-- ABA mode/cooldown ESP for Matcha: Drawing API, no Instance.new.
-- Reads replicated data only. Hidden opponent backpacks cannot be recovered here.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local me=Players.LocalPlayer
local env=(getgenv and getgenv()) or _G
if env.ABAStatusESP then pcall(env.ABAStatusESP.Destroy) end
local state={Enabled=true,ShowSelf=false,MaxDistance=1500}
-- Set exact field names and ModeMax after confirming the live game's meter schema.
state.ModeFields={"ModeCharge","ModeMeter","AwakeningCharge","UltimateCharge","Mode","Ultimate"}
state.ModeMax=nil -- Never assume a raw number is a percentage.
local records,connections={},{}
assert(Drawing and type(Drawing.new)=="function","Matcha Drawing API is required")
local colors={ready=Color3.fromRGB(100,240,157),cooldown=Color3.fromRGB(255,161,95),unknown=Color3.fromRGB(165,174,194)}
local function draw(kind,props)
    local d=Drawing.new(kind)
    for k,v in pairs(props) do pcall(function() d[k]=v end) end
    return d
end
local function playerTitle(player)
    local okName,name=pcall(function() return player.Name end)
    local okDisplay,display=pcall(function() return player.DisplayName end)
    name=(okName and type(name)=="string" and name~="" and name) or "Player"
    display=(okDisplay and type(display)=="string" and display~="" and display) or name
    if display==name then return name end
    return display.." (@"..name..")"
end
local function create(player)
    local r={rows={},objects={},gui={Enabled=false}}
    local function add(kind,props)
        props.Visible=false
        local d=draw(kind,props);table.insert(r.objects,d);return d
    end
    r.panel=add("Square",{Filled=true,Color=Color3.fromRGB(17,21,33),Transparency=.87,ZIndex=20})
    r.bar=add("Square",{Filled=true,Color=Color3.fromRGB(57,63,81),ZIndex=21})
    r.fill=add("Square",{Filled=true,Color=Color3.fromRGB(153,116,255),ZIndex=22})
    local function text()
        return add("Text",{Size=13,Font=2,Color=Color3.fromRGB(235,240,255),Outline=true,ZIndex=23})
    end
    r.name=text();r.name.Text=playerTitle(player)
    r.mode=text()
    for i=1,5 do r.rows[i]=text() end
    function r.gui:Destroy()
        for _,d in ipairs(r.objects) do pcall(function() d:Remove() end) end
    end
    records[player]=r;return r
end
local function setText(row,text,color)
    row.Text=text;row.Color=color
end
local function hide(r)
    for _,d in ipairs(r.objects) do d.Visible=false end
end
local function render(r)
    if not r.gui.Enabled then hide(r);return end
    local cam=workspace.CurrentCamera
    if not cam or not r.gui.Adornee then hide(r);return end
    local world=r.gui.Adornee.Position+Vector3.new(0,3,0)
    local ok,p,onScreen=pcall(function() return cam:WorldToViewportPoint(world) end)
    if not ok then
        ok,p,onScreen=pcall(function() return cam:WorldToScreenPoint(world) end)
    end
    if not ok or not p then
        hide(r)
        if not r.projectionWarning then r.projectionWarning=true;warn("[ABA ESP] Camera projection is unavailable in this client.") end
        return
    end
    if onScreen==false or (p.Z and p.Z<=0) then hide(r);return end
    local distance=(cam.CFrame.Position-r.gui.Adornee.Position).Magnitude
    if distance>state.MaxDistance then hide(r);return end
    local x,y=math.floor(p.X-127),math.floor(p.Y-174)
    r.panel.Position=Vector2.new(x,y);r.panel.Size=Vector2.new(254,174)
    r.name.Position=Vector2.new(x+8,y+5);r.mode.Position=Vector2.new(x+8,y+28)
    r.bar.Position=Vector2.new(x+8,y+48);r.bar.Size=Vector2.new(238,5)
    r.fill.Position=r.bar.Position;r.fill.Size=Vector2.new(math.max(1,238*(r.ratio or 0)),5)
    for i,row in ipairs(r.rows) do row.Position=Vector2.new(x+8,y+57+(i-1)*21) end
    for _,d in ipairs(r.objects) do d.Visible=true end
    r.fill.Visible=(r.ratio or 0)>0
end
local function readNumber(root,key)
    if not root then return end
    local a=root:GetAttribute(key)
    if type(a)=="number" then return a end
    local child=root:FindFirstChild(key)
    if child and (child:IsA("NumberValue") or child:IsA("IntValue")) then return child.Value,child end
end
local function modeValue(player,char)
    local roots={char,char and char:FindFirstChild("Stats"),player,player:FindFirstChild("Stats")}
    for i=1,4 do
        local root=roots[i]
        if root then
            for _,key in ipairs(state.ModeFields) do
                local value,obj=readNumber(root,key)
                if value then
                    local maximum=state.ModeMax or readNumber(root,key.."Max") or readNumber(root,"Max"..key)
                    if not maximum and obj then maximum=obj:GetAttribute("Max") or obj:GetAttribute("MaxValue") end
                    if type(maximum)~="number" or maximum<=0 then maximum=nil end
                    return value,maximum,key
                end
            end
        end
    end
