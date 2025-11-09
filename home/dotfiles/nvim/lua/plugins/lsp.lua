local ok, mason = pcall(require, 'mason')
if not ok then
  return
end

local lspconfig = require("lspconfig")

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

mason.setup {
  ui = {
    icons = {
      server_installed = "✓",
      server_pending = "➜",
      server_uninstalled = "✗"
    }
  }
}

local servers = {
  "lua_ls",
  "pyright",
  "denols",
  "ts_ls",
  "html",
  "cssls",
  "jsonls",
  "yamlls",
  "bashls",
  "clangd",
  "rust_analyzer",
  "gopls",
  "marksman",
  "taplo",
  "texlab",
  "dockerls",
  "docker_compose_language_service",
}

require('mason-lspconfig').setup {
  ensure_installed = servers,
  automatic_installation = true,
}

for _, server in ipairs(servers) do
  lspconfig[server].setup {
    capabilities = capabilities,
  }
end

-- Manually configure R since it's not installed via Mason
lspconfig.r_language_server.setup({
  cmd = { "R", "--slave", "-e", "languageserver::run()" },
  capabilities = capabilities,
})

