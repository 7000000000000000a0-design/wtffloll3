-- Volt candy quest reroller. F8 starts/stops. Reads reward before rerolling.
local env=(getgenv and getgenv()) or _G
if env.VoltCandyQuests and env.VoltCandyQuests.Destroy then pcall(env.VoltCandyQuests.Destroy) end
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local state={Alive=true,Running=false,Generation=0,MaxAttempts=40}
env.VoltCandyQuests=state
local ui=Instance.new("ScreenGui");ui.Name="VoltCandyQuestStatus";ui.ResetOnSpawn=false;ui.IgnoreGuiInset=true;ui.DisplayOrder=10000;ui.Parent=pg
local frame=Instance.new("Frame");frame.AnchorPoint=Vector2.new(1,0);frame.Position=UDim2.new(1,-16,0,20);frame.Size=UDim2.fromOffset(380,80);frame.BackgroundColor3=Color3.fromRGB(23,25,34);frame.BorderSizePixel=0;frame.Parent=ui
local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,8);corner.Parent=frame
local function label(y,size)
    local l=Instance.new("TextLabel");l.Position=UDim2.fromOffset(12,y);l.Size=UDim2.new(1,-24,0,28);l.BackgroundTransparency=1;l.Font=Enum.Font.GothamMedium;l.TextSize=size;l.TextXAlignment=Enum.TextXAlignment.Left;l.TextColor3=Color3.fromRGB(235,239,245);l.Parent=frame;return l
end
local title=label(5,15);local detail=label(34,12);detail.TextWrapped=true
local function status(text)
    title.Text="Candy Quests: "..(state.Running and "ON" or "OFF").." [F8]"
    title.TextColor3=state.Running and Color3.fromRGB(105,240,160) or Color3.fromRGB(255,170,115)
    detail.Text=text
    print("[Volt Candy] "..text)
end
local function norm(text) return tostring(text or ""):gsub("<[^>]+>",""):gsub("’","'"):lower():gsub("%s+"," "):match("^%s*(.-)%s*$") end
local function visible(o)
    while o and o~=pg do
        if o:IsA("GuiObject") and not o.Visible then return false end
        if o:IsA("ScreenGui") and not o.Enabled then return false end
        o=o.Parent
    end
    return o==pg
end
local function button(text)
    local chat=pg:FindFirstChild("ChatGui")
    local f=chat and chat:FindFirstChild("Frame")
    if not f or not chat.Enabled then return end
    for _,o in ipairs(f:GetChildren()) do
        if o:IsA("TextButton") and visible(o) and norm(o.Text)==text then return o end
    end
end
local function quest()
    for _,o in ipairs(pg:GetDescendants()) do
        if o:IsA("TextLabel") and visible(o) and norm(o.Text)=="the horseman's riddle" then
            local root=o.Parent
            for _=1,4 do
                if not root or root==pg or root:IsA("ScreenGui") then break end
                local reward,public,close
                for _,t in ipairs(root:GetDescendants()) do
                    if (t:IsA("TextLabel") or t:IsA("TextButton")) and visible(t) then
                        local text=norm(t.Text)
                        if text:find("win a public match",1,true) then public=true end
                        local n=text:match("reward%s*:%s*(%d+)")
                        if n then reward=tonumber(n) end
                        if t:IsA("TextButton") and (text=="x" or text=="×") then close=t end
                    elseif t:IsA("ImageButton") and visible(t) and t.Name:lower():find("close",1,true) then close=t end
                end
                if reward then return {reward=reward,target=reward==10 and public==true,close=close} end
                root=root.Parent
            end
        end
    end
end
local function valid(g) return state.Alive and state.Running and state.Generation==g end
local function pause(g,seconds)
    local untilTime=os.clock()+seconds
    repeat if not valid(g) then return false end;task.wait(.05) until os.clock()>=untilTime
    return true
end
local function click(o,g)
    if not valid(g) or not o or not visible(o) then return false end
    status("Activating: "..(o:IsA("TextButton") and o.Text or o.Name))
    -- The saved dialogue code connects TextButton.Activated.
    if type(firesignal)=="function" then
        local ok=pcall(function() firesignal(o.Activated) end)
        if ok then return true end
    end
    local ok,vim=pcall(function() return game:GetService("VirtualInputManager") end)
    if not ok or not vim then error("Volt exposes neither firesignal nor VirtualInputManager") end
    local p,size=o.AbsolutePosition,o.AbsoluteSize
    local x,y=p.X+size.X/2,p.Y+size.Y/2
    local screen=o:FindFirstAncestorOfClass("ScreenGui")
    if screen and not screen.IgnoreGuiInset then
        local inset=game:GetService("GuiService"):GetGuiInset();x=x+inset.X;y=y+inset.Y
    end
    vim:SendMouseMoveEvent(x,y,game)
    if not pause(g,.1) then return false end
    vim:SendMouseButtonEvent(x,y,0,true,game,0)
    task.wait(.05)
    vim:SendMouseButtonEvent(x,y,0,false,game,0)
    return valid(g)
end
local function waitQuest(g,seconds)
    local finish=os.clock()+seconds
    repeat local q=quest();if q then return q end
        if not pause(g,.1) then return end
    until os.clock()>=finish
end
local function stop(text,g)
    if g and state.Generation~=g then return end
    state.Running=false;status(text)
end
local function run(g)
    for attempt=1,state.MaxAttempts do
        if not valid(g) then return end
        local q=quest()
        if q then
            if q.target then stop("FOUND: public match, 10 candy",g);return end
            if not q.close then stop("Close the quest panel, then press F8",g);return end
            if not click(q.close,g) or not pause(g,.6) then return end
        end
        local reroll=button("give me a new riddle")
        if not reroll then stop("Open the Horseman dialogue, then press F8",g);return end
        status("Requesting riddle "..attempt)
        if not click(reroll,g) or not pause(g,1.4) then return end
        q=quest()
        if not q then
            local show=button("what's my riddle?")
            if not show then stop("Reopen dialogue and press F8 to inspect quest",g);return end
            if not click(show,g) then return end
            q=waitQuest(g,4)
        end
        if not valid(g) then return end
        if not q then stop("No readable reward panel; stopped safely",g);return end
        if q.target then stop("FOUND: public match, 10 candy",g);return end
        status("Reward "..q.reward.."; continuing")
        if not pause(g,.8) then return end
    end
    stop("40 attempts reached; press F8 to continue",g)
end
local connection
function state.Destroy()
    state.Alive=false;state.Running=false;state.Generation=state.Generation+1
    if connection then connection:Disconnect() end
    ui:Destroy()
    if env.VoltCandyQuests==state then env.VoltCandyQuests=nil end
end
connection=UIS.InputBegan:Connect(function(input,processed)
    if processed or input.KeyCode~=Enum.KeyCode.F8 then return end
    state.Generation=state.Generation+1
    state.Running=not state.Running
    local g=state.Generation
    status(state.Running and "Starting..." or "Stopped by F8")
    if state.Running then task.spawn(function()
        local ok,err=pcall(run,g)
        if not ok then stop("Error: "..tostring(err),g) end
    end) end
end)
status("Ready: open Horseman dialogue; press F8")

