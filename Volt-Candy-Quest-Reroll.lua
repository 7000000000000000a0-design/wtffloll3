-- Volt candy quest reroller. F8 starts/stops. Reads reward before rerolling.
local env=(getgenv and getgenv()) or _G
if env.VoltCandyQuests and env.VoltCandyQuests.Destroy then pcall(env.VoltCandyQuests.Destroy) end
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local state={Alive=true,Running=false,Generation=0}
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
local function findQuestClose(root,titleObject)
    local candidates={}
    for _,o in ipairs(root:GetDescendants()) do
        if visible(o) then
            local text=(o:IsA("TextLabel") or o:IsA("TextButton")) and norm(o.Text) or ""
            if text=="x" or text=="×" then
                local button=o
                while button and button~=root and not button:IsA("GuiButton") do button=button.Parent end
                if button and button:IsA("GuiButton") and visible(button) then candidates[button]=true end
            elseif o:IsA("GuiButton") and (o.Name:lower():find("close",1,true) or o.Name:lower()=="x") then
                candidates[o]=true
            end
        end
    end
    local best,bestScore
    local titleY=titleObject.AbsolutePosition.Y
    for button in pairs(candidates) do
        local p,size=button.AbsolutePosition,button.AbsoluteSize
        if size.X>0 and size.Y>0 then
            local score=math.abs(p.Y-titleY)*10-p.X*.01
            if not bestScore or score<bestScore then best=button;bestScore=score end
        end
    end
    return best
end
local function quest()
    for _,o in ipairs(pg:GetDescendants()) do
        if o:IsA("TextLabel") and visible(o) and norm(o.Text)=="the horseman's riddle" then
            local root=o.Parent
            for _=1,4 do
                if not root or root==pg then break end
                local reward,public,close
                for _,t in ipairs(root:GetDescendants()) do
                    if (t:IsA("TextLabel") or t:IsA("TextButton")) and visible(t) then
                        local text=norm(t.Text)
                        if text:find("win a public match",1,true) then public=true end
                        local n=text:match("reward%s*:%s*(%d+)")
                        if n then reward=tonumber(n) end
                        if t:IsA("TextButton") and (text=="x" or text=="×") then close=t end
                    elseif t:IsA("ImageButton") and visible(t) and (t.Name:lower():find("close",1,true) or t.Name:lower()=="x") then close=t end
                end
                if reward then
                    close=findQuestClose(root,o) or close
                    -- The red X may be a sibling of the content frame.
                    if not close and root.Parent and root.Parent~=pg then close=findQuestClose(root.Parent,o) end
                    return {reward=reward,target=reward==10 and public==true,close=close,root=root,title=o}
                end
                root=root.Parent
            end
        end
    end
end
local function valid(g) return state.Alive and state.Running and state.Generation==g end
local function pause(g,seconds)
    local untilTime=os.clock()+seconds
    repeat if not valid(g) then return false end;task.wait(.03) until os.clock()>=untilTime
    return true
end
local function click(o,g)
    if not valid(g) or not o or not visible(o) then return false end
    status("Activating: "..(o:IsA("TextButton") and o.Text or o.Name))
    -- The saved dialogue code connects TextButton.Activated.
    if type(firesignal)=="function" then
        local ok=pcall(function() firesignal(o.Activated) end)
        if ok then return pause(g,.12) end
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
    if not pause(g,.05) then return false end
    vim:SendMouseButtonEvent(x,y,0,true,game,0)
    task.wait(.03)
    vim:SendMouseButtonEvent(x,y,0,false,game,0)
    return valid(g)
end
local skipDialogue
local function waitQuest(g,seconds)
    local finish=os.clock()+seconds
    repeat local q=quest();if q then return q end
        if skipDialogue then skipDialogue(g,false) end
        if not pause(g,.05) then return end
    until os.clock()>=finish
