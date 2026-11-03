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

source=source:gsub("local KEY_NAME = {}", 'VK.MButton=0x04\nKEY_LABEL[0x04]="Middle Mouse"\nlocal KEY_NAME = {}',1)

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

-- Macros copied from the requested GT Goku script version.
local macrosModule = [====[
-- Lua equivalent of x.ahk. All key codes below are Windows virtual-key codes.
local macrosTab=window:Tab("Macros")
local macrosOn=false
local gojoOn=false
local aizenOn=true
local aizenToggle,gojoToggle,dioToggle
local dioOn=false
local macroBusy=false
local macroHeldKeys={}
local macroError
local macroBindings={
    {trigger=0x45,first=0x32,second=0x31,delay=.020},
    {trigger=0x54,first=0x32,second=0x34,delay=.040},
    {trigger=0x5A,first=0x33,second=0x31,delay=.040},
    {trigger=0x58,first=0x33,second=0x34,delay=.040},
}
local function macroFocused()
    if type(isrbxactive)~="function" then return false end
    local ok,active=pcall(isrbxactive)
    return ok and active==true
end
local function macroReady()
    return type(iskeypressed)=="function" and type(keypress)=="function"
        and type(keyrelease)=="function" and type(isrbxactive)=="function"
        and task and type(task.spawn)=="function" and type(task.wait)=="function"
end
local function macroReport(text)
    if macroError~=text then macroError=text;print("[Macros] "..text) end
end
local macroNotice
local macroNoticeUntil=0
local function noticeDrawing(kind,props)
    local object=Drawing.new(kind)
    ownedDrawings[#ownedDrawings+1]=object
    for key,value in pairs(props)do object[key]=value end
    return object
end
local function showMacroNotice(on)
    if not macroNotice then
        macroNotice={parts={}}
        local function background(kind)
            local object=noticeDrawing(kind,{
                Filled=true,Color=Color3.fromRGB(16,16,20),
                Transparency=1,ZIndex=1000,Visible=false,
            })
            macroNotice.parts[#macroNotice.parts+1]=object
            return object
        end
        macroNotice.horizontal=background("Square")
        macroNotice.vertical=background("Square")
        macroNotice.corners={}
        for i=1,4 do
            local corner=background("Circle")
            corner.Radius=10
            corner.NumSides=24
            macroNotice.corners[i]=corner
        end
        macroNotice.dot=noticeDrawing("Circle",{
            Filled=true,Radius=3,NumSides=16,Color=Color3.fromRGB(235,235,240),
            Transparency=1,ZIndex=1001,Visible=false,
        })
        macroNotice.title=noticeDrawing("Text",{
            Text="ahahaha",Size=13,Font=2,Center=false,Outline=false,
            Color=Color3.fromRGB(240,240,245),Transparency=1,ZIndex=1001,Visible=false,
        })
        macroNotice.text=noticeDrawing("Text",{
            Size=13,Font=2,Center=false,Outline=false,
            Color=Color3.fromRGB(150,150,160),Transparency=1,ZIndex=1001,Visible=false,
        })
        macroNotice.parts[#macroNotice.parts+1]=macroNotice.dot
        macroNotice.parts[#macroNotice.parts+1]=macroNotice.title
        macroNotice.parts[#macroNotice.parts+1]=macroNotice.text
    end
    macroNotice.text.Text=on and "Macro is ON" or "Macro is OFF"
    macroNoticeUntil=(tick and tick() or os.clock())+2
end
local function updateMacroNotice()
    if not macroNotice then return end
    local visible=alive and (tick and tick() or os.clock())<macroNoticeUntil
    local camera=world.CurrentCamera
    local size=camera and camera.ViewportSize
    if not size or size.X<=0 then visible=false end
    if visible then
        local width,height,radius=244,38,10
        local x,y=math.max(0,size.X-width-16),16
        macroNotice.horizontal.Position=Vector2.new(x+radius,y)
        macroNotice.horizontal.Size=Vector2.new(width-radius*2,height)
        macroNotice.vertical.Position=Vector2.new(x,y+radius)
        macroNotice.vertical.Size=Vector2.new(width,height-radius*2)
        macroNotice.corners[1].Position=Vector2.new(x+radius,y+radius)
        macroNotice.corners[2].Position=Vector2.new(x+width-radius,y+radius)
        macroNotice.corners[3].Position=Vector2.new(x+radius,y+height-radius)
        macroNotice.corners[4].Position=Vector2.new(x+width-radius,y+height-radius)
        macroNotice.dot.Position=Vector2.new(x+14,y+height/2)
        macroNotice.title.Position=Vector2.new(x+25,y+11)
        macroNotice.text.Position=Vector2.new(x+89,y+11)
    end
    for _,object in ipairs(macroNotice.parts)do object.Visible=visible end
end
-- Persist the master switch without adding another visible control.
local macroSavedState=macrosTab:Toggle({
    Name="Saved macro state",Default=false,Flag="macro_master_enabled",
    Callback=function(on) macrosOn=on end,
})
macroSavedState:SetVisible(false)
macrosOn=macroSavedState.Value==true
macrosTab:Keybind({Name="Toggle Macros",Default="F2",Flag="macro_toggle_key",Mode="Press",Callback=function()
    if not alive or not macroFocused() then return end
    macroSavedState:Set(not macrosOn)
    macrosOn=macroSavedState.Value==true
    window:Save()
    print("[Macros] "..(macrosOn and "ON" or "OFF"))
    local noticeOK,noticeErr=pcall(showMacroNotice,macrosOn)
    if not noticeOK then macroReport(tostring(noticeErr)) end
    if macrosOn and not macroReady() then
        macroReport("Requires iskeypressed, keypress, keyrelease, isrbxactive and task APIs.")
    end
end})
local function macroTap(vk)
    macroHeldKeys[vk]=true
    keypress(vk)
    keyrelease(vk)
    macroHeldKeys[vk]=nil
end
macrosTab:Section("Aizen Macros")
aizenToggle=macrosTab:Toggle({Name="Use Aizen Macro",Default=true,Flag="macro_use_aizen",Callback=function(on)
    aizenOn=on
    if on and dioOn then
        dioOn=false
        if dioToggle then dioToggle:Set(false) end
    end
    if on and gojoOn then
        gojoOn=false
        if gojoToggle then gojoToggle:Set(false) end
    end
end})
local function runMacro(selected)
    if not alive or not macrosOn or not aizenOn or gojoOn or macroBusy or not macroFocused() then return end
    if not macroReady() then
        macroReport("Requires iskeypressed, keypress, keyrelease, isrbxactive and task APIs.")
        return
    end
    macroBusy=true
    task.spawn(function()
        local ok,err=pcall(function()
            if not alive or not macrosOn or not aizenOn or gojoOn or not macroFocused() then return end
            macroTap(selected.first)
            task.wait(selected.delay)
            if alive and macrosOn and aizenOn and not gojoOn and macroFocused() then macroTap(selected.second) end
        end)
        for vk in pairs(macroHeldKeys)do
            pcall(keyrelease,vk)
            macroHeldKeys[vk]=nil
        end
        macroBusy=false
        if not ok then macroReport(tostring(err)) end
    end)
end
for index,binding in ipairs(macroBindings)do
    local selected=binding
    macrosTab:Keybind({
        Name=string.char(selected.first).." > "..string.char(selected.second).." ("..tostring(math.floor(selected.delay*1000+.5)).." ms)",
        Default=selected.trigger,
        Flag="macro_sequence_"..tostring(index),
        Mode="Press",
        Callback=function() runMacro(selected) end,
    })
end


macrosTab:Section("Gojo Macros")
gojoToggle=macrosTab:Toggle({Name="Use Gojo Macros",Default=false,Flag="macro_use_gojo",Callback=function(on)
    gojoOn=on
    if on and dioOn then
        dioOn=false
        if dioToggle then dioToggle:Set(false) end
    end
    if on and aizenOn then
        aizenOn=false
        if aizenToggle then aizenToggle:Set(false) end
    end
end})
local gojoBindings={
    {name="TP + Pull Blue",key="Z",steps={{0x33,.072},{0x33,.020},{0x51,0}}},
    {name="Instant Blue TP",key="T",steps={{0x33,.092},{0x51,0}}},
    {name="Purple Combo",key="MButton",steps={{0x33,.010},{0x32,1.550},{0x20,0},{0x51,0}}},
    {name="TP + Blue (blue)",key="V",steps={{0x33,.020},{0x51,0}}},
}
local function runGojoMacro(selected)
    if not alive or not macrosOn or not gojoOn or macroBusy or not macroFocused() then return end
    if not macroReady() then
        macroReport("Requires iskeypressed, keypress, keyrelease, isrbxactive and task APIs.")
        return
    end
    macroBusy=true
    task.spawn(function()
        local ok,err=pcall(function()
            for _,step in ipairs(selected.steps)do
                if not alive or not macrosOn or not gojoOn or not macroFocused() then return end
                macroTap(step[1])
                if step[2]>0 then task.wait(step[2]) end
            end
        end)
        for vk in pairs(macroHeldKeys)do
            pcall(keyrelease,vk)
            macroHeldKeys[vk]=nil
        end
        macroBusy=false
        if not ok then macroReport(tostring(err)) end
    end)
end
for index,binding in ipairs(gojoBindings)do
    local selected=binding
    macrosTab:Keybind({
        Name=selected.name,Default=selected.key,
        Flag="gojo_macro_sequence_"..tostring(index),Mode="Press",
        Callback=function() runGojoMacro(selected) end,
    })
end


macrosTab:Section("DIO Macros")
dioToggle=macrosTab:Toggle({Name="Use DIO Macros",Default=false,Flag="macro_use_dio",Callback=function(on)
    dioOn=on
    if on then
        aizenOn=false;gojoOn=false
        if aizenToggle then aizenToggle:Set(false) end
        if gojoToggle then gojoToggle:Set(false) end
    end
end})
local function runDioMacro()
    if not alive or not macrosOn or not dioOn or macroBusy or not macroFocused() then return end
    if not macroReady() or type(mouse1press)~="function" or type(mouse1release)~="function" then
        macroReport("DIO requires mouse1press and mouse1release plus the keyboard macro APIs.")
        return
    end
    macroBusy=true
    task.spawn(function()
        local mouseHeld,spaceHeld=false,false
        local function active() return alive and macrosOn and dioOn and macroFocused() end
        local ok,err=pcall(function()
            if not active() then return end
            mouseHeld=true;mouse1press()
            task.wait(.230)
            if not active() then return end
            spaceHeld=true;keypress(0x20)
            task.wait(.210)
            if not active() then return end
            macroTap(0x33)
        end)
        if spaceHeld then pcall(keyrelease,0x20) end
        if mouseHeld then pcall(mouse1release) end
        for vk in pairs(macroHeldKeys)do
            pcall(keyrelease,vk);macroHeldKeys[vk]=nil
        end
        macroBusy=false
        if not ok then macroReport(tostring(err)) end
    end)
end
macrosTab:Keybind({Name="Uptilt",Default="X",Flag="dio_uptilt_key",Mode="Press",
    Callback=function() runDioMacro() end})

-- Apply saved selections immediately; Nova also restores their callbacks on its next frame.
aizenOn=aizenToggle.Value==true
gojoOn=gojoToggle.Value==true
dioOn=dioToggle.Value==true

]====]
scriptSource = replace(
    scriptSource,
    'connection=game:GetService("RunService").Heartbeat:Connect(function()',
    macrosModule .. 'connection=game:GetService("RunService").Heartbeat:Connect(function()\n    pcall(updateMacroNotice)'
)

local run, err = loadstring(scriptSource)
assert(run, err)
run()
