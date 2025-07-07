-- Advanced Debugger
return {
    "mfussenegger/nvim-dap",
    config = function()
        -- cấu hình dap cho ngôn ngữ bạn muốn
        require("dap").setup()
    end
}