local config = {
	encrypt_cmd = {
		'gpg2',
		'--batch',
		'--no-tty',
		'--yes',
		'--default-recipient-self',
		'-eo',
	},
	decrypt_cmd = { 'gpg2', '--batch', '--no-tty', '--yes', '-d' },
}

local run_cmd = function(cmd, filename, stdin)
	local c = vim.tbl_extend('force', cmd, { [#cmd + 1] = filename })
	return vim.system(c, { stdin = stdin, text = true }):wait()
end

local is_new_file = function(obj)
	return obj.code == 2
		and string.find(obj.stderr, 'decrypt_message failed: No such file or directory') ~= nil
end

local match_filetype = function(name, contents)
	return vim.filetype.match({ filename = string.sub(name, 0, -5), contents = contents })
end

local M = {}

M.setup = function(c)
	config = vim.tbl_extend('force', config, c or {})

	vim.api.nvim_create_autocmd({ 'BufReadCmd' }, {
		pattern = '*.gpg',
		group = vim.api.nvim_create_augroup('gpg_buf_read_cmd', { clear = true }),
		callback = function(opts)
			vim.opt_local.buftype = 'acwrite'
			vim.opt_local.backup = false
			vim.opt_local.shada = ''
			vim.opt_local.swapfile = false
			vim.opt_local.undofile = false
			vim.opt_local.writebackup = false

			local obj = run_cmd(config.decrypt_cmd, opts.file)
			if obj.code ~= 0 then
				if not is_new_file(obj) then vim.notify(obj.stderr, vim.log.levels.ERROR) end
				vim.opt_local.filetype = match_filetype(opts.file)
				return
			end

			local lines = vim.split(string.sub(obj.stdout, 0, -2), '\n')
			vim.opt_local.filetype = match_filetype(opts.file, lines)

			vim.api.nvim_exec_autocmds('BufReadPre', {})
			vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
			vim.api.nvim_exec_autocmds('BufReadPost', {})
		end,
	})

	vim.api.nvim_create_autocmd({ 'BufWriteCmd' }, {
		pattern = '*.gpg',
		group = vim.api.nvim_create_augroup('gpg_buf_write_cmd', { clear = true }),
		callback = function(opts)
			vim.api.nvim_exec_autocmds('BufWritePre', {})

			local buffer = vim.api.nvim_buf_get_lines(0, 0, -1, true)
			local obj = run_cmd(config.encrypt_cmd, opts.file, buffer)
			if obj.code == 0 then
				vim.notify(string.format('"%s" encrypted', opts.file), vim.log.levels.INFO)
			else
				vim.notify(obj.stderr, vim.log.levels.ERROR)
				return
			end

			vim.api.nvim_exec_autocmds('BufWritePost', {})
			vim.opt_local.modified = false
		end,
	})
end

return M
