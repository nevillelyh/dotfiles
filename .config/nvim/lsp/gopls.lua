return {
  cmd = { 'gopls' },
  filetypes = { 'go', 'gomod' },
  root_markers = { 'go.mod', 'go.work', '.git' },
  settings = {
    gopls = {
      analyses = { unusedparams = true },
      staticcheck = true,
      gofumpt = true,
    },
  },
}
