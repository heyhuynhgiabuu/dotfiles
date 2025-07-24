local M = {}

-- Default layouts
local DEFAULT_EN_LAYOUT = "com.apple.keylayout.ABC"
local previous_layout = DEFAULT_EN_LAYOUT

-- Check if im-select is available
local function is_im_select_available()
    local handle = io.popen("which im-select 2>/dev/null")
    local result = handle:read("*a")
    handle:close()
    return result ~= ""
end

function M.get_current_layout()
    if not is_im_select_available() then
        return DEFAULT_EN_LAYOUT
    end
    
    local handle = io.popen("im-select 2>/dev/null")
    if not handle then
        return DEFAULT_EN_LAYOUT
    end
    
    local result = handle:read("*a")
    handle:close()
    return result:gsub("%s+", "")
end

function M.switch_to_layout(layout)
    if not is_im_select_available() then
        return
    end
    
    if layout and layout ~= "" then
        os.execute("im-select " .. layout .. " 2>/dev/null")
    end
end

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
        M.switch_to_layout(DEFAULT_EN_LAYOUT)
    end)
end

-- Initialize with current layout
if is_im_select_available() then
    previous_layout = M.get_current_layout()
end

return M
