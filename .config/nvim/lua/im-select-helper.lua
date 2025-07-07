local M = {}

function M.get_current_layout()
    local handle = io.popen("im-select")
    local result = handle:read("*a")
    handle:close()
    return result:gsub("%s+", "")
end

function M.switch_to_layout(layout)
    os.execute("im-select " .. layout)
end

-- Lưu layout của lần insert trước
local previous_layout = "com.apple.keylayout.ABC"

function M.on_insert_enter()
    vim.schedule(function()
        if previous_layout and previous_layout ~= "" then
            M.switch_to_layout(previous_layout)
        end
    end)
end

function M.on_insert_leave()
    vim.schedule(function()
        previous_layout = M.get_current_layout()
        M.switch_to_layout("com.apple.keylayout.ABC")
    end)
end

return M

