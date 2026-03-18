return {
  cmd = { 'metals' },
  filetypes = { 'scala', 'sbt', 'java' },
  root_markers = { 'build.sbt', 'build.sc', 'pom.xml', '.git' },
  settings = {
    metals = {
      showImplicitArguments = true,
      showImplicitConversions = true,
      showInferredType = true,
      superMethodLensesEnabled = true,
      enableSemanticHighlighting = true,
    },
  },
}
