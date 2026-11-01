-- ABA mode/cooldown ESP. Run as a LocalScript or through a compatible client.
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
local folder=Instance.new("Folder")
folder.Name="ABAStatusESP"
folder.Parent=me:WaitForChild("PlayerGui")
local colors={ready=Color3.fromRGB(100,240,157),cooldown=Color3.fromRGB(255,161,95),unknown=Color3.fromRGB(165,174,194)}
local function label(parent,y,height)
    local t=Instance.new("TextLabel")
    t.BackgroundTransparency=1;t.Position=UDim2.fromOffset(8,y)
    t.Size=UDim2.new(1,-16,0,height);t.Font=Enum.Font.GothamMedium
    t.TextSize=12;t.TextColor3=Color3.fromRGB(235,240,255)
    t.TextXAlignment=Enum.TextXAlignment.Left;t.TextTruncate=Enum.TextTruncate.AtEnd
    t.Parent=parent;return t
end
local function create(player)
    local gui=Instance.new("BillboardGui")
    gui.Name="Status_"..player.UserId;gui.Size=UDim2.fromOffset(254,174)
    gui.StudsOffsetWorldSpace=Vector3.new(0,4.3,0);gui.AlwaysOnTop=true
    gui.MaxDistance=state.MaxDistance;gui.Enabled=false;gui.Parent=folder
    local panel=Instance.new("Frame");panel.Size=UDim2.fromScale(1,1)
    panel.BackgroundColor3=Color3.fromRGB(17,21,33);panel.BackgroundTransparency=.13
    panel.BorderSizePixel=0;panel.Parent=gui
    local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,8);corner.Parent=panel
    local name=label(panel,4,22);name.Text=player.DisplayName.." (@"..player.Name..")"
    local mode=label(panel,27,18)
    local bar=Instance.new("Frame");bar.Position=UDim2.fromOffset(8,48)
    bar.Size=UDim2.new(1,-16,0,5);bar.BorderSizePixel=0
    bar.BackgroundColor3=Color3.fromRGB(57,63,81);bar.Parent=panel
    local fill=Instance.new("Frame");fill.Size=UDim2.fromScale(0,1);fill.BorderSizePixel=0
    fill.BackgroundColor3=Color3.fromRGB(153,116,255);fill.Parent=bar
    local rows={};for i=1,5 do rows[i]=label(panel,57+(i-1)*21,20) end
    records[player]={gui=gui,mode=mode,fill=fill,rows=rows}
    return records[player]
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
        r.fill.Size=UDim2.fromScale(ratio,1)
    elseif value then
        r.mode.Text=string.format("MODE  %g  (maximum unknown)",value)
        r.fill.Size=UDim2.fromScale(0,1)
    else
        r.mode.Text="MODE  unavailable";r.fill.Size=UDim2.fromScale(0,1)
    end
    local slots=movesFor(player,char)
    for i=1,5 do
        local data=slots[i];local row=r.rows[i]
        if not data then row.Text=i.."  unavailable";row.TextColor3=colors.unknown
        elseif type(data.cd)~="number" then
            row.Text=i.."  "..data.name.."  | unknown";row.TextColor3=colors.unknown
        elseif data.cd>=20 then
            row.Text=i.."  "..data.name.."  | READY";row.TextColor3=colors.ready
        else
            row.Text=string.format("%d  %s  | CD %.0f%%",i,data.name,math.clamp(data.cd/20,0,1)*100)
            row.TextColor3=colors.cooldown
        end
    end
end
for _,p in ipairs(Players:GetPlayers()) do create(p) end
table.insert(connections,Players.PlayerAdded:Connect(create))
table.insert(connections,Players.PlayerRemoving:Connect(function(p)
    if records[p] then records[p].gui:Destroy();records[p]=nil end
end))
local elapsed=0
table.insert(connections,RunService.Heartbeat:Connect(function(dt)
    elapsed=elapsed+dt;if elapsed<.1 then return end;elapsed=0
    for player,r in pairs(records) do
        local ok,err=pcall(update,player,r)
        if not ok then
            r.gui.Enabled=false
            if not r.warned then r.warned=true;warn("[ABA ESP] "..tostring(err)) end
        end
    end
end))
table.insert(connections,UIS.InputBegan:Connect(function(input,processed)
    if not processed and input.KeyCode==Enum.KeyCode.F6 then state.Enabled=not state.Enabled end
end))
function state.Destroy()
    for _,c in ipairs(connections) do c:Disconnect() end
    folder:Destroy();table.clear(records)
    if env.ABAStatusESP==state then env.ABAStatusESP=nil end
end
env.ABAStatusESP=state
print("[ABA ESP] Loaded. F6 toggles. Missing replicated data is shown as unavailable.")

