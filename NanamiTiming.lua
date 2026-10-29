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
    if not character or not character:GetAttribute("NANAMIAIM") then
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
        local size,pos=bar.AbsoluteSize,bar.AbsolutePosition
        local cutSize,cutPos=cutter.AbsoluteSize,cutter.AbsolutePosition
        if size and pos and cutSize and cutPos and size.X > 1 then
            local ratio=(cutPos.X+cutSize.X*.5-pos.X)/size.X
            if ratio == ratio and ratio >= -.1 and ratio <= 1.1 then
                -- A reused GUI can contain multiple timing rounds within one move.
                if prompt.last and prompt.last >= .65 and ratio < .3 then prompt.fired=false end
                prompt.last=ratio
                if not prompt.fired then
                    if window:IsOpen() then
                        message("Hide the menu with Right Shift to resume timing.")
                    elseif math.abs(ratio-.7) < .02 and not sent then
                        mouse1click(); prompt.fired=true; sent=true
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
end)
print("[Nanami Timing] Loaded. Right Shift shows/hides the menu. Auto Timing defaults to OFF.")