end
local function movesFor(player,char)
    local slots,unslotted={},{}
    local roots={player:FindFirstChild("Backpack"),char}
    local seen={}
    for i=1,2 do
        local root=roots[i]
        if root then
            for _,move in ipairs(root:GetChildren()) do
                local config=move:FindFirstChild(".Config")
                if config and (move:IsA("Configuration") or move:IsA("Tool")) and not seen[move.Name] then
                    seen[move.Name]=true
                    local data={name=move.Name,cd=move:GetAttribute("COOLDOWN")}
                    local renamed=config:FindFirstChild("NewName")
                    if renamed and renamed:IsA("StringValue") and renamed.Value~="" then data.name=renamed.Value end
                    local assigned=false
                    for n=1,5 do
                        if config:FindFirstChild("Slot"..n) then slots[n]=data;assigned=true;break end
                    end
                    if not assigned then table.insert(unslotted,data) end
                end
            end
        end
    end
    table.sort(unslotted,function(a,b)return a.name<b.name end)
    for _,data in ipairs(unslotted) do for n=1,5 do if not slots[n] then slots[n]=data;break end end end
    return slots
end
local function update(player,r)
    local char=player.Character
    local head=char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
    local hum=char and char:FindFirstChildOfClass("Humanoid")
    r.gui.Enabled=state.Enabled and (state.ShowSelf or player~=me) and head~=nil and (not hum or hum.Health>0)
    r.gui.Adornee=head;r.gui.MaxDistance=state.MaxDistance
    if not r.gui.Enabled then return end
    local value,maximum,key=modeValue(player,char)
    if value and maximum then
        local ratio=math.clamp(value/maximum,0,1)
        r.mode.Text=string.format("MODE  %.0f%%",ratio*100)
        r.ratio=ratio
    elseif value then
        r.mode.Text=string.format("MODE  %g  (maximum unknown)",value)
        r.ratio=0
    else
        r.mode.Text="MODE  unavailable";r.ratio=0
    end
    local slots=movesFor(player,char)
    for i=1,5 do
        local data=slots[i];local row=r.rows[i]
        if not data then row.Text=i.."  unavailable";row.Color=colors.unknown
        elseif type(data.cd)~="number" then
            row.Text=i.."  "..data.name.."  | unknown";row.Color=colors.unknown
        elseif data.cd>=20 then
            row.Text=i.."  "..data.name.."  | READY";row.Color=colors.ready
        else
            row.Text=string.format("%d  %s  | CD %.0f%%",i,data.name,math.clamp(data.cd/20,0,1)*100)
            row.Color=colors.cooldown
        end
    end
end
local lastScan=-math.huge
local lastFrame=-math.huge
local f6Down=false
local running=true
local function step()
    if not running then return end
    local now=os.clock()
    if now-lastFrame<.05 then return end
    lastFrame=now
    if now-lastScan>=1 then
        lastScan=now
        local present={}
        for _,player in ipairs(Players:GetPlayers()) do
            present[player]=true
            if not records[player] then create(player) end
        end
        for player,r in pairs(records) do
            if not present[player] then r.gui:Destroy();records[player]=nil end
        end
    end
    local down=false
    if type(iskeypressed)=="function" then
        local ok,value=pcall(iskeypressed,0x75) -- F6 virtual-key code
        down=ok and value==true
    else
        local ok,value=pcall(function() return UIS:IsKeyDown(Enum.KeyCode.F6) end)
        down=ok and value==true
    end
    if down and not f6Down then state.Enabled=not state.Enabled end
    f6Down=down
    for player,r in pairs(records) do
        local ok,err=pcall(function() update(player,r);render(r) end)
        if not ok then
            r.gui.Enabled=false;hide(r)
            if not r.warned then r.warned=true;warn("[ABA ESP] "..tostring(err)) end
        end
    end
end
local ok,connection=pcall(function()
    return RunService.Heartbeat:Connect(function()
        local success,err=pcall(step)
        if not success and state.LastError~=tostring(err) then
            state.LastError=tostring(err);warn("[ABA ESP] "..state.LastError)
        end
    end)
end)
if ok and connection then
    table.insert(connections,connection)
elseif task and type(task.spawn)=="function" and type(task.wait)=="function" then
    task.spawn(function()
        while running do
            local success,err=pcall(step)
            if not success and state.LastError~=tostring(err) then
                state.LastError=tostring(err);warn("[ABA ESP] "..state.LastError)
            end
            task.wait(.05)
        end
    end)
else
    error("ABA ESP requires Heartbeat or task.spawn/task.wait")
end
function state.Destroy()
    running=false
    for _,c in ipairs(connections) do c:Disconnect() end
    for _,r in pairs(records) do r.gui:Destroy() end
    table.clear(records)
    if env.ABAStatusESP==state then env.ABAStatusESP=nil end
end
env.ABAStatusESP=state
print("[ABA ESP] Loaded. F6 toggles. Missing replicated data is shown as unavailable.")

