local M = {}

function M.open_markdown_preview()
    local file = vim.fn.expand('%:p')
    if vim.fn.has('mac') == 1 then
        -- Try Firefox first, fallback to Chrome, then Safari
        local firefox_installed = vim.fn.system("which /Applications/Firefox.app/Contents/MacOS/firefox")
        local chrome_installed = vim.fn.system("which /Applications/Google\\ Chrome.app/Contents/MacOS/Google\\ Chrome")
        
        if vim.fn.filereadable("/Applications/Firefox.app/Contents/MacOS/firefox") == 1 then
            vim.fn.system('open -a "Firefox" ' .. vim.fn.shellescape(file))
        elseif vim.fn.filereadable("/Applications/Google Chrome.app/Contents/MacOS/Google Chrome") == 1 then
            vim.fn.system('open -a "Google Chrome" ' .. vim.fn.shellescape(file))
        else
            vim.fn.system('open -a "Safari" ' .. vim.fn.shellescape(file))
        end
    elseif vim.fn.has('unix') == 1 then
        -- Try Firefox first, fallback to Chrome
        local firefox_path = vim.fn.system("which firefox"):gsub("\n", "")
        local chrome_path = vim.fn.system("which google-chrome"):gsub("\n", "")
        
        if firefox_path ~= "" then
            vim.fn.system('firefox ' .. vim.fn.shellescape(file) .. ' &')
        elseif chrome_path ~= "" then
            vim.fn.system('google-chrome ' .. vim.fn.shellescape(file) .. ' &')
        else
            vim.fn.system('xdg-open ' .. vim.fn.shellescape(file))
        end
    end
end

-- Key mapping như video Kunkka: <leader> + ob
vim.keymap.set('n', '<leader>ob', M.open_markdown_preview, { desc = "Open markdown in browser" })

return M

