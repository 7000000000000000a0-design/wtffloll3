--[[
    Anime Battle Arena - Head Ride 

    gotta use or own settings 
depends on ping and  what not
]]

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ===========================================================================
-- helpers
-- ===========================================================================
local function safe(fn, fallback)
    local ok, res = pcall(fn)
    if ok then return res end
    return fallback
end

-- UI.GetValue is nil until the tab renders its first frame
local function gv(id, default)
    local ok, v = pcall(UI.GetValue, id)
    if ok and v ~= nil then return v end
    return default
end

local function charOf(plr)
    return safe(function() return plr.Character end, nil)
end

local function partOf(model, name)
    if not model then return nil end
    return safe(function() return model:FindFirstChild(name) end, nil)
end

local function rootOf(model)
    if not model then return nil end
    return safe(function()
        return model:FindFirstChild("HumanoidRootPart")
            or model:FindFirstChild("UpperTorso")
            or model:FindFirstChild("Torso")
    end, nil)
end

local function humOf(model)
    if not model then return nil end
    return safe(function() return model:FindFirstChildOfClass("Humanoid") end, nil)
        or safe(function() return model:FindFirstChild("Humanoid") end, nil)
end

local function myRoot()  return rootOf(charOf(LocalPlayer)) end
local function myPos()
    local r = myRoot()
    if not r then return nil end
    return safe(function() return r.Position end, nil)
end

-- Velocity is a documented BasePart property; AssemblyLinearVelocity is too.
local function velOf(part)
    local v = safe(function() return part.AssemblyLinearVelocity end, nil)
    if v then return v end
    return safe(function() return part.Velocity end, nil) or Vector3.zero
end

local function isAlive(plr)
    local hum = humOf(charOf(plr))
    if not hum then return false end
    local hp = safe(function() return hum.Health end, 0) or 0
    return hp > 0
end

local function sameTeam(plr)
    local a = safe(function() return LocalPlayer.Team end, nil)
    local b = safe(function() return plr.Team end, nil)
    if a == nil or b == nil then return false end
    return a == b
end

-- ===========================================================================
-- state
-- ===========================================================================
local targets      = {}     -- refreshed by a polling loop
local currentTarget = nil
local rideKb       = nil    -- keybind widget, captured during render
local lockedTarget = nil
local lastStatus   = "idle"
local stepCount    = 0
local stepRate     = 0

