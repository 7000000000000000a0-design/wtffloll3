local url = "https://raw.githubusercontent.com/7000000000000000a0-design/wtffloll3/91a00e582a0d41feae00f672c48fe060410925fc/NanamiTiming-Toji.lua"
local scriptSource = game:HttpGet(url)

local function replace(text, old, new)
    local a, b = text:find(old, 1, true)
    assert(a, "Patch target missing: " .. old)
    return text:sub(1, a - 1) .. new .. text:sub(b + 1)
end

local menuPatch = [==[
local function replaceMenu(text, old, new)
    local a, b = text:find(old, 1, true)
    assert(a, "Menu patch target missing: " .. old)
    return text:sub(1, a - 1) .. new .. text:sub(b + 1)
end

source = replaceMenu(
    source,
    "local ok = pcall(function() M.x, M.y = mouse.X, mouse.Y + mouseOffset end)",
    "local ok = pcall(function() local p = game:GetService('UserInputService'):GetMouseLocation(); M.x, M.y = p.X, p.Y end)"
)

source = replaceMenu(
    source,
    "if pressed(x, y, SIDEBAR, 52) and not slide then",
    "if pressed(x, y, w, 34) and not slide then"
)

source = replaceMenu(
    source,
    'if grab ~= lastGrab and type(setrobloxinput) == "function" then',
    "if false then"
)

source = [[
local UIS = game:GetService("UserInputService")

local isrbxactive = function()
    return true
end

local ismouse1pressed = function()
    return UIS:IsMouseButtonPressed(
        Enum.UserInputType.MouseButton1
    )
end

local keyNames = {
    [8]="Backspace", [9]="Tab", [13]="Return",
    [16]="LeftShift", [17]="LeftControl", [18]="LeftAlt",
    [27]="Escape", [32]="Space",
    [33]="PageUp", [34]="PageDown", [35]="End", [36]="Home",
    [37]="Left", [38]="Up", [39]="Right", [40]="Down",
    [45]="Insert", [46]="Delete",
    [160]="LeftShift", [161]="RightShift",
    [162]="LeftControl", [163]="RightControl",
    [164]="LeftAlt", [165]="RightAlt",
    [186]="Semicolon", [187]="Equals", [188]="Comma",
    [189]="Minus", [190]="Period", [191]="Slash",
    [192]="Backquote", [219]="LeftBracket",
    [220]="BackSlash", [221]="RightBracket", [222]="Quote"
}

local digits = {
    "Zero", "One", "Two", "Three", "Four",
    "Five", "Six", "Seven", "Eight", "Nine"
}

local iskeypressed = function(vk)
    if vk == 1 then
        return ismouse1pressed()
    elseif vk == 2 then
        return UIS:IsMouseButtonPressed(
            Enum.UserInputType.MouseButton2
        )
    end

    local name = keyNames[vk]

    if vk >= 48 and vk <= 57 then
        name = digits[vk - 47]
    elseif vk >= 65 and vk <= 90 then
        name = string.char(vk)
    elseif vk >= 112 and vk <= 123 then
        name = "F" .. tostring(vk - 111)
    end

    return name and UIS:IsKeyDown(Enum.KeyCode[name]) or false
end
]] .. source

local menuChunk, menuError = loadstring(source)
assert(menuChunk, menuError)
local library = menuChunk()
]==]

scriptSource = replace(
    scriptSource,
    "local library = loadstring(source)()",
    menuPatch
)

scriptSource = scriptSource:gsub(
    "local key=gui%.Address or gui",
    "local key=gui"
)

scriptSource = scriptSource:gsub(
    "local id=eye%.Address or eye",
    "local id=eye"
)

local run, err = loadstring(scriptSource)
assert(run, err)
run()
