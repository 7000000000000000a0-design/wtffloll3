-- Matcha candy quest reroller. Open the Horseman dialogue before starting.
-- F8 starts/stops. Automatically stops on the 10-candy public-match quest.
local env=(getgenv and getgenv()) or _G
if env.CandyQuestReroll then
    if env.CandyQuestReroll.Destroy then pcall(env.CandyQuestReroll.Destroy)
    else env.CandyQuestReroll.Running=false end
end
local state={Running=false,MaxAttempts=40,OffsetX=0,OffsetY=0,Alive=true,Generation=0}
local activeGeneration=0
local setEnabled
env.CandyQuestReroll=state
assert(task and task.spawn and task.wait,"task APIs are required")
assert(type(iskeypressed)=="function","Matcha iskeypressed is required for F8")
local player=game:GetService("Players").LocalPlayer
local noticeObjects={}
local status="Ready: open dialogue, then press F8"
local function log(s)
    status=tostring(s)
    print("[Candy Quests] "..status)
end
local function makeNotice(kind,props)
    if not Drawing or type(Drawing.new)~="function" then return end
    local d=Drawing.new(kind)
    table.insert(noticeObjects,d)
    for k,v in pairs(props) do pcall(function() d[k]=v end) end
    return d
end
local bg=makeNotice("Square",{Filled=true,Color=Color3.fromRGB(20,23,32),Transparency=.93,ZIndex=2000,Visible=true})
local title=makeNotice("Text",{Size=16,Font=2,Outline=true,ZIndex=2001,Visible=true})
local detail=makeNotice("Text",{Size=13,Font=2,Outline=true,Color=Color3.fromRGB(235,235,240),ZIndex=2001,Visible=true})
local function updateNotice()
    if not bg or not title or not detail then return end
    local cam=workspace.CurrentCamera
    local size=cam and cam.ViewportSize
    local width=size and size.X or 1280
    local x=math.max(8,width-386)
    bg.Position=Vector2.new(x,20);bg.Size=Vector2.new(370,76)
    title.Position=Vector2.new(x+12,29)
    title.Text="Candy Quests: "..(state.Running and "ON" or "OFF").."  [F8]"
    title.Color=state.Running and Color3.fromRGB(100,240,157) or Color3.fromRGB(255,160,110)
    detail.Position=Vector2.new(x+12,54)
    local msg=status
    if #msg>49 then msg=msg:sub(1,46).."..." end
    detail.Text=msg
end
local function keyDown()
    local ok,value=pcall(iskeypressed,0x77)
    if ok and value==true then return true end
    ok,value=pcall(iskeypressed,"F8")
    return ok and value==true
end
local function normalize(s) return tostring(s or ""):lower():gsub("’","'"):gsub("<[^>]+>",""):gsub("%s+"," "):gsub("^%s+",""):gsub("%s+$","") end
local function stopped()
    return not state.Alive or not state.Running or activeGeneration~=state.Generation
end
local function pause(seconds)
    local untilTime=os.clock()+seconds
    repeat if stopped() then return false end;task.wait(.05) until os.clock()>=untilTime
    return true
end
local function visible(o)
    local current=o
    local depth=0
    while current and depth<32 do
        depth=depth+1
        local ok,v=pcall(function() return current.Visible end)
        if ok and v==false then return false end
        local success,isScreen=pcall(function() return current:IsA("ScreenGui") end)
        if success and isScreen then
            local read,enabled=pcall(function() return current.Enabled end)
            if read and enabled==false then return false end
        end
        local okParent,parent=pcall(function() return current.Parent end)
        current=okParent and parent or nil
    end
    return true
end
local function gui() return player:FindFirstChild("PlayerGui") end
-- Read a small part of the GUI tree per heartbeat; never block on GetDescendants.
local scan={queue={},index=1,texts={},nextReset=0,visited=0}
local function refreshScan()
    local now=tick and tick() or os.clock()
    if scan.index>#scan.queue then
        if now<scan.nextReset then return end
        local root=gui()
        scan.queue=root and {root} or {};scan.index=1;scan.texts={};scan.visited=0
        scan.nextReset=math.huge
    end
    for _=1,15 do
        local o=scan.queue[scan.index]
        if not o then break end
        scan.index=scan.index+1;scan.visited=scan.visited+1
        local ok,text=pcall(function() return o.Text end)
        if ok and type(text)=="string" and text~="" then table.insert(scan.texts,o) end
        local success,children=pcall(function() return o:GetChildren() end)
        if success and children then
            for _,child in ipairs(children) do
                if #scan.queue<6000 then table.insert(scan.queue,child) end
            end
        end
    end
    if scan.index>#scan.queue then scan.nextReset=now+2 end
