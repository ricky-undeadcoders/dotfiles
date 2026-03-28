-- LSP configuration for Platform Productivity work
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Go language server (already configured via gopls)
        gopls = {
          settings = {
            gopls = {
              analyses = {
                unusedparams = true,
              },
              staticcheck = true,
            },
          },
        },
        -- Jsonnet language server
        jsonnet_ls = {},
        -- YAML language server (for Kubernetes manifests)
        yamlls = {
          settings = {
            yaml = {
              schemas = {
                kubernetes = "/*.yaml",
              },
            },
          },
        },
        -- Terraform language server
        terraformls = {},
        -- Bash language server
        bashls = {},
      },
    },
  },
}
