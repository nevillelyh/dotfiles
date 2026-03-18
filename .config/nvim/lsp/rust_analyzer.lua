return {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml', 'Cargo.lock', '.git' },
  settings = {
    ['rust-analyzer'] = {
      checkOnSave = true,
      check = {
        command = 'clippy',
      },
      cargo = {
        allFeatures = true,
      },
      procMacro = {
        enable = true,
      },
      inlayHints = {
        bindingModeHints = { enable = true },
        chainingHints = { enable = true },
        parameterHints = { enable = true },
        typeHints = { enable = true },
      },
    },
  },
}