end
local HttpService=game:GetService("HttpService")
local notifiedGenerations={}
local function notifyFound(message,g)
    if notifiedGenerations[g] then return end
    notifiedGenerations[g]=true
    task.spawn(function()
        local okConfig,config=pcall(function()
            return HttpService:JSONDecode(readfile("CandyQuestWebhook.json"))
        end)
        if not okConfig or type(config)~="table" then
            warn("[Volt Candy] Discord settings file unavailable; quest remains stopped.");return
        end
        local url=config.WebhookUrl
        local userId=tostring(config.UserId or "")
        if type(url)~="string" or not url:match("^https://discord%.com/api/webhooks/%d+/[%w_%-]+$") or not userId:match("^%d+$") then
            warn("[Volt Candy] Discord settings invalid; quest remains stopped.");return
        end
        local requestFn=request or http_request or (syn and syn.request) or (http and http.request)
        if type(requestFn)~="function" then warn("[Volt Candy] HTTP request API unavailable; cannot notify Discord.");return end
        local payload={
            content="<@"..userId.."> Candy quest found! "..message,
            allowed_mentions={parse={},users={userId}},
        }
        local body=HttpService:JSONEncode(payload)
        for attempt=1,3 do
            local ok,response=pcall(requestFn,{Url=url.."?wait=true",Method="POST",Headers={["Content-Type"]="application/json"},Body=body})
            local code=ok and type(response)=="table" and tonumber(response.StatusCode or response.Status)
            if code and code>=200 and code<300 then
                print("[Volt Candy] Discord notification sent.");return
            end
            if code==429 then
                local delay=2
                pcall(function() delay=tonumber(HttpService:JSONDecode(response.Body).retry_after) or delay end)
                task.wait(math.clamp(delay,.5,15))
            else
                -- No blind retries: a lost response may still mean Discord received the ping.
                warn("[Volt Candy] Discord notification failed (status "..tostring(code or "unknown").."). Quest remains stopped.");return
            end
        end
        warn("[Volt Candy] Discord rate limit persisted; quest remains stopped.")
    end)
end
local function stop(text,g)
    if g and state.Generation~=g then return end
    if g and valid(g) and not text:find("FOUND:",1,true) then
        error("Recovery needed: "..text,0)
    end
    state.Running=false;status(text)
    if text:find("FOUND:",1,true) then notifyFound(text,g or state.Generation) end
end
local function horseman()
    local npcs=workspace:FindFirstChild("FriendlyNPCs")
    if not npcs then return end
    for _,npc in ipairs(npcs:GetChildren()) do
        local hum=npc:FindFirstChildOfClass("Humanoid")
        if norm(npc.Name):find("horseman",1,true) or (hum and norm(hum.DisplayName):find("horseman",1,true)) then return npc end
    end
end
local lastDialogueClick=0
skipDialogue=function(g,allowCompleted,forcePhysical)
    if not valid(g) or os.clock()-lastDialogueClick<.25 then return false end
    local chat=pg:FindFirstChild("ChatGui")
    local frame=chat and chat:FindFirstChild("Frame")
    local text=frame and frame:FindFirstChild("TextLabel")
    if not chat or not chat.Enabled or not text or not visible(text) then return false end
    for _,o in ipairs(frame:GetChildren()) do
        if o:IsA("TextButton") and o.Visible then return false end
    end
    -- Final dialogue sits beneath the quest panel; it must still be dismissible.
    if quest() and not allowCompleted then return false end
    local content=text.ContentText or text.Text
    local count=(utf8 and utf8.len and utf8.len(content)) or #content
    local max=text.MaxVisibleGraphemes
    local typing=type(max)=="number" and max>=0 and max<count
    if not typing and not allowCompleted then return false end
    lastDialogueClick=os.clock()
    local advanced=false
    if not forcePhysical and type(_G.M1Override)=="function" then advanced=pcall(_G.M1Override) end
    if not advanced then
        local p,size=text.AbsolutePosition,text.AbsoluteSize
        local x,y=p.X+size.X/2,p.Y+size.Y/2
        if not chat.IgnoreGuiInset then
            local inset=game:GetService("GuiService"):GetGuiInset();x=x+inset.X;y=y+inset.Y
        end
        local vim=game:GetService("VirtualInputManager")
        vim:SendMouseMoveEvent(x,y,game)
        if not pause(g,.10) then return false end
        vim:SendMouseButtonEvent(x,y,0,true,game,0)
        task.wait(.04)
        vim:SendMouseButtonEvent(x,y,0,false,game,0)
    end
    return true
