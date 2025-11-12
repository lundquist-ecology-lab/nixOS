local ok, mason = pcall(require, 'mason')
if not ok then
  return
end

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
  vim.lsp.config(server, {
    capabilities = capabilities,
  })
end

-- Manually configure R since it's not installed via Mason
vim.lsp.config('r_language_server', {
  cmd = { "R", "--slave", "-e", "languageserver::run()" },
  capabilities = capabilities,
})

-- Optimize LSP for network shares
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = "/mnt/*/*",
  callback = function()
    -- Reduce LSP file watching on network shares
    local clients = vim.lsp.get_clients({bufnr = 0})
    for _, client in ipairs(clients) do
      if client.server_capabilities.workspace then
        -- Disable file watching for network shares
        client.server_capabilities.workspace.didChangeWatchedFiles = nil
      end
    end
  end,
})
