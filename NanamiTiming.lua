-- Matcha version. Drawing menu provided by Nova (Martinikaws).
local old = _G.NanamiTimingMatcha
if old and old.Destroy then pcall(old.Destroy) end
assert(Drawing and type(Drawing.new) == "function", "Matcha Drawing API is required")
local url = "https://raw.githubusercontent.com/Martinikaws/Nova/88f5bd44551d03d6a01ba07b761519eb3d8ccb34/Nova.lua"
local source
if type(httpget) == "function" then source = httpget(url) else source = game:HttpGet(url) end
local library = loadstring(source)()
local Nova = library or _G.Nova
assert(Nova and Nova.CreateWindow, "Nova menu library did not load")
local window = Nova:CreateWindow({Title="ABA Timings", Subtitle="Matcha v4", ToggleKey="RightShift", Open=true, Size={540,410}})
local tab = window:Tab("Nanami")
tab:Section("Ratio timing")
local enabled, alive, clicked = false, true, false
local prompts = {}
local connection, lastStatus, lastError
local status = tab:Label("Auto Timing: OFF")
local function message(text)
    if text ~= lastStatus then lastStatus=text; status:SetText(text) end
end
tab:Toggle({Name="Auto Timing", Default=false, Callback=function(on)
    enabled=on; prompts={}; clicked=false
    message(on and "Waiting for your Nanami move..." or "Auto Timing: OFF")
    if on then window:Toggle(false) end
end})
tab:Label("Right Shift: show / hide this menu")
tab:Label("Enable once, then use your moves. Every new prompt is timed.")
tab:Label("Enabling automatically hides this menu.")
local state = {}
function state.Destroy()
    alive=false; enabled=false
    if connection then connection:Disconnect(); connection=nil end
    window:Destroy()
    if _G.NanamiTimingMatcha == state then _G.NanamiTimingMatcha=nil end
end
_G.NanamiTimingMatcha=state
tab:Button({Name="Close and stop", Callback=state.Destroy})
local players=game:GetService("Players")
local world=game:GetService("Workspace")
local armedUntil=0
local lastKeys={}
local positionOffset
-- Matcha's screen coordinates can be unreliable on rotated BillboardGui bars.
-- The reference script reads the UDim2 X.Scale float instead; never write memory.
if type(memory_read) == "function" then
    local ok,data=pcall(function()
        local body
        if type(httpget)=="function" then body=httpget("https://offsets.imtheo.lol/Offsets.json")
        else body=game:HttpGet("https://offsets.imtheo.lol/Offsets.json") end
        return game:GetService("HttpService"):JSONDecode(body)
    end)
    local value=ok and data and data.Offsets and data.Offsets.GuiObject and data.Offsets.GuiObject.Position
    if type(value)=="string" then value=tonumber(value) end
    if type(value)=="number" and value>0 and value<8192 and value%4==0 then positionOffset=value end
end
local function readRatio(bar,cutter)
    local ok,value=pcall(function()return cutter.Position.X.Scale end)
    if ok and type(value)=="number" and value>=0 and value<=1 then return value,"local" end
    if positionOffset and type(memory_read)=="function" then
        local success,scale=pcall(function()return memory_read("float",cutter.Address+positionOffset) end)
        if success and type(scale)=="number" and scale==scale and scale>=0 and scale<=1 then return scale,"cursor" end
    end
    local size,pos=bar.AbsoluteSize,bar.AbsolutePosition
    local cutSize,cutPos=cutter.AbsoluteSize,cutter.AbsolutePosition
    if size and pos and cutSize and cutPos and size.X>1 then
        return (cutPos.X+cutSize.X*.5-pos.X)/size.X,"screen fallback"
    end
end
-- Other explicit reaction checks found in .RunOnceLocal.
local flashTab=window:Tab("Black Flash")
flashTab:Section("BlackFlashCheck")
local flashOn=false
local flashStatus=flashTab:Label("Auto Black Flash: OFF")
flashTab:Label("Unverified cue detection: click when the zoom starts returning.")
local flash={last=nil,minimum=math.huge,descending=false,fired=false}
flashTab:Toggle({Name="Auto Black Flash",Default=false,Callback=function(on)
    flashOn=on;flash={last=nil,minimum=math.huge,descending=false,fired=false}
    flashStatus:SetText(on and "Waiting for the Black Flash zoom..." or "Auto Black Flash: OFF")
    if on then window:Toggle(false) end
end})
local kokuTab=window:Tab("Kokushibo")
kokuTab:Section("KokushiboCheck")
local kokuOn=false
local kokuStatus=kokuTab:Label("Auto Kokushibo: OFF")
kokuTab:Label("Unverified cue detection: right-click when eye movement finishes.")
local koku={gui=nil,positions={},moved=false,stable=0,fired=false}
kokuTab:Toggle({Name="Auto Kokushibo",Default=false,Callback=function(on)
    kokuOn=on;koku={gui=nil,positions={},moved=false,stable=0,fired=false}
    kokuStatus:SetText(on and "Waiting for FrenchKokushibo..." or "Auto Kokushibo: OFF")
    if on then window:Toggle(false) end
end})
local function localX(obj)
    local ok,x=pcall(function()return obj.Position.X.Scale end)
    if ok and type(x)=="number" then return x end
    if positionOffset and type(memory_read)=="function" then
        local success,value=pcall(function()return memory_read("float",obj.Address+positionOffset)end)
        if success and type(value)=="number" and value==value then return value end
    end