end
local function dismissFinalDialogue(g)
    local started=os.clock()
    local clicks=0
    repeat
        if not valid(g) then return false end
        local chat=pg:FindFirstChild("ChatGui")
        local frame=chat and chat:FindFirstChild("Frame")
        local text=frame and frame:FindFirstChild("TextLabel")
        if not chat or not chat.Enabled or not text or not norm(text.Text):find("can you solve this one",1,true) then return true end
        local current=quest()
        if current and current.target then
            state.NeedsInspection=false
            stop("FOUND: public match, 10 candy",g)
            return false
        end
        status("Dismissing final dialogue...")
        -- A callback can exist but do nothing; switch to a real click after one second.
        if skipDialogue(g,true,os.clock()-started>1) then clicks=clicks+1 end
        if not pause(g,.08) then return false end
    until os.clock()-started>=6
    stop("Final dialogue did not finish/close",g);return false
end
local function ensureDialogue(g)
    if not dismissFinalDialogue(g) then return false end
    if button("give me a new riddle") or button("what's my riddle?") then return true end
    local npc=horseman()
    if not npc then stop("Horseman NPC not found nearby",g);return false end
    local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local part=npc.PrimaryPart or npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChildWhichIsA("BasePart")
    if not root or not part or (root.Position-part.Position).Magnitude>30 then
        stop("Stand beside the Horseman, then press F8",g);return false
    end
    local prompt=npc:FindFirstChild("NpcTalkPrompt")
    local detector=npc:FindFirstChildOfClass("ClickDetector")
    for attempt=1,3 do
        if not valid(g) then return false end
        status("Talking to the Horseman...")
        local fired=false
        if prompt and prompt.Enabled and type(fireproximityprompt)=="function" then
            fired=pcall(fireproximityprompt,prompt)
        end
        if not fired and detector and type(fireclickdetector)=="function" then fired=pcall(fireclickdetector,detector) end
        if not fired and prompt and type(firesignal)=="function" then fired=pcall(function() firesignal(prompt.Triggered,player) end) end
        if not fired then stop("Volt cannot activate NPC interaction",g);return false end
        local deadline=os.clock()+4
        repeat
            if button("give me a new riddle") or button("what's my riddle?") then return pause(g,.10) end
            skipDialogue(g,false)
            if not pause(g,.05) then return false end
        until os.clock()>=deadline
    end
    stop("Horseman dialogue did not reopen",g);return false
end
local function closeQuest(q,g)
    status("Pressing the quest panel X...")
    if not valid(g) then return false end
    -- Search all visible X glyphs: some interfaces use a plain label/frame for close.
    local target=q.close
    if not target then
        local bestScore
        for _,o in ipairs(pg:GetDescendants()) do
            if (o:IsA("TextLabel") or o:IsA("TextButton")) and visible(o) then
                local text=norm(o.Text):gsub("%s","")
                if text=="x" or text=="×" or text=="✕" or text=="✖" then
                    local p,size=o.AbsolutePosition,o.AbsoluteSize
                    local tp=q.title.AbsolutePosition
                    local score=math.abs(p.Y-tp.Y)*10-p.X*.01
                    if size.X>0 and size.Y>0 and math.abs(p.Y-tp.Y)<100 and p.X>tp.X then
                        if not bestScore or score<bestScore then target=o;bestScore=score end
                    end
                end
            end
        end
    end
    local x,y,screen
    if target then
        local p,size=target.AbsolutePosition,target.AbsoluteSize
        x=p.X+size.X/2;y=p.Y+size.Y/2
        screen=target:FindFirstAncestorOfClass("ScreenGui")
    else
        -- The supplied screenshots place X flush against the panel's top-right edge.
        local panel=q.root
        while panel and panel~=pg do
            if panel:IsA("GuiObject") then
                local size=panel.AbsoluteSize
                local tp=q.title.AbsolutePosition
                local p=panel.AbsolutePosition
                if size.X>=350 and size.Y>=120 and p.Y<=tp.Y and tp.Y-p.Y<100 then break end
            end
            panel=panel.Parent
        end
        if not panel or panel==pg or not panel:IsA("GuiObject") then
            stop("Cannot determine quest panel bounds",g);return false
        end
        local p,size=panel.AbsolutePosition,panel.AbsoluteSize
        x=p.X+size.X-22;y=p.Y+22
        screen=panel:FindFirstAncestorOfClass("ScreenGui")
    end
    if screen and not screen.IgnoreGuiInset then
        local inset=game:GetService("GuiService"):GetGuiInset();x=x+inset.X;y=y+inset.Y
    end
    -- Use actual mouse input, so a plain label or overlay cannot block signal lookup.
    local vim=game:GetService("VirtualInputManager")
    vim:SendMouseMoveEvent(x,y,game)
    if not pause(g,.05) then return false end
    vim:SendMouseButtonEvent(x,y,0,true,game,0)
    task.wait(.03)
    vim:SendMouseButtonEvent(x,y,0,false,game,0)
    local deadline=os.clock()+3
    repeat
        if not quest() then return pause(g,.04) end
        if not pause(g,.05) then return false end
    until os.clock()>=deadline
    stop("Quest panel did not close",g);return false
