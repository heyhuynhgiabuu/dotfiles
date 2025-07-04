local lspconfig = require("lspconfig")

-- Cài jdtls bên ngoài hoặc brew install jdtls
lspconfig.jdtls.setup({
	cmd = { "jdtls" },
})