end
local function textObjects(root)
    local result={}
    for _,o in ipairs(scan.texts) do
        local belongs=root==gui()
        if not belongs then
            local current=o
            for _=1,16 do
                if current==root then belongs=true;break end
                if not current then break end
                current=current.Parent
            end
        end
        if belongs and visible(o) then table.insert(result,o) end
    end
    return result
end
local function dialogueButton(phrase)
    local pg=gui()
    local chat=pg and pg:FindFirstChild("ChatGui")
    local frame=chat and chat:FindFirstChild("Frame")
    if not frame then return end
    local ok,enabled=pcall(function() return chat.Enabled end)
    if ok and enabled==false then return end
    for _,button in ipairs(frame:GetChildren()) do
        local read,text=pcall(function() return button.Text end)
        local shown,isVisible=pcall(function() return button.Visible end)
        if read and type(text)=="string" and normalize(text)==phrase and (not shown or isVisible~=false) then
            local pos,size=button.AbsolutePosition,button.AbsoluteSize
            if pos and size and size.X>0 and size.Y>0 then return button end
        end
    end
end
local function findText(phrase)
    local direct=dialogueButton(phrase)
    if direct then return direct end
    for _,o in ipairs(textObjects(gui())) do
        if normalize(o.Text)==phrase then return o end
    end
end
local function click(o)
    if stopped() or not o or not visible(o) then return false end
    if type(isrbxactive)=="function" and not isrbxactive() then
        log("Paused: focus Roblox to continue.")
        repeat if not pause(.2) then return false end until isrbxactive()
    end
    local pos,size=o.AbsolutePosition,o.AbsoluteSize
    if not pos or not size or size.X<=0 or size.Y<=0 then error("Cannot read button coordinates") end
    log("Clicking: "..tostring(o.Text or o.Name or "button"))
    mousemoveabs(math.floor(pos.X+size.X/2+state.OffsetX),math.floor(pos.Y+size.Y/2+state.OffsetY))
    if not pause(.15) then return false end
    mouse1click();return true
end
local function panel()
    local title=findText("the horseman's riddle")
    if not title then return end
    -- Locate the nearest container containing the title, objective and reward together.
    local root=title.Parent
    for _=1,5 do
        if not root then return end
        local texts=textObjects(root)
        local reward,objective
        for _,o in ipairs(texts) do
            local t=normalize(o.Text):gsub("<[^>]+>","")
            if t:find("reward",1,true) then reward=t end
            if t:find("win a public match",1,true) then objective=t end
        end
        if reward then
            local amount=tonumber(reward:match("reward%s*:%s*(%d+)"))
            return {root=root,target=objective~=nil and amount==10,reward=amount,objective=objective}
        end
        root=root.Parent
    end
end
local function waitPanel(seconds)
    local finish=os.clock()+seconds
    repeat
        local p=panel();if p then return p end
        if not pause(.1) then return end
    until os.clock()>=finish
end
local function closePanel(p)
    for _,o in ipairs(textObjects(p.root)) do
        if normalize(o.Text)=="x" then
            if not click(o) then return false end
            return pause(.5) and panel()==nil
        end
    end
    return false
end
local phase="idle"
local deadline=0
local pending=nil
local afterClick=nil
local attempts=0
local connection
local lastKey=false
local lastStep=0
setEnabled=function(on)
    on=on==true and state.Alive
    state.Running=on
    pending=nil
    phase=on and "inspect" or "idle"
    deadline=0
    if on then attempts=0;log("Looking for quest/dialogue...") end
end
local function finish(message)
    setEnabled(false);log(message)
