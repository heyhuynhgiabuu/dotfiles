local M = {}

function M.open_markdown_preview()
    local file = vim.fn.expand('%:p')
    if vim.fn.has('mac') == 1 then
        vim.fn.system('open ' .. file)
    elseif vim.fn.has('unix') == 1 then
        vim.fn.system('xdg-open ' .. file)
    end
end

-- Key mapping như video Kunkka: <leader> + ob
vim.keymap.set('n', '<leader>ob', M.open_markdown_preview, { desc = "Open markdown in browser" })

return M