-- ===========================================================================
-- target list (polled - cheap, and avoids leaning on join/leave events)
-- ===========================================================================
task.spawn(function()
    while true do
        local list = {}
        for _, plr in ipairs(safe(function() return Players:GetPlayers() end, {}) or {}) do
            if plr ~= LocalPlayer then
                list[#list + 1] = plr
            end
        end
        targets = list
        wait(0.25)
    end
end)

-- ===========================================================================
-- target selection
-- ===========================================================================
local function screenDistToCentre(pos)
    local screen, onScreen = WorldToScreen(pos)
    if not onScreen then return nil end
    local cam  = safe(function() return workspace.CurrentCamera end, nil)
    local vps  = cam and safe(function() return cam.ViewportSize end, nil)
    if not vps then return nil end
    local dx = screen.X - (vps.X / 2)
    local dy = screen.Y - (vps.Y / 2)
    return math.sqrt((dx * dx) + (dy * dy))
end

local function pickTarget()
    local origin = myPos()
    if not origin then return nil end

    local maxDist   = tonumber(gv("ride_range", 150)) or 150
    local teamCheck = gv("ride_team", false)
    local mode      = tonumber(gv("ride_target", 0)) or 0   -- 0 = nearest, 1 = crosshair

    local best, bestScore = nil, nil

    for _, plr in ipairs(targets) do
        if isAlive(plr) and not (teamCheck and sameTeam(plr)) then
            local root = rootOf(charOf(plr))
            local pos  = root and safe(function() return root.Position end, nil)
            if pos then
                local dist = (pos - origin).Magnitude
                if dist <= maxDist then
                    local score
                    if mode == 1 then
                        score = screenDistToCentre(pos)      -- nil when off screen
                    else
                        score = dist
                    end
                    if score and (not bestScore or score < bestScore) then
                        best, bestScore = plr, score
                    end
                end
            end
        end
    end

    return best
end

local function targetValid(plr)
    if not plr then return false end
    if not isAlive(plr) then return false end
    local origin = myPos()
    local root   = rootOf(charOf(plr))
    local pos    = root and safe(function() return root.Position end, nil)
    if not origin or not pos then return false end
    local maxDist = tonumber(gv("ride_range", 150)) or 150
    return (pos - origin).Magnitude <= maxDist * 1.25
end

-- ===========================================================================
-- keybind gate
-- ===========================================================================
local function keybindActive()
    if not rideKb then return true end
    local name = safe(function() return rideKb:GetKeyName() end, "none")
    if name == "none" or name == nil then return true end   -- unbound = always on
    local ok, v = pcall(function() return rideKb:IsEnabled() end)
    if not ok or v == nil then return true end
    return v and true or false
end

local function rideEnabled()
    return gv("ride_on", false) and keybindActive()
end

-- ===========================================================================
-- the ride
-- ===========================================================================
local function goalPosition(targetPlr)
    local char = charOf(targetPlr)
    local head = partOf(char, "Head")
    local root = rootOf(char)
    local anchor = head or root
    if not anchor then return nil end

    local pos = safe(function() return anchor.Position end, nil)
    if not pos then return nil end

    -- sit above the head, not inside it
    local height = tonumber(gv("ride_height", 4.0)) or 4.0
    if not head and root then
        height = height + 1.5          -- root sits lower than the head
    end

    local goal = pos + Vector3.new(0, height, 0)

    -- lead a moving target
    local pred = (tonumber(gv("ride_pred", 0.08)) or 0.08)
    if pred > 0 then
        goal = goal + (velOf(anchor) * pred)
    end

    return goal
end

-- where the correction runs: 0 Heartbeat, 1 RenderStepped, 2 dedicated loop
local function updateSource()
    return tonumber(gv("ride_tick", 2)) or 2
end

local lastStep = nil

local function rideStep()
    local now = safe(function() return tick() end, nil)
    local dt  = (lastStep and now) and (now - lastStep) or 0.016
    lastStep  = now
    -- a long gap (alt-tab, lag spike) must not turn into one huge step
    dt = math.clamp(dt, 0.001, 0.1)

    if not rideEnabled() then
        currentTarget = nil
        lastStatus = "idle"
        return
    end

    stepCount = stepCount + 1

    -- keep the locked target while it is still valid
    if gv("ride_lock", true) and targetValid(lockedTarget) then
        currentTarget = lockedTarget
    else
        currentTarget = pickTarget()
        lockedTarget  = currentTarget
    end

    if not currentTarget then
        lastStatus = "no target"
        return
    end

    local me = myRoot()
    if not me then
        lastStatus = "no character"
        return
    end

    local goal = goalPosition(currentTarget)
    if not goal then
        lastStatus = "target has no head"
        return
    end

    local here = safe(function() return me.Position end, nil)
    if not here then
        lastStatus = "cannot read position"
        return
    end

    local mode = tonumber(gv("ride_mode", 0)) or 0   -- 0 = position, 1 = velocity

    local delta   = goal - here
    local dist    = delta.Magnitude
    local climb   = tonumber(gv("ride_climb", 45)) or 45   -- studs/s, 0 = instant
    local arrived = dist <= 1.0

    if mode == 0 then
        local dest
        if climb > 0 and not arrived then
            -- travel at a fixed speed, so the approach reads as a climb
            local maxStep = climb * dt
            if dist > maxStep then
                dest = here + (delta.Unit * maxStep)
            else
                dest = goal
            end
        else
            dest = goal
        end
        if pcall(function() me.Position = dest end) then
            lastStatus = arrived and "riding (position)" or "climbing"
        else
            lastStatus = "position write failed"
        end
    else
        local gain = tonumber(gv("ride_gain", 12)) or 12
        local want = delta * gain
        if climb > 0 and want.Magnitude > climb then
            want = want.Unit * climb
        end
        local ok = pcall(function() me.AssemblyLinearVelocity = want end)
        if not ok then
            ok = pcall(function() me.Velocity = want end)
        end
        if ok then
            lastStatus = arrived and "riding (velocity)" or "climbing"
        else
            lastStatus = "velocity write failed"
        end
    end
end

RunService.Heartbeat:Connect(function()
    if updateSource() == 0 then rideStep() end
end)

RunService.RenderStepped:Connect(function()
    if updateSource() == 1 then rideStep() end
end)

-- dedicated loop, so the correction rate is not capped by your frame rate
task.spawn(function()
    while true do
        if updateSource() == 2 then
            rideStep()
            local hz = math.clamp(tonumber(gv("ride_hz", 200)) or 200, 30, 1000)
            wait(1 / hz)
        else
            wait(0.1)
        end
    end
end)

-- sample the achieved rate once a second so the menu can show it
task.spawn(function()
    while true do
        wait(1)
        stepRate  = stepCount
        stepCount = 0
    end
end)

-- ===========================================================================
-- target indicator
-- ===========================================================================
local circle, label, line

local function makeDrawings()
    if circle then return end
    circle = safe(function() return Drawing.new("Circle") end, nil)
    label  = safe(function() return Drawing.new("Text") end, nil)
    line   = safe(function() return Drawing.new("Line") end, nil)
    pcall(function()
        circle.Thickness = 2
        circle.NumSides  = 24
        circle.Radius    = 14
        circle.Visible   = false
        label.Center     = true
        label.Outline    = true
        label.FontSize   = 13
        label.Visible    = false
        line.Thickness   = 1
        line.Visible     = false
    end)
end

local function hideDrawings()
    pcall(function()
        if circle then circle.Visible = false end
        if label  then label.Visible  = false end
        if line   then line.Visible   = false end
    end)
end

local function indicatorColour()
    local v = gv("ride_colour", nil)
    if typeof and typeof(v) == "Color3" then return v end
    if type(v) == "table" then
        local r = v.r or v[1] or 120
        local g = v.g or v[2] or 220
        local b = v.b or v[3] or 255
        if r > 1 or g > 1 or b > 1 then return Color3.fromRGB(r, g, b) end
        return Color3.new(r, g, b)
    end
    return Color3.fromRGB(120, 220, 255)
end

RunService.RenderStepped:Connect(function()
    if not gv("ride_marker", true) or not currentTarget then
        hideDrawings()
        return
    end

    makeDrawings()
    if not circle or not label or not line then return end

    local char = charOf(currentTarget)
    local head = partOf(char, "Head") or rootOf(char)
    local pos  = head and safe(function() return head.Position end, nil)
    if not pos then
        hideDrawings()
        return
    end

    local screen, onScreen = WorldToScreen(pos)
    if not onScreen then
        hideDrawings()
        return
    end

    local col    = indicatorColour()
    local origin = myPos()
    local dist   = origin and (pos - origin).Magnitude or 0

    pcall(function()
        circle.Color    = col
        circle.Position = Vector2.new(screen.X, screen.Y)
        circle.Visible  = true

        label.Color     = col
        label.Text      = safe(function() return currentTarget.Name end, "?")
            .. "  " .. math.floor(dist) .. "m"
        label.Position  = Vector2.new(screen.X, screen.Y - 30)
        label.Visible   = true
    end)

    if gv("ride_tracer", false) then
        local cam = safe(function() return workspace.CurrentCamera end, nil)
        local vps = cam and safe(function() return cam.ViewportSize end, nil)
        if vps then
            pcall(function()
                line.Color   = col
                line.From    = Vector2.new(vps.X / 2, vps.Y)
                line.To      = Vector2.new(screen.X, screen.Y)
                line.Visible = true
            end)
        end
    else
        pcall(function() line.Visible = false end)
    end
end)

-- ===========================================================================
-- UI
-- ===========================================================================
UI.AddTab("ABA", function(tab)
    local ride = tab:Section("Head Ride", "Left")
    ride:Toggle("ride_on", "Enabled", false)
    rideKb = ride:Keybind("ride_kb", 0x39, "hold")   -- 0x39 = the 9 key
    ride:Tip("Hold 9. Leave the key unbound to run it constantly.")
    ride:SliderFloat("ride_height", "Height above head", 0.0, 12.0, 4.0, "%.1f")
    ride:SliderFloat("ride_pred", "Prediction (s)", 0.0, 0.5, 0.08, "%.2f")
    ride:SliderInt("ride_range", "Max range", 10, 500, 150)
    ride:Combo("ride_mode", "Move by", { "Set position", "Velocity" }, 0)
    ride:SliderFloat("ride_climb", "Rise speed (studs/s)", 0.0, 300.0, 45.0, "%.0f")
    ride:Tip("How fast you travel up onto them. 0 teleports instantly.")
    ride:SliderFloat("ride_gain", "Velocity gain", 1.0, 40.0, 12.0, "%.1f")
    ride:Tip("Velocity mode only. Rise speed still caps the result.")
    ride:Spacing()
    ride:Combo("ride_tick", "Update on", { "Heartbeat", "RenderStepped", "Fast loop" }, 2)
    ride:SliderInt("ride_hz", "Fast loop rate (per second)", 30, 1000, 200)
    ride:Tip("Fast loop ignores your frame rate. Raise it if you slide off, lower it if the game rubber-bands you.")

    local tgt = tab:Section("Target", "Left")
    tgt:Combo("ride_target", "Pick by", { "Nearest", "Closest to crosshair" }, 0)
    tgt:Toggle("ride_lock", "Stay on one target", true)
    tgt:Toggle("ride_team", "Ignore teammates", false)
    tgt:Button("Drop target", function()
        lockedTarget  = nil
        currentTarget = nil
    end)

    local vis = tab:Section("Indicator", "Right")
    vis:Toggle("ride_marker", "Show target marker", true)
    vis:ColorPicker("ride_colour", 120, 220, 255, 255)
    vis:Toggle("ride_tracer", "Tracer line", false)

    local misc = tab:Section("Misc", "Right")
    misc:Text("Status : " .. lastStatus)
    misc:Text("Updates: " .. stepRate .. "/s")
    misc:Text("Target : " .. (currentTarget and safe(function() return currentTarget.Name end, "?") or "none"))
    misc:Text("Players: " .. #targets)
    misc:Text("Ping   : " .. tostring(safe(function() return GetPingValue() end, "?")) .. " ms")
    misc:Spacing()
    misc:Button("Test movement write", function()
        -- yielding inside the render callback would stall the UI, so spawn it
        task.spawn(function()
            local r = myRoot()
            if not r then
                notify("No character found", "Head Ride", 3)
                return
            end
            local before = safe(function() return r.Position end, nil)
            if not before then
                notify("Cannot read Position at all", "Head Ride", 4)
                return
            end
            pcall(function() r.Position = before + Vector3.new(0, 6, 0) end)
            wait(0.2)
            local after = safe(function() return r.Position end, nil)
            if not after then
                notify("Could not read position back", "Head Ride", 4)
                return
            end
            local moved = (after - before).Magnitude
            if moved > 1.5 then
                notify(string.format("Position writes work (moved %.1f studs)", moved),
                    "Head Ride", 5)
            else
                notify("Position write did nothing - switch Move by to Velocity",
                    "Head Ride", 6)
            end
        end)
    end)
    misc:Button("Reset", function()
        pcall(UI.SetValue, "ride_on", false)
        lockedTarget  = nil
        currentTarget = nil
        hideDrawings()
        notify("Head ride off", "ABA", 3)
    end)
end)

-- ===========================================================================
notify("ABA head ride loaded - run the movement test first", "ABA", 6)
print("[aba] head ride loaded on " .. tostring(safe(function() return getgamename() end, "?")))