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
    while current do
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
local function textObjects(root)
    local result={}
    if not root then return result end
    for _,o in ipairs(root:GetDescendants()) do
        if o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then
            if visible(o) then table.insert(result,o) end
        end
    end
    return result
end
local function findText(phrase)
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
local function run()
    if type(mouse1click)~="function" then log("Missing mouse1click; cannot click buttons.");return end
    if type(mousemoveabs)~="function" then log("Missing mousemoveabs; cannot move to buttons.");return end
    log("Started. Keep the Horseman dialogue open. F8 stops.")
    for attempt=1,state.MaxAttempts do
        if stopped() then return end
        local existing=panel()
        if existing then
            if existing.target then log("Found: win a public match, reward 10 candy. Stopped.");return end
            if not closePanel(existing) then log("Close the riddle panel and press F8. Stopped.");return end
        end
        local reroll=findText("give me a new riddle")
        if not reroll then log("Open the Horseman dialogue with 'Give me a new riddle', then press F8. Stopped.");return end
        if not click(reroll) or not pause(1.2) then return end
        local p=panel()
        if not p then
            local show=findText("what's my riddle?")
            if not show then
                log("Riddle requested. Reopen the Horseman dialogue to inspect it, then press F8. Stopped.");return
            end
            if not click(show) then return end
            p=waitPanel(4)
        end
        if not p then log("No readable quest panel appeared. Stopped without more rerolls.");return end
        log("Attempt "..attempt..": reward "..tostring(p.reward or "unreadable")..(p.objective and ", public match" or ", other objective"))
        if p.target then log("Found the 10-candy public-match quest. Stopped.");return end
        if not p.reward then log("Reward unreadable; stopping to avoid skipping a valid quest.");return end
        if not closePanel(p) then log("Could not close quest panel. Stopped.");return end
        if not pause(1) then return end
    end
    log("Attempt limit reached. Stopped.")
end
setEnabled=function(on)
    on=on==true and state.Alive
    if state.Running~=on then
        state.Generation=state.Generation+1
        state.Running=on
        if on then log("Starting: looking for riddle button") end
    end
end
function state.Destroy()
    if not state.Alive then return end
    setEnabled(false);state.Alive=false
    for _,d in ipairs(noticeObjects) do pcall(function() d:Remove() end) end
    if env.CandyQuestReroll==state then env.CandyQuestReroll=nil end
end
-- Independent key polling keeps F8 responsive during GUI waits.
task.spawn(function()
    local held=keyDown()
    while state.Alive do
        local down=keyDown()
        local focused=true
        if type(isrbxactive)=="function" then
            local success,active=pcall(isrbxactive)
            focused=success and active==true
        end
        if down and not held and focused then setEnabled(not state.Running) end
        held=down
        pcall(updateNotice)
        task.wait(.03)
    end
end)
task.spawn(function()
    while state.Alive do
        if state.Running then
            local generation=state.Generation
            activeGeneration=generation
            local ok,err=pcall(run)
            if state.Generation==generation then setEnabled(false) end
            if not ok then log("Stopped: "..tostring(err)) end
        end
        task.wait(.1)
    end
end)
log("Ready. Open the Horseman dialogue and press F8 to start. Press F8 again to stop. Stops automatically on the 10-candy public-match quest.")