end
local function updateOtherTimings()
    if not alive then return end
    if flashOn then
        local cam=world.CurrentCamera
        local fov=cam and cam.FieldOfView
        if type(fov)=="number" then
            if fov>=65 then flash={last=fov,minimum=fov,descending=false,fired=false}
            else
                if flash.last and fov<flash.last-.05 then flash.descending=true end
                flash.minimum=math.min(flash.minimum,fov)
                if flash.descending and flash.minimum<=6.5 and flash.last and fov>flash.last+.05 and not flash.fired then
                    if type(mouse1click)=="function" and not window:IsOpen() then
                        mouse1click();flash.fired=true;flashStatus:SetText("Black Flash click sent at zoom return.")
                    end
                end
                flash.last=fov
            end
        end
    end
    if kokuOn then
        local player=players.LocalPlayer
        local pg=player and player:FindFirstChild("PlayerGui")
        local gui=pg and pg:FindFirstChild("FrenchKokushibo")
        if not gui then koku={gui=nil,positions={},moved=false,stable=0,fired=false};return end
        local key=gui.Address or gui
        if key~=koku.gui then koku={gui=key,positions={},moved=false,stable=0,fired=false} end
        if koku.fired then return end
        local changed=false
        local count=0
        for _,eye in ipairs(gui:GetChildren())do
            local x=localX(eye)
            if x then
                count=count+1
                local id=eye.Address or eye
                local previousX=koku.positions[id]
                if previousX and math.abs(x-previousX)>.000001 then changed=true end
                koku.positions[id]=x
            end
        end
        if count==0 then kokuStatus:SetText("Eye positions unavailable in this Matcha build.");return end
        if changed then koku.moved=true;koku.stable=0
        elseif koku.moved then koku.stable=koku.stable+1 end
        if koku.stable>=2 and not window:IsOpen() then
            if type(mouse2click)=="function" then
                mouse2click();koku.fired=true;kokuStatus:SetText("Kokushibo right-click sent after eye movement.")
            else kokuStatus:SetText("This Matcha build has no mouse2click API.") end
        end
    end
end
local function child(parent,name) return parent and parent:FindFirstChild(name) end
local function barsIn(model, results)
    local root=child(model,"HumanoidRootPart")
    if not root then return end
    for _,gui in ipairs(root:GetChildren()) do
        if gui.Name == "NanamiCutGUI" then
            local bar=child(gui,"MainBar")
            local cutter=child(bar,"Cutter")
            if bar and cutter then results[#results+1]={gui=gui,bar=bar,cutter=cutter} end
        end
    end
end
local function locate(character)
    local results={}
    barsIn(character,results)
    local live=child(world,"Live")
    if live then
        for _,model in ipairs(live:GetChildren()) do
            if model ~= character then barsIn(model,results) end
        end
    end
    return results
end
local function update()
    if not enabled or not alive then return end
    if type(mouse1click) ~= "function" then message("This runner has no mouse1click API."); return end
    local player=players.LocalPlayer
    local character=player and player.Character
    -- Some builds do not expose NANAMIAIM; arm only from the local move keys.
    local now=tick and tick() or os.clock()
    if type(iskeypressed)=="function" then
        for key=0x31,0x34 do
            local down=iskeypressed(key)==true
            if down and not lastKeys[key] then armedUntil=now+5 end
            lastKeys[key]=down
        end
    end
    local aiming=character and character:GetAttribute("NANAMIAIM")
    if not character or (not aiming and now>armedUntil) then
        prompts={}; message("Waiting for your Nanami move..."); return
    end
    local candidates=locate(character)
    local seen={}
    local sent=false
    if #candidates == 0 then message("Waiting for the game's ratio bar...") end
    for _,candidate in ipairs(candidates) do
        local gui,bar,cutter=candidate.gui,candidate.bar,candidate.cutter
        local key=gui.Address or gui
        seen[key]=true
        local prompt=prompts[key] or {fired=false}
        prompts[key]=prompt
        local ratio,method=readRatio(bar,cutter)
        if ratio then
            if ratio == ratio and ratio >= -.1 and ratio <= 1.1 then
                -- A reused GUI can contain multiple timing rounds within one move.
                if prompt.last and prompt.last >= .65 and ratio < .3 then prompt.fired=false end
                prompt.last=ratio
                if not prompt.fired then
                    if window:IsOpen() then
                        message("Hide the menu with Right Shift to resume timing.")
                    elseif math.abs(ratio-.7) < .018 and not sent then
                        mouse1click(); prompt.fired=true; sent=true
                        print("[Nanami Timing v3] Click at "..tostring(ratio).." via "..method)
                        message("Timing click sent; watching for the next prompt...")
                    elseif ratio <= .72 then
                        message("Tracking: "..tostring(math.floor(ratio*100+.5)).."%")
                    end
                end
            end
        else
            message("Ratio bar screen coordinates unavailable.")
        end
    end
    for key in pairs(prompts) do if not seen[key] then prompts[key]=nil end end
end
connection=game:GetService("RunService").Heartbeat:Connect(function()
    if not alive then return end
    local ok,err=pcall(update)
    if not ok then
        message("Tracking unavailable; see Matcha output.")
        if tostring(err) ~= lastError then lastError=tostring(err); print("[Nanami Timing] "..lastError) end
    end
    local otherOK,otherError=pcall(updateOtherTimings)
    if not otherOK and tostring(otherError)~=lastError then
        lastError=tostring(otherError);print("[ABA Timings] "..lastError)
    end
end)
print("[Nanami Timing] Loaded. Right Shift shows/hides the menu. Auto Timing defaults to OFF.")