end
local function queueClick(object,nextPhase,delay)
    if not object or not visible(object) then return false end
    if type(mousemoveabs)~="function" or type(mouse1click)~="function" then
        finish("Missing mousemoveabs or mouse1click");return false
    end
    local pos,size=object.AbsolutePosition,object.AbsoluteSize
    if not pos or not size or size.X<=0 or size.Y<=0 then
        finish("Button coordinates unavailable");return false
    end
    mousemoveabs(math.floor(pos.X+size.X/2+state.OffsetX),math.floor(pos.Y+size.Y/2+state.OffsetY))
    pending=object;afterClick=nextPhase;state.AfterDelay=delay or 1
    phase="click";deadline=(tick and tick() or os.clock())+.2
    log("Moving to: "..tostring(object.Text or object.Name))
    return true
end
local function closeQuest(p,nextPhase)
    for _,o in ipairs(textObjects(p.root)) do
        if normalize(o.Text)=="x" then return queueClick(o,nextPhase,.6) end
    end
    finish("Quest close button unreadable");return false
end
local function update()
    if not state.Running then return end
    local now=tick and tick() or os.clock()
    if now<deadline then return end
    if phase=="click" then
        if pending and visible(pending) then
            mouse1click()
            log("Clicked: "..tostring(pending.Text or pending.Name))
            pending=nil;phase=afterClick;deadline=now+state.AfterDelay
        else finish("Button closed before click") end
        return
    end
    if phase=="inspect" then
        local direct=dialogueButton("give me a new riddle")
        if direct then
            -- First inspect an already displayed quest if its data has been read.
            local existing=panel()
            if existing and existing.target then finish("FOUND: public match, 10 candy");return end
            if not existing then phase="reroll" end
        end
        log("Checking visible quest...")
        local p=panel()
        if p then
            if p.target then finish("FOUND: public match, 10 candy");return end
            if not p.reward then finish("Quest reward unreadable");return end
            closeQuest(p,"reroll");return
        end
        phase="reroll"
    end
    if phase=="reroll" then
        if attempts>=state.MaxAttempts then finish("Attempt limit reached");return end
        log("Finding Give me a new riddle...")
        local button=findText("give me a new riddle")
        if not button then
            log("Finding button: "..scan.visited.." scanned, "..#scan.texts.." texts")
            phase="inspect";deadline=now+.5;return
        end
        attempts=attempts+1
        queueClick(button,"show",1.2);return
    end
    if phase=="show" then
        log("Reading new quest...")
        local p=panel()
        if p then phase="check";return end
        local button=findText("what's my riddle?")
        if not button then finish("Reopen dialogue, then press F8");return end
        queueClick(button,"check",1);return
    end
    if phase=="check" then
        log("Checking reward and objective...")
        local p=panel()
        if not p then finish("Quest panel not readable");return end
        if p.target then finish("FOUND: public match, 10 candy");return end
        if not p.reward then finish("Quest reward unreadable");return end
        log("Attempt "..attempts..": "..p.reward.." candy")
        closeQuest(p,"reroll")
    end
end
function state.Destroy()
    state.Running=false;state.Alive=false
    if connection then pcall(function() connection:Disconnect() end) end
    for _,d in ipairs(noticeObjects) do pcall(function() d:Remove() end) end
    if env.CandyQuestReroll==state then env.CandyQuestReroll=nil end
end
local keyHeld=false
local heartbeatCount=0
connection=game:GetService("RunService").Heartbeat:Connect(function()
    if not state.Alive then return end
    heartbeatCount=heartbeatCount+1
    -- Poll F8 every heartbeat, even when OFF; no GUI scan or clock can block it.
    local okKey,down=pcall(keyDown)
    down=okKey and down==true
    if down and not keyHeld then setEnabled(not state.Running) end
    keyHeld=down
    pcall(updateNotice)
    if not state.Running then return end
    -- Advance a smaller GUI batch, then the reroll state machine.
    -- Direct dialogue choices do not depend on completion of the general GUI scan.
    local scanned,scanError=pcall(refreshScan)
    if not scanned then finish("GUI scan error: "..tostring(scanError));return end
    local ok,err=pcall(update)
    if not ok then finish("Error: "..tostring(err)) end
    pcall(updateNotice)
end)
log("Ready: open Horseman dialogue; F8 starts/stops")
pcall(updateNotice)

