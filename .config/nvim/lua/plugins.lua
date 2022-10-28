local status, packer = pcall(require, "packer")
if (not status) then
  print("Packer is not installed")
  return
end

vim.cmd [[packadd packer.nvim]]

-- https://github.com/wbthomason/packer.nvim#quickstart
-- after you make changes here you have to run
-- :PackerSync
-- -- Perform `PackerUpdate` and then `PackerCompile`
--
packer.startup(function(use)
    use 'wbthomason/packer.nvim'

    use {
        'svrana/neosolarized.nvim',
        requires = { 'tjdevries/colorbuddy.nvim' }
    }

    use 'ggandor/lightspeed.nvim'

    use {'nvim-treesitter/nvim-treesitter'}
    use {
        'nvim-orgmode/orgmode',
        config = function()
            require('orgmode').setup{}
        end
    }

    -- https://github.com/hrsh7th/nvim-cmp
    -- some auto completion
    use 'neovim/nvim-lspconfig'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-cmdline'
    use 'hrsh7th/nvim-cmp'

    -- " For luasnip users
    use 'L3MON4D3/LuaSnip'
    use 'saadparwaiz1/cmp_luasnip'

    -- git magic
    use 'lewis6991/gitsigns.nvim'

    -- vim-table-mode
    -- <leader>tm = table mode ||
    -- <leader>tt = tableize
    -- <leader>tdc = delete column
    -- 'ci|' = change inside column
    use 'dhruvasagar/vim-table-mode'

    -- lualine
    use {
        'nvim-lualine/lualine.nvim',
        requires = {
            'kyazdani42/nvim-web-devicons',
            opt = true
        }
    }

    -- https://github.com/numToStr/Comment.nvim
    -- gcc - comment
    -- gcb - block comment
    use 'numToStr/Comment.nvim'
end)