end
local function waitAfterReroll(g)
    -- Let the click handler start, then proceed on an observable UI change.
    if not pause(g,.10) then return false end
    local deadline=os.clock()+4
    repeat
        if not valid(g) then return false end
        if quest() then return true end
        local chat=pg:FindFirstChild("ChatGui")
        if not chat or not chat.Enabled then return true end
        local frame=chat:FindFirstChild("Frame")
        local label=frame and frame:FindFirstChild("TextLabel")
        if label and norm(label.Text):find("can you solve this one",1,true) then return true end
        if button("what's my riddle?") then return true end
        skipDialogue(g,false)
        if not pause(g,.05) then return false end
    until os.clock()>=deadline
    stop("Riddle response timed out",g);return false
end
local function inspectQuest(g)
    if not ensureDialogue(g) then return end
    local show=button("what's my riddle?")
    if not show then error("Quest inspection choice unavailable",0) end
    if not click(show,g) then return end
    return waitQuest(g,4)
end
local function run(g)
    local attempt=0
    while valid(g) do
        local q=quest()
        if state.NeedsInspection and not q then
            q=inspectQuest(g)
            if not valid(g) then return end
            if not q then error("Cannot verify pending quest; retrying inspection",0) end
        end
        if q then
            state.NeedsInspection=false
            if q.target then
                stop("FOUND: public match, 10 candy",g);return
            end
            if not closeQuest(q,g) then return end
        end
        if not ensureDialogue(g) then return end
        local reroll=button("give me a new riddle")
        if not reroll then error("Reroll choice unavailable",0) end
        attempt=attempt+1;status("Requesting riddle "..attempt)
        -- Preserve this flag across recovery; inspect before requesting another quest.
        state.NeedsInspection=true
        if not click(reroll,g) or not waitAfterReroll(g) then return end
        q=quest()
        if q and q.target then
            state.NeedsInspection=false
            stop("FOUND: public match, 10 candy",g);return
        end
        if not dismissFinalDialogue(g) then return end
        q=quest() or inspectQuest(g)
        if not valid(g) then return end
        if not q then error("Quest panel unreadable; retrying inspection",0) end
        state.NeedsInspection=false
        if q.target then
            stop("FOUND: public match, 10 candy",g);return
        end
        status("Reward "..q.reward.."; rerolling")
        if not closeQuest(q,g) then return end
        state.RecoveryFailures=0
        if not pause(g,.05) then return end
    end
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
        local failures=0
        while valid(g) do
            local ok,err=pcall(run,g)
            if ok or not valid(g) then break end
            failures=(state.RecoveryFailures==0) and 1 or failures+1
            state.RecoveryFailures=failures
            if failures>=5 then
                state.Running=false;status("Stopped after 5 recovery failures: "..tostring(err));break
            end
            status("Recovering "..failures.."/5: "..tostring(err))
            if not pause(g,math.min(.4*failures,2)) then break end
        end
    end) end
end)
status("Ready: stand beside Horseman; press F8")

