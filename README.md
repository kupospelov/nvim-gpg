# nvim-gpg

A plugin for editing `gpg` encrypted files.

## Installation

Requires version `0.10` or newer.

[packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua

require('packer').startup(function(use)
    use('kupospelov/nvim-gpg')
end)

```

[lazy.nvim](https://github.com/folke/lazy.nvim):

```lua

require('lazy').setup({
    { 'kupospelov/nvim-gpg' },
})

```

## Configuration

The default configuration:

```lua

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

```

Settings can be changed using the `setup` function that accepts a table with the following fields:
* `encrypt_cmd` contains the `gpg` command that encrypts the file. The last argument must be `--output`.
* `decrypt_cmd` contains the `gpg` command that writes the decrypted file to standard output.

### Example

```lua

local gpg = require('gpg')
gpg.setup()

```

## TODO

* Support non-default recipients.
