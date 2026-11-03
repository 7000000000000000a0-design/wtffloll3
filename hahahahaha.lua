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

-- Add the attached timing checks to this loader's existing menu.
local instaTimingModule = [====[
-- Timing callbacks adapted from ahmed abditori.txt.
local updateInstaTimings
do
    local instaTab=window:Tab("Insta Timing")
    local instaOn=false
    local rs=game:GetService("ReplicatedStorage")
    local targets={"BlackFlashCheck","NanamiCheck","OsuCheck","KokushiboCheck","ChrolloCheck","ChrolloCheck2"}
    local entries={}
    local lastFired=-math.huge
    local nextScan=0
    local status=instaTab:Label({Text="Insta Timing: OFF"})
    local function fireM1()
        local now=tick and tick() or os.clock()
        if now-lastFired<.5 then return end
        lastFired=now
        local player=players.LocalPlayer
        local char=player and player.Character
        local root=char and char:FindFirstChild("HumanoidRootPart")
        local humanoid=char and char:FindFirstChildWhichIsA("Humanoid")
        if not root or not humanoid or humanoid.Health<=0 then return end
        if char:FindFirstChild("Stun") or char:FindFirstChild("Ragdolled") or char:FindFirstChild("Knocked") then return end
        local backpack=player:FindFirstChild("Backpack")
        local input=backpack and backpack:FindFirstChild("Input")
        if not input then return end
        local jitter=Vector3.new((math.random()-.5)*4,(math.random()-.5)*2,(math.random()-.5)*4)
        local dodgeVelo
        if math.random()<.15 then
            dodgeVelo=Vector3.new(math.random()*2-1,0,math.random()*2-1)*math.random()
        end
        input:FireServer("M1",{
            air=false,mousehit=root.CFrame*CFrame.new(jitter),md=Vector3.zero,
            dodgevelo=dodgeVelo,skeydown=false,skeyreal=false,
        })
    end
    local wrap=newcclosure or function(fn)return fn end
    local function restore(entry)
        if entry.mode=="hook" then
            return pcall(hookfunction,entry.target,entry.original)
        end
        return pcall(function()
            local ok,current=pcall(function()return entry.remote.OnClientInvoke end)
            if not ok or current==entry.callback then
                entry.remote.OnClientInvoke=entry.original
            end
        end)
    end
    instaCleanup=function()
        instaOn=false
        for remote,entry in pairs(entries)do
            local ok,err=restore(entry)
            if ok then entries[remote]=nil
            else print("[Insta Timing] Restore failed: "..tostring(err)) end
        end
    end
    local function install(remote,current,readable)
        local entry={remote=remote,original=readable and current or nil}
        entry.callback=wrap(function(...)
            if not alive or not instaOn then
                if type(entry.original)=="function" then return entry.original(...) end
                return
            end
            local ok,err=pcall(fireM1)
            if not ok then print("[Insta Timing] "..tostring(err)) end
            return true,false
        end)
        if readable and type(current)=="function" then
            if type(hookfunction)~="function" then
                return nil,"This runner has no hookfunction API"
            end
            entry.mode="hook";entry.target=current
            local ok,original=pcall(hookfunction,current,entry.callback)
            if not ok then return nil,tostring(original) end
            if type(original)~="function" then
                return nil,"hookfunction did not return the original callback"
            end
            entry.original=original
        else
            entry.mode="property"
            local ok,err=pcall(function()remote.OnClientInvoke=entry.callback end)
            if not ok then return nil,tostring(err) end
        end
        return entry
    end
    updateInstaTimings=function()
        if not alive or not instaOn then return end
        local now=tick and tick() or os.clock()
        if now<nextScan then return end
        nextScan=now+20+math.random()*20
        for remote,entry in pairs(entries)do
            if remote.Parent~=rs then
                local restored=restore(entry)
                if restored then entries[remote]=nil end
            end
        end
        local count,errors=0,{}
        for _,name in ipairs(targets)do
            local remote=rs:FindFirstChild(name)
            if remote and remote.ClassName=="RemoteFunction" then
                local readable,current=pcall(function()return remote.OnClientInvoke end)
                local entry=entries[remote]
                local expected=entry and (entry.mode=="hook" and entry.target or entry.callback)
                if entry and readable and current~=expected then
                    local restored,err=restore(entry)
                    if restored then entries[remote]=nil;entry=nil
                    else errors[#errors+1]=name..": "..tostring(err) end
                end
                if not entry then
                    local installed,err=install(remote,current,readable)
                    if installed then entries[remote]=installed;entry=installed
                    else errors[#errors+1]=name..": "..tostring(err) end
                end
                if entry then count=count+1 end
            end
        end
        status:SetText("Active checks: "..tostring(count).."/6"..(#errors>0 and " | "..errors[1] or ""))
        for _,err in ipairs(errors)do print("[Insta Timing] "..err) end
    end
    instaTab:Toggle({Name="Enable Insta Timing",Default=false,Callback=function(on)
        if not on then
            instaCleanup();status:SetText("Insta Timing: OFF")
            return
        end
        instaOn=true;nextScan=0
        local ok,err=pcall(updateInstaTimings)
        if not ok then status:SetText("Insta Timing unavailable");print("[Insta Timing] "..tostring(err)) end
    end})
end

]====]
scriptSource = replace(
    scriptSource,
    "local connection, lastStatus, lastError",
    "local connection, lastStatus, lastError\nlocal instaCleanup"
)
scriptSource = replace(
    scriptSource,
    "    alive=false; enabled=false",
    "    alive=false; enabled=false\n    if instaCleanup then pcall(instaCleanup) end"
)
scriptSource = replace(
    scriptSource,
    'connection=game:GetService("RunService").Heartbeat:Connect(function()',
    instaTimingModule .. 'connection=game:GetService("RunService").Heartbeat:Connect(function()\n    if updateInstaTimings then pcall(updateInstaTimings) end'
)

local run, err = loadstring(scriptSource)
assert(run, err)
run()
