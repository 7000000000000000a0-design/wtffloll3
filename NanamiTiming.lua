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
local window = Nova:CreateWindow({Title="Nanami Timing", Subtitle="Matcha", ToggleKey="RightShift", Open=true, Size={500,350}})
local tab = window:Tab("Nanami")
tab:Section("Ratio timing")
local enabled, alive, clicked = false, true, false
local activeGUI, connection, lastStatus, lastError
local status = tab:Label("Auto Timing: OFF")
local function message(text)
    if text ~= lastStatus then lastStatus=text; status:SetText(text) end
end
tab:Toggle({Name="Auto Timing", Default=false, Callback=function(on)
    enabled=on; activeGUI=nil; clicked=false
    message(on and "Waiting for your Nanami move..." or "Auto Timing: OFF")
end})
tab:Label("Right Shift: show / hide this menu")
tab:Label("Enable the toggle, hide the menu, then use your move.")
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
local function child(parent,name) return parent and parent:FindFirstChild(name) end
local function barIn(model)
    local root=child(model,"HumanoidRootPart")
    if not root then return end
    for _,gui in ipairs(root:GetChildren()) do
        if gui.Name == "NanamiCutGUI" then
            local bar=child(gui,"MainBar")
            local cutter=child(bar,"Cutter")
            if bar and cutter then return gui,bar,cutter end
        end
    end
end
local function locate(character)
    local gui,bar,cutter=barIn(character)
    if gui then return gui,bar,cutter end
    local live=child(world,"Live")
    if live then
        for _,model in ipairs(live:GetChildren()) do
            gui,bar,cutter=barIn(model)
            if gui then return gui,bar,cutter end
        end
    end
end
local function update()
    if not enabled or not alive then return end
    if type(mouse1click) ~= "function" then message("This runner has no mouse1click API."); return end
    local player=players.LocalPlayer
    local character=player and player.Character
    if not character or not character:GetAttribute("NANAMIAIM") then
        activeGUI=nil; clicked=false; message("Waiting for your Nanami move..."); return
    end
    local gui,bar,cutter=locate(character)
    if not gui then message("Waiting for the game's ratio bar..."); return end
    if gui ~= activeGUI then activeGUI=gui; clicked=false end
    if clicked then return end
    local size,pos=bar.AbsoluteSize,bar.AbsolutePosition
    local cutSize,cutPos=cutter.AbsoluteSize,cutter.AbsolutePosition
    if not size or not pos or not cutSize or not cutPos or size.X <= 1 then
        message("Ratio bar screen coordinates unavailable."); return
    end
    local ratio=(cutPos.X+cutSize.X*.5-pos.X)/size.X
    if ratio ~= ratio or ratio < -.1 or ratio > 1.1 then return end
    if window:IsOpen() then message("Press Right Shift to hide the menu before timing."); return end
    if math.abs(ratio-.7) < .02 then
        clicked=true; mouse1click(); message("Timing click sent at "..tostring(math.floor(ratio*100+.5)).."%")
    elseif ratio > .72 then
        message("Window passed; waiting for your next move.")
    else
        message("Tracking: "..tostring(math.floor(ratio*100+.5)).."%")
    end
end
connection=game:GetService("RunService").Heartbeat:Connect(function()
    if not alive then return end
    local ok,err=pcall(update)
    if not ok then
        message("Tracking unavailable; see Matcha output.")
        if tostring(err) ~= lastError then lastError=tostring(err); print("[Nanami Timing] "..lastError) end
    end
end)
print("[Nanami Timing] Loaded. Right Shift shows/hides the menu. Auto Timing defaults to OFF.")
