vim.g.mapleader = ' '

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "williamboman/mason.nvim",
        opts = {}
      }
    }
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lsp-signature-help",

      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip"
    }
  },

  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        theme = "catppuccin",
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' }
      }
    }
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build"
      }
    },
    branch = "0.1.x"
  },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    config = function()
      require("catppuccin").setup({ no_italic = true })

      vim.cmd.colorscheme("catppuccin")
    end
  },

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate"
  }
})

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true

vim.keymap.set("n", "<Leader>y", ":%y+<CR>")
vim.keymap.set("n", "<Leader>e", vim.diagnostic.open_float)

require("telescope").load_extension("fzf")

local builtin = require("telescope.builtin")

vim.keymap.set("n", "<Leader>sf", builtin.find_files)
vim.keymap.set("n", "<Leader>sb", builtin.buffers)
vim.keymap.set("n", "<Leader>sd", builtin.diagnostics)
vim.keymap.set("n", "gr", builtin.lsp_references)

require("nvim-treesitter.configs").setup({
  auto_install = true,
  highlight = { enable = true }
})

local lspconfig = require("lspconfig")

vim.diagnostic.config({ float = { border = "rounded" }})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

    vim.keymap.set("n", "<Leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<Leader>ca", vim.lsp.buf.code_action, opts)
  end
})

local servers = { "clangd" }
local capabilities = require("cmp_nvim_lsp").default_capabilities()

for i, server in ipairs(servers) do
  lspconfig[server].setup({ capabilities = capabilities })
end

local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end
  },

  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered()
  },

  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item()
  }),

  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "nvim_lsp_signature_help" },
    { name = "luasnip" }
  })
})
