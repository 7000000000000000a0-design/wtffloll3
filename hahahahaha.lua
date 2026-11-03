-- Matcha version. Drawing menu provided by Nova (Martinikaws).
local old = _G.NanamiTimingMatcha
if old and old.Destroy then pcall(old.Destroy) end
assert(Drawing and type(Drawing.new) == "function", "Matcha Drawing API is required")
local url = "https://raw.githubusercontent.com/Martinikaws/Nova/88f5bd44551d03d6a01ba07b761519eb3d8ccb34/Nova.lua"
local source
if type(httpget) == "function" then source = httpget(url) else source = game:HttpGet(url) end
local wheelSource=table.concat({
    "    local function colorPopup(el, x, y, w, bottom)",
    "        local pw, ph = math.min(260, w), 220",
    "        local px, py = x + w - pw, y + 38",
    "        if py + ph > bottom and y - ph - 4 > 0 then py = y - ph - 4 end",
    "        return function()",
    "            rect(px, py, pw, ph, C.panel, 20, 6)",
    "            border(px, py, pw, ph, C.line, 21, 6)",
    "            el.hsv = el.hsv or {toHSV(el.Value)}",
    "            local hsv = el.hsv",
    "            local radius = math.min(70, (pw - 82) / 2)",
    "            local cx, cy = px + radius + 14, py + radius + 14",
    "            local function hue(dx, dy)",
    "                local angle",
    "                if math.atan2 then angle = math.atan2(dy, dx) else angle = math.atan(dy, dx) end",
    "                return (angle / (math.pi * 2)) % 1",
    "            end",
    "            local wheelDrawn=opts.ColorWheelImage and picture(el.id..\":wheel-art\",opts.ColorWheelImage,cx-radius,cy-radius,radius*2,radius*2,22)",
    "            if not wheelDrawn then",
    "            local cell = 3",
    "            for gy = -radius, radius, cell do",
    "                for gx = -radius, radius, cell do",
    "                    local dx, dy = gx + cell / 2, gy + cell / 2",
    "                    local distance = math.sqrt(dx * dx + dy * dy)",
    "                    if distance <= radius then",
    "                        local halfWidth=math.sqrt(math.max(0,radius*radius-dy*dy))",
    "                        local left=math.max(gx,-halfWidth)",
    "                        local right=math.min(gx+cell,halfWidth)",
    "                        rect(cx + left, cy + gy, right-left, cell,",
    "                            fromHSV(hue(dx, dy), distance / radius, 1), 22, 0)",
    "                    end",
    "                end",
    "            end",
    "            end",
    "            local angle = hsv[1] * math.pi * 2",
    "            local sx, sy = cx + math.cos(angle) * hsv[2] * radius, cy + math.sin(angle) * hsv[2] * radius",
    "            circle(sx, sy, 5, RGB(0, 0, 0), 24, false, 3)",
    "            circle(sx, sy, 4, RGB(255, 255, 255), 25, false, 1)",
    "            local dx, dy = M.x - cx, M.y - cy",
    "            local distance = math.sqrt(dx * dx + dy * dy)",
    "            if distance <= radius and pressed(cx - radius, cy - radius, radius * 2, radius * 2, true) then",
    "                drag = el.id .. \":wheel\"; M.claimed = true",
    "            end",
    "            if drag == el.id .. \":wheel\" then",
    "                if M.down then",
    "                    M.claimed, M.dragged = true, true",
    "                    if distance > 0.001 then hsv[1] = hue(dx, dy) end",
    "                    hsv[2] = clamp(distance / radius, 0, 1)",
    "                    el:Set(fromHSV(hsv[1], hsv[2], hsv[3]))",
    "                else drag = nil end",
    "            end",
    "            local bx, by, bw, bh = px + pw - 45, py + 14, 20, radius * 2",
    "            for i = 0, 27 do",
    "                rect(bx, by + bh * i / 28, bw, math.ceil(bh / 28) + 1,",
    "                    fromHSV(hsv[1], hsv[2], 1 - i / 27), 22, 0)",
    "            end",
    "            border(bx, by, bw, bh, C.line, 23, 2)",
    "            rect(bx - 3, by + bh * (1 - hsv[3]) - 2, bw + 6, 4, C.text, 24, 1)",
    "            if pressed(bx - 5, by - 4, bw + 10, bh + 8, true) then drag = el.id .. \":value\"; M.claimed = true end",
    "            if drag == el.id .. \":value\" then",
    "                if M.down then",
    "                    M.claimed, M.dragged = true, true",
    "                    hsv[3] = 1 - clamp((M.y - by) / bh, 0, 1)",
    "                    el:Set(fromHSV(hsv[1], hsv[2], hsv[3]))",
    "                else drag = nil end",
    "            end",
    "            local hx, hy, hw = px + 12, py + 177, pw - 24",
    "            local fieldWidth=(hw-12)/3",
    "            local labels={\"R\",\"G\",\"B\"}",
    "            for channel=1,3 do",
    "                local index=channel",
    "                local id=el.id..\":rgb\"..index",
    "                local fx=hx+(index-1)*(fieldWidth+6)",
    "                local focused=focus==id",
    "                local values={el.Value.R,el.Value.G,el.Value.B}",
    "                local value=math.floor(clamp(values[index],0,1)*255+.5)",
    "                rect(fx,hy,fieldWidth,28,C.card,22,5)",
    "                border(fx,hy,fieldWidth,28,focused and C.accent or C.line,23,5)",
    "                mtext(labels[index],fx+6,hy+14,C.dim,12,24)",
    "                mtext(focused and focusValue or tostring(value),fx+23,hy+14,C.text,13,24)",
    "                if clicked(fx,hy,fieldWidth,28,true) and not focused then",
    "                    blur();focus,focusValue=id,tostring(value)",
    "                    focusCommit=function(text)",
    "                        local number=tonumber(text)",
    "                        if not number then return end",
    "                        local rgb={el.Value.R,el.Value.G,el.Value.B}",
    "                        rgb[index]=math.floor(clamp(number,0,255)+.5)/255",
    "                        el:Set(Color3.new(rgb[1],rgb[2],rgb[3]))",
    "                        el.hsv={toHSV(el.Value)}",
    "                    end",
    "                end",
    "            end",
    "            return {x = px, y = py, w = pw, h = ph}",
    "        end",
    "    end",
    "",
    "",
}, "\n")
local wheelStart=source:find("    local function colorPopup(",1,true)
local wheelEnd=wheelStart and source:find("    function DRAW.Colorpicker(",wheelStart,true)
assert(wheelStart and wheelEnd,"Nova color picker layout changed")
source=source:sub(1,wheelStart-1)..wheelSource..source:sub(wheelEnd)
local menuColorSource=table.concat({
    "        local function applyMenuColor(c)",
    "            local function shade(delta)",
    "                return Color3.new(clamp(c.R+delta,0,1),clamp(c.G+delta,0,1),clamp(c.B+delta,0,1))",
    "            end",
    "            C.bg=c",
    "            local light=(c.R*.299+c.G*.587+c.B*.114)>.55",
    "            local direction=light and -1 or 1",
    "            C.side=shade(direction*.018)",
    "            C.panel=shade(direction*.032)",
    "            C.card=shade(direction*.052)",
    "            C.cardHover=shade(direction*.085)",
    "            C.line=shade(direction*.13)",
    "            C.text=light and RGB(20,22,28) or RGB(235,238,245)",
    "            C.dim=light and RGB(65,70,82) or RGB(160,168,185)",
    "            C.faint=light and RGB(90,95,108) or RGB(105,115,135)",
    "        end",
    "        if type(saved.__menu)==\"string\" then applyMenuColor(hexToColor(saved.__menu) or C.bg) end",
    "        settings:Colorpicker({Name=\"Menu color\",Default=C.bg,Callback=function(c) applyMenuColor(c); Window:Save() end})",
    "",
}, "\n")
local accentMarker="        accentEl.menuAccent = true"
local accentStart,accentEnd=source:find(accentMarker,1,true)
assert(accentStart,"Nova Settings layout changed")
source=source:sub(1,accentEnd).."\n"..menuColorSource..source:sub(accentEnd+1)
source=source:gsub("__accent = accentHex, __mouseoffset", "__accent = accentHex, __menu = colorToHex(C.bg), __mouseoffset")
source=source:gsub("applyAccent%(c%); markChanged%(%)", "applyAccent(c); markChanged(); Window:Save()")
local smoothScrollSource=table.concat({
    "    local wheelPending=0",
    "    local wheelConnections={}",
    "    pcall(function()",
    "        local input=game:GetService(\"UserInputService\")",
    "        wheelConnections[#wheelConnections+1]=input.InputChanged:Connect(function(event)",
    "            pcall(function()",
    "                if tostring(event.UserInputType):find(\"MouseWheel\",1,true) then",
    "                    wheelPending=wheelPending+event.Position.Z",
    "                end",
    "            end)",
    "        end)",
    "    end)",
    "    local function drawPage(tab,x,y,w,h)",
    "        local s=tab.scroll",
    "        local list,total={},0",
    "        for _,el in ipairs(tab.elements)do",
    "            if not el.Hidden then list[#list+1]=el;total=total+heightOf(el,w)end",
    "        end",
    "        local maxScroll=math.max(0,total-h)",
    "        s.target=clamp(s.target or 0,0,maxScroll)",
    "        s.visual=clamp(s.visual or 0,0,maxScroll)",
    "        local hovered=over(x,y,w+14,h)",
    "        if hovered and not focus and not popup then",
    "            if wheelPending~=0 then s.target=s.target-wheelPending*48 end",
    "            if key(0x28) then s.target=s.target+42 end",
    "            if key(0x26) then s.target=s.target-42 end",
    "            if key(0x22) then s.target=s.target+h*.85 end",
    "            if key(0x21) then s.target=s.target-h*.85 end",
    "            if pressed(x,y,w,h)then s.grab=M.y;s.grabTarget=s.target end",
    "        end",
    "        wheelPending=0",
    "        if not M.down then s.grab=nil;s.bar=nil end",
    "        if s.grab and M.dragged then s.target=s.grabTarget-(M.y-s.grab) end",
    "        local barH=math.max(28,h*h/math.max(h,total))",
    "        local bx=x+w+4",
    "        local barY=y+(h-barH)*s.visual/math.max(1,maxScroll)",
    "        if maxScroll>0 then",
    "            local onBar=over(bx-3,y,12,h)",
    "            if pressed(bx-3,y,12,h)then",
    "                s.bar=clamp(M.y-barY,0,barH);s.grab=nil",
    "                M.claimed,M.dragged=true,true",
    "            end",
    "            if s.bar then",
    "                s.target=(M.y-y-s.bar)/math.max(1,h-barH)*maxScroll",
    "                M.claimed,M.dragged=true,true",
    "            end",
    "            rect(bx,y,6,h,C.card,3,3)",
    "            rect(bx,barY,6,barH,(onBar or s.bar)and C.accent or C.faint,4,3)",
    "        end",
    "        s.target=clamp(s.target,0,maxScroll)",
    "        local dt=math.min(.1,math.max(0,frameDt or 1/60))",
    "        s.visual=s.visual+(s.target-s.visual)*(1-math.exp(-18*dt))",
    "        if math.abs(s.target-s.visual)<.1 then s.visual=s.target end",
    "        local cy=y-s.visual",
    "        for _,el in ipairs(list)do",
    "            local eh=heightOf(el,w)",
    "            if cy>=y-.1 and cy+eh-8<=y+h then",
    "                local fn=DRAW[el.Kind]",
    "                if fn then fn(el,x,cy,w,eh,y+h)end",
    "            end",
    "            cy=cy+eh",
    "        end",
    "    end",
    "",
    "",
}, "\n")
local pageStart=source:find("    local function drawPage(",1,true)
local pageEnd=pageStart and source:find("    local function drawWindow(",pageStart,true)
assert(pageStart and pageEnd,"Nova scroll layout changed")
source=source:sub(1,pageStart-1)..smoothScrollSource..source:sub(pageEnd)
source=source:gsub("alive = false\n        if saveAt", "alive = false\n        for _,connection in ipairs(wheelConnections)do pcall(function()connection:Disconnect()end)end\n        if saveAt")
local ownedDrawings={}
local function clearOwnedDrawings()
    for _,drawing in ipairs(ownedDrawings)do
        pcall(function()drawing.Visible=false end)
        pcall(function()drawing.Transparency=0 end)
        local ok=pcall(function()drawing:Remove()end)
        if not ok then pcall(function()drawing:Destroy()end)end
    end
end
-- Track only objects created by this copy of Nova, without replacing global Drawing.
_G.ABATimingOwnedDrawings=ownedDrawings
-- Matcha may not run short-lived spawned button callbacks reliably.
source=source:gsub("task%.spawn%(callback, el%)","callback(el)")
-- A button can unload during frame(); remove anything drawn later in that frame.
source=source:gsub("local ok, err = pcall%(frame%)","local ok, err = pcall(frame)\n        if not alive then pcall(wipe) end")
source=source:gsub("Drawing%.new","abaOwnedDrawingNew")
source=table.concat({
    "local abaNativeDrawingNew=Drawing.new",
    "local abaOwnedDrawings=_G.ABATimingOwnedDrawings",
    "local function abaOwnedDrawingNew(kind)",
    "    local object=abaNativeDrawingNew(kind)",
    "    abaOwnedDrawings[#abaOwnedDrawings+1]=object",
    "    return object",
    "end",
    "",
}, "\n")..source
local function replaceMenu(text, old, new)
    local a, b = text:find(old, 1, true)
    assert(a, "Menu patch target missing: " .. old)
    return text:sub(1, a - 1) .. new .. text:sub(b + 1)
end

source = replaceMenu(
    source,
    "local ok = pcall(function() M.x, M.y = mouse.X, mouse.Y + mouseOffset end)",
    "local ok = pcall(function() local p = game:GetService('UserInputService'):GetMouseLocation(); M.x, M.y = p.X, p.Y end)"
)

source = replaceMenu(
    source,
    "if pressed(x, y, SIDEBAR, 52) and not slide then",
    "if pressed(x, y, w, 34) and not slide then"
)

source = replaceMenu(
    source,
    'if grab ~= lastGrab and type(setrobloxinput) == "function" then',
    "if false then"
)

source = [[
local UIS = game:GetService("UserInputService")

local menuFocused=true
local menuFocusConnections={}
menuFocusConnections[#menuFocusConnections+1]=UIS.WindowFocused:Connect(function()menuFocused=true end)
menuFocusConnections[#menuFocusConnections+1]=UIS.WindowFocusReleased:Connect(function()menuFocused=false end)
local isrbxactive = function() return menuFocused end

local ismouse1pressed = function()
    return UIS:IsMouseButtonPressed(
        Enum.UserInputType.MouseButton1
    )
end

local keyNames = {
    [8]="Backspace", [9]="Tab", [13]="Return",
    [16]="LeftShift", [17]="LeftControl", [18]="LeftAlt",
    [27]="Escape", [32]="Space",
    [33]="PageUp", [34]="PageDown", [35]="End", [36]="Home",
    [37]="Left", [38]="Up", [39]="Right", [40]="Down",
    [45]="Insert", [46]="Delete",
    [160]="LeftShift", [161]="RightShift",
    [162]="LeftControl", [163]="RightControl",
    [164]="LeftAlt", [165]="RightAlt",
    [186]="Semicolon", [187]="Equals", [188]="Comma",
    [189]="Minus", [190]="Period", [191]="Slash",
    [192]="Backquote", [219]="LeftBracket",
    [220]="BackSlash", [221]="RightBracket", [222]="Quote"
}

local digits = {
    "Zero", "One", "Two", "Three", "Four",
    "Five", "Six", "Seven", "Eight", "Nine"
}

local iskeypressed = function(vk)
    if vk == 1 then
        return ismouse1pressed()
    elseif vk == 2 then
        return UIS:IsMouseButtonPressed(
            Enum.UserInputType.MouseButton2
        )
    end

    if vk == 4 then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton3) end

    local name = keyNames[vk]

    if vk >= 48 and vk <= 57 then
        name = digits[vk - 47]
    elseif vk >= 65 and vk <= 90 then
        name = string.char(vk)
    elseif vk >= 112 and vk <= 123 then
        name = "F" .. tostring(vk - 111)
    end

    return name and UIS:IsKeyDown(Enum.KeyCode[name]) or false
end
]] .. source

source=source:gsub("local KEY_NAME = {}", 'VK.MButton=0x04\nKEY_LABEL[0x04]="Middle Mouse"\nlocal KEY_NAME = {}',1)

source=source:gsub("alive = false\n", "alive = false\n        for _,event in ipairs(menuFocusConnections)do pcall(function()event:Disconnect()end)end\n",1)
local menuChunk, menuError = loadstring(source)
assert(menuChunk, menuError)
local library = menuChunk()

local Nova = library or _G.Nova
assert(Nova and Nova.CreateWindow, "Nova menu library did not load")
local colorWheelImage
pcall(function()
    local wheelURL="https://raw.githubusercontent.com/7000000000000000a0-design/wtffloll3/main/assets/color-wheel.png"
    if type(httpget)=="function" then colorWheelImage=httpget(wheelURL)else colorWheelImage=game:HttpGet(wheelURL)end
end)
local state
local window = Nova:CreateWindow({Title="hahahahahaha", ColorWheelImage=colorWheelImage, Folder="hahahahahaha", ConfigName="menu-colors", ToggleKey="RightShift", Open=true, Size={480,380}, OnUnload=function()
    if state then state.Destroy() end
end})
if window.SettingsTab and window.SettingsTab.elements then
    local rows=window.SettingsTab.elements
    for i=#rows,1,-1 do
        local name=tostring(rows[i].Name or "")
        local text=tostring(rows[i].Text or "")
        if name:find("Mouse offset",1,true)==1 or text:find("Made with Nova",1,true)==1 or name:find("Made with Nova",1,true)==1 then
            table.remove(rows,i)
        elseif name=="Unload" then
            rows[i].Callback=function() if state then state.Destroy()end end
        end
    end
end
local tab = window:Tab("Timings")

local enabled, alive, clicked = false, true, false
local lastNanamiClick=-math.huge
local prompts = {}
local connection, lastStatus, lastError
local instaCleanup
local macroCleanup

local function message(text)
    if text ~= lastStatus then lastStatus=text;  end
end
tab:Toggle({Name="Auto Nanami", Default=false, Callback=function(on)
    enabled=on; prompts={}; clicked=false
    message(on and "Waiting for your Nanami move..." or "Auto Nanami: OFF")
end})


state = {}
function state.Destroy()
    if not alive then return end
    alive=false; enabled=false
    if instaCleanup then pcall(instaCleanup) end
    if macroCleanup then pcall(macroCleanup) end
    if connection then pcall(function()connection:Disconnect()end);connection=nil end
    pcall(function()window:Toggle(false)end)
    pcall(function()window:Destroy()end)
    clearOwnedDrawings()
    -- Also catch any final objects created by a menu frame already in progress.
    if task and type(task.spawn)=="function" then
        task.spawn(function()
            for _=1,3 do task.wait();clearOwnedDrawings() end
        end)
    end
    if _G.NanamiTimingMatcha == state then _G.NanamiTimingMatcha=nil end
    if _G.ABATimingOwnedDrawings==ownedDrawings then _G.ABATimingOwnedDrawings=nil end
end
_G.NanamiTimingMatcha=state

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
-- Timing input adapters also work outside Nova's separately loaded menu.
local timingUIS=game:GetService("UserInputService")
local timingNativeKey=iskeypressed
local timingNativeClick=mouse1click
local timingVIM
pcall(function()timingVIM=game:GetService("VirtualInputManager")end)
local iskeypressed=function(vk)
    if type(timingNativeKey)=="function" then
        local ok,down=pcall(timingNativeKey,vk)
        if ok then return down==true end
    end
    local names={[0x31]="One",[0x32]="Two",[0x33]="Three",[0x34]="Four"}
    local name=names[vk]
    return name and timingUIS:IsKeyDown(Enum.KeyCode[name]) or false
end
local mouse1click=function()
    if type(timingNativeClick)=="function" then return timingNativeClick() end
    assert(timingVIM,"Left-click simulation is unavailable in this runner")
    local point=timingUIS:GetMouseLocation()
    local ok,err=pcall(function()timingVIM:SendMouseButtonEvent(point.X,point.Y,0,true,game,0)end)
    local released,releaseErr=pcall(function()timingVIM:SendMouseButtonEvent(point.X,point.Y,0,false,game,0)end)
    if not ok then error(err) end
    if not released then error(releaseErr) end
end
local function readRatio(bar,cutter)
    local ok,value=pcall(function()return cutter.Position.X.Scale end)
    if ok and type(value)=="number" and value==value then
        local width=bar.AbsoluteSize.X
        local offset=cutter.Position.X.Offset
        if width>0 and type(offset)=="number" then value=value+offset/width end
        if value>=0 and value<=1 then return value,"local" end
    end
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
local flashTab=tab

local flash={last=nil,minimum=math.huge,descending=false,fired=false}
local cameraTimingsOn=false
local m1Cooldown,quietAfterNanami=.2,.6
local lastProfileClick=-math.huge


-- GT Goku profiles use the saved camera animation's 60-fps timeline.
-- Cues reproduce the existing downward-then-upward zoom rule, not verified QTE windows.
local gtCameraProfiles={
    ["115027682223739"]={name="SSJ4",frames={40,200,364,507}},
    ["114729164555197"]={name="FullPower",frames={23,62,103,219}},
    ["106522529146940"]={name="QuickSSJ4",frames={33,69,223}},
    ["117772961044160"]={name="Mini4Ku",frames={183,212}},
    ["75854246118526"]={name="AdultDaima4",frames={169,433}},
    ["97822073349491"]={name="ExplosiveKame",frames={95,105,850}},
    ["81873132751170"]={name="SpiritBomb",frames={}},
    ["101369743951516"]={name="GoldenApe",frames={}}, -- Fixed FOV; suppress generic clicks.
}
local gtTrackStates=setmetatable({}, {__mode="k"})
local function updateGTCamera(cam,now)
    local found=false
    local active={}
    for _,rig in ipairs(cam:GetChildren()) do
        if rig.Name=="GTKuCam" then
            local controller=rig:FindFirstChildOfClass("AnimationController")
            local animator=controller and controller:FindFirstChildOfClass("Animator")
            local ok,tracks=pcall(function()
                return animator and animator:GetPlayingAnimationTracks() or controller:GetPlayingAnimationTracks()
            end)
            if ok and tracks then
                for _,track in ipairs(tracks) do
                    local animation=track.Animation
                    local id=animation and tostring(animation.AnimationId):match("%d+")
                    local profile=id and gtCameraProfiles[id]
                    if profile and track.IsPlaying then
                        found=true;active[track]=true
                        local frame=track.TimePosition*60
                        local entry=gtTrackStates[track]
                        if not entry or frame<entry.last-1 then
                            -- Starting midway through a cutscene must not replay old cues.
                            entry={last=frame,fired={}}
                            gtTrackStates[track]=entry
                        else
                            for index,cue in ipairs(profile.frames) do
                                if not entry.fired[index] and frame>cue then
                                    entry.fired[index]=true
                                    -- Cross the start of the outward zoom once; discard stale cues after a stall.
                                    if entry.last<=cue and frame-cue<=6
                                        and now-lastProfileClick>=m1Cooldown
                                        and now-lastNanamiClick>=quietAfterNanami
                                        and type(mouse1click)=="function" then
                                        mouse1click();lastProfileClick=now
                                        print("[ABA Timings] GT Goku "..profile.name.." zoom click; frame="..tostring(cue))
                                    end
                                end
                            end
                            entry.last=frame
                        end
                    end
                end
            end
        end
    end
    for track in pairs(gtTrackStates) do
        if not active[track] then gtTrackStates[track]=nil end
    end
    return found
end

-- Shared camera detector, including GT Goku animation-specific zoom cues.
flashTab:Toggle({Name="Auto Camera Timings",Default=false,Callback=function(on)
    cameraTimingsOn=on
    gtTrackStates=setmetatable({}, {__mode="k"})
    flash={last=nil,minimum=math.huge,descending=false,fired=false}
end})

local kokuTab=tab
local kokuOn=false
local koku
local function resetKoku(gui)
    koku={gui=gui,positions={},moved=false,stable=0,fired=false,lastMotion=0}
end
resetKoku(nil)
kokuTab:Toggle({Name="Auto Kokushibo",Default=false,Callback=function(on)
    kokuOn=on;resetKoku(nil)
end})
local function kokuPosition(obj)
    local ok,value=pcall(function()
        if not obj:IsA("GuiObject") then return end
        local p=obj.Position
        return {p.X.Scale,p.X.Offset,p.Y.Scale,p.Y.Offset}
    end)
    if ok then return value end
end
local function kokuVisible(gui,pg)
    local current=gui
    while current and current~=pg do
        if current:IsA("GuiObject") and not current.Visible then return false end
        if current:IsA("ScreenGui") and not current.Enabled then return false end
        current=current.Parent
    end
    return current==pg
end
local function kokuRightClick()
    if type(mouse2click)=="function" then mouse2click();return end
    if type(mouse2press)=="function" and type(mouse2release)=="function" then
        local ok,err=pcall(mouse2press)
        local released,releaseErr=pcall(mouse2release)
        if not ok then error(err) end
        if not released then error(releaseErr) end
        return
    end
    local vim=game:GetService("VirtualInputManager")
    local point=game:GetService("UserInputService"):GetMouseLocation()
    local ok,err=pcall(function()vim:SendMouseButtonEvent(point.X,point.Y,1,true,game,0)end)
    local released,releaseErr=pcall(function()vim:SendMouseButtonEvent(point.X,point.Y,1,false,game,0)end)
    if not ok then error(err) end
    if not released then error(releaseErr) end
end
local function updateKokushibo()
    if not alive or not kokuOn then return end
    local player=players.LocalPlayer
    local pg=player and player:FindFirstChild("PlayerGui")
    local gui=koku.gui
    if not gui or not pg or not gui:IsDescendantOf(pg) then
        gui=pg and pg:FindFirstChild("FrenchKokushibo",true)
    end
    if not gui or not kokuVisible(gui,pg) then resetKoku(nil);return end
    if gui~=koku.gui then resetKoku(gui) end
    local now=tick and tick() or os.clock()
    local positions={}
    local changed,count=false,0
    for _,eye in ipairs(gui:GetDescendants())do
        local p=kokuPosition(eye)
        if p then
            positions[eye]=p;count=count+1
            local old=koku.positions[eye]
            if old then
                for i=1,4 do
                    if math.abs(p[i]-old[i])>.000001 then changed=true;break end
                end
            elseif next(koku.positions)~=nil then changed=true end
        end
    end
    for eye in pairs(koku.positions)do
        if not positions[eye] then changed=true end
    end
    koku.positions=positions
    if count==0 then return end
    if changed then
        koku.moved=true;koku.stable=0;koku.fired=false;koku.lastMotion=now
    elseif koku.moved and not koku.fired then
        koku.stable=koku.stable+1
    end
    if koku.moved and not koku.fired and koku.stable>=2 and now-koku.lastMotion>=1/120 then
        -- Mark first so a failed input API cannot spam every frame.
        koku.fired=true
        kokuRightClick()
    end
end
local function updateOtherTimings()
    if not alive then return end
    local now=tick and tick() or os.clock()
    if cameraTimingsOn then
        local cam=world.CurrentCamera
        local fov=cam and cam.FieldOfView
        if cam and updateGTCamera(cam,now) then
            flash={last=nil,minimum=math.huge,descending=false,fired=false}
        elseif type(fov)=="number" then
            if flash.last then
                local delta=fov-flash.last
                if delta<-.05 then
                    -- A new inward zoom starts a fresh round, regardless of base FOV.
                    if flash.fired then flash.fired=false;flash.minimum=fov end
                    flash.descending=true
                end
                flash.minimum=math.min(flash.minimum,fov)
                -- Reference MYABA uses a downward-FOV latch followed by any upward edge.
                local endpoint=delta>.0001
                if flash.descending and endpoint and not flash.fired then
                    local ready=now-lastProfileClick>=m1Cooldown and now-lastNanamiClick>=quietAfterNanami
                    if ready and type(mouse1click)=="function" then
                        mouse1click();flash.fired=true
                        lastProfileClick=now
                        
                        print("[ABA Timings v8] Black Flash zoom click; FOV="..tostring(fov)..", minimum="..tostring(flash.minimum))
                    end
                end
            end
            flash.minimum=math.min(flash.minimum,fov);flash.last=fov
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
        local key=gui
        seen[key]=true
        local prompt=prompts[key] or {fired=false}
        prompts[key]=prompt
        local ratio,method=readRatio(bar,cutter)
        if ratio then
            if ratio == ratio and ratio >= -.1 and ratio <= 1.1 then
                -- A reused GUI can contain multiple timing rounds within one move.
                if prompt.last and prompt.last >= .65 and ratio < .3 then prompt.fired=false end
                local previousRatio=prompt.last
                prompt.last=ratio
                if not prompt.fired then
                    local inWindow=math.abs(ratio-.7)<.018
                    local crossed=previousRatio and previousRatio<.682 and ratio>=.682 and ratio<=.82
                    if (inWindow or crossed) and not sent then
                        mouse1click(); prompt.fired=true; sent=true
                        lastNanamiClick=tick and tick() or os.clock()
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
-- Timing callbacks adapted from ahmed abditori.txt.
local updateInstaTimings
do
    local instaTab=tab
    local instaOn=false
    local rs=game:GetService("ReplicatedStorage")
    local targets={"BlackFlashCheck"}
    local entries={}
    local lastFired=-math.huge
    local nextScan=0
    local status=instaTab:Label({Text="Insta Timing: OFF"})
    status:SetVisible(false)
    local function isYuji()
        local player=players.LocalPlayer
        local character=player and player.Character
        if not player or not character then return false end
        local function matches(value)
            if type(value)~="string" then return false end
            local name=value:lower():gsub("[^%w]","")
            return name:find("yuji",1,true)~=nil or name:find("itadori",1,true)~=nil
        end
        if matches(character.Name) then return true end
        local roots={player,character,player:FindFirstChild("ReplicatedStats")}
        for i=1,3 do
            local root=roots[i]
            if root then
                local ok,attributes=pcall(function()return root:GetAttributes()end)
                if ok and type(attributes)=="table" then
                    for key,value in pairs(attributes)do
                        local field=tostring(key):lower()
                        if (field:find("char",1,true) or field:find("fighter",1,true) or field:find("selected",1,true))
                            and matches(value) then return true end
                    end
                end
                local ok,children=pcall(function()return root:GetDescendants()end)
                if ok then
                    for _,object in ipairs(children)do
                        local field=tostring(object.Name):lower()
                        if field:find("char",1,true) or field:find("fighter",1,true) or field:find("selected",1,true) then
                            local readable,value=pcall(function()return object.Value end)
                            if readable and matches(value) then return true end
                        end
                    end
                end
            end
        end
        return false
    end
    local function fireM1()
        local now=tick and tick() or os.clock()
        if now-lastFired<.5 then return end
        lastFired=now
        local player=players.LocalPlayer
        local char=player and player.Character
        local root=char and char:FindFirstChild("HumanoidRootPart")
        local humanoid=char and char:FindFirstChildWhichIsA("Humanoid")
        if not root or not humanoid or humanoid.Health<=0 then return end
        if char:FindFirstChild("Stun") or char:FindFirstChild("Ragdolled") or char:FindFirstChild("Knocked") then return end
        local backpack=player:FindFirstChild("Backpack")
        local input=backpack and backpack:FindFirstChild("Input")
        if not input then return end
        local jitter=Vector3.new((math.random()-.5)*4,(math.random()-.5)*2,(math.random()-.5)*4)
        local dodgeVelo
        if math.random()<.15 then
            dodgeVelo=Vector3.new(math.random()*2-1,0,math.random()*2-1)*math.random()
        end
        input:FireServer("M1",{
            air=false,mousehit=root.CFrame*CFrame.new(jitter),md=Vector3.zero,
            dodgevelo=dodgeVelo,skeydown=false,skeyreal=false,
        })
    end
    local wrap=newcclosure or function(fn)return fn end
    local function readCallback(remote)
        local ok,value=pcall(function()return remote.OnClientInvoke end)
        if ok then return true,value end
        if type(getcallbackvalue)=="function" then
            return pcall(getcallbackvalue,remote,"OnClientInvoke")
        end
        return false,value
    end
    -- Keep one stable dispatcher per callback. OFF always calls the saved game
    -- function; toggling never re-hooks or erases a game's callback.
    instaCleanup=function()
        instaOn=false
        for _,entry in pairs(entries)do entry.active=false end
    end
    local function install(remote,current,readable)
        if not readable or type(current)~="function" then
            return nil,"Waiting for access to the original game callback"
        end
        local entry={remote=remote,original=current,active=true}
        entry.callback=wrap(function(...)
            -- Capture the state at invocation: an in-progress check completes
            -- consistently even if the switch changes while it is running.
            local automatic=alive and instaOn and entry.active and isYuji()
            if not automatic then return entry.original(...) end
            local ok,err=pcall(fireM1)
            if not ok then print("[Insta Timing] "..tostring(err)) end
            return true,false
        end)
        if type(hookfunction)=="function" then
            entry.mode="hook";entry.target=current
            local ok,original=pcall(hookfunction,current,entry.callback)
            if not ok then return nil,tostring(original) end
            if type(original)~="function" then
                entry.active=false
                return nil,"hookfunction did not return the original callback"
            end
            entry.original=original
        else
            entry.mode="property"
            local ok,err=pcall(function()remote.OnClientInvoke=entry.callback end)
            if not ok then return nil,tostring(err) end
        end
        return entry
    end
    updateInstaTimings=function()
        if not alive or not instaOn then return end
        local now=tick and tick() or os.clock()
        if now<nextScan then return end
        nextScan=now+2
        for remote,entry in pairs(entries)do
            if remote.Parent~=rs then entry.active=false;entries[remote]=nil end
        end
        local count,errors=0,{}
        for _,name in ipairs(targets)do
            local remote=rs:FindFirstChild(name)
            if remote and remote.ClassName=="RemoteFunction" then
                local readable,current=readCallback(remote)
                local entry=entries[remote]
                local expected=entry and (entry.mode=="hook" and entry.target or entry.callback)
                if entry and readable and current~=expected then
                    entry.active=false;entries[remote]=nil;entry=nil
                end
                if not entry then
                    local installed,err=install(remote,current,readable)
                    if installed then entries[remote]=installed;entry=installed
                    else errors[#errors+1]=name..": "..tostring(err) end
                end
                if entry then entry.active=true;count=count+1 end
            end
        end
        status:SetText("Active checks: "..tostring(count).."/1"..(#errors>0 and " | "..errors[1] or ""))
        for _,err in ipairs(errors)do print("[Insta Timing] "..err) end
    end
    instaTab:Toggle({Name="Insta Black Flash - Yuji (for fun)",Default=false,Callback=function(on)
        if not on then
            instaCleanup();status:SetText("Insta Timing: OFF")
            return
        end
        instaOn=true;nextScan=0
        local ok,err=pcall(updateInstaTimings)
        if not ok then status:SetText("Insta Timing unavailable");print("[Insta Timing] "..tostring(err)) end
    end})
end


-- Lua equivalent of x.ahk. All key codes below are Windows virtual-key codes.
local macrosTab=window:Tab("Macros")
local macrosOn=false
local gojoOn=false
local aizenOn=true
local aizenToggle,gojoToggle,dioToggle
local dioOn=false
local macroBusy=false
local macroHeldKeys={}
local macroMouseHeld=false
local macroError
local macroBindings={
    {trigger=0x45,first=0x32,second=0x31,delay=.020},
    {trigger=0x54,first=0x32,second=0x34,delay=.040},
    {trigger=0x5A,first=0x33,second=0x31,delay=.040},
    {trigger=0x58,first=0x33,second=0x34,delay=.040},
}
-- Shared macro input: use runner APIs when present, otherwise Roblox virtual input.
local macroUIS=game:GetService("UserInputService")
local macroVIM
pcall(function()macroVIM=game:GetService("VirtualInputManager")end)
local macroWindowFocused=true
local macroFocusConnections={}
pcall(function()
    macroFocusConnections[#macroFocusConnections+1]=macroUIS.WindowFocused:Connect(function()macroWindowFocused=true end)
    macroFocusConnections[#macroFocusConnections+1]=macroUIS.WindowFocusReleased:Connect(function()macroWindowFocused=false end)
end)
local nativeKeypress,nativeKeyrelease=keypress,keyrelease
local nativeMousepress,nativeMouserelease=mouse1press,mouse1release
local macroKeyNames={[0x20]="Space",[0x31]="One",[0x32]="Two",[0x33]="Three",[0x34]="Four",[0x51]="Q"}
local function macroSendKey(vk,down)
    if type(nativeKeypress)=="function" and type(nativeKeyrelease)=="function" then
        if down then return nativeKeypress(vk) else return nativeKeyrelease(vk) end
    end
    local name=macroKeyNames[vk]
    assert(macroVIM and name,"Keyboard simulation is unavailable in this runner")
    macroVIM:SendKeyEvent(down,Enum.KeyCode[name],false,game)
end
local function macroSendMouse(down)
    if type(nativeMousepress)=="function" and type(nativeMouserelease)=="function" then
        if down then return nativeMousepress() else return nativeMouserelease() end
    end
    assert(macroVIM,"Mouse simulation is unavailable in this runner")
    local point=macroUIS:GetMouseLocation()
    macroVIM:SendMouseButtonEvent(point.X,point.Y,0,down,game,0)
end
local function macroFocused()
    if not macroWindowFocused then return false end
    if type(isrbxactive)=="function" then
        local ok,active=pcall(isrbxactive)
        if ok and active==false then return false end
    end
    local ok,box=pcall(function()return macroUIS:GetFocusedTextBox()end)
    return not ok or box==nil
end
local function macroReady()
    return ((type(nativeKeypress)=="function" and type(nativeKeyrelease)=="function") or macroVIM~=nil)
        and task and type(task.spawn)=="function" and type(task.wait)=="function"
end
local function macroReport(text)
    if macroError~=text then macroError=text;print("[Macros] "..text) end
end
local macroNotice
local macroNoticeUntil=0
local function noticeDrawing(kind,props)
    local object=Drawing.new(kind)
    ownedDrawings[#ownedDrawings+1]=object
    for key,value in pairs(props)do object[key]=value end
    return object
end
local function showMacroNotice(on)
    if not macroNotice then
        macroNotice={parts={}}
        local function background(kind)
            local object=noticeDrawing(kind,{
                Filled=true,Color=Color3.fromRGB(16,16,20),
                Transparency=1,ZIndex=1000,Visible=false,
            })
            macroNotice.parts[#macroNotice.parts+1]=object
            return object
        end
        macroNotice.horizontal=background("Square")
        macroNotice.vertical=background("Square")
        macroNotice.corners={}
        for i=1,4 do
            local corner=background("Circle")
            corner.Radius=10
            corner.NumSides=24
            macroNotice.corners[i]=corner
        end
        macroNotice.dot=noticeDrawing("Circle",{
            Filled=true,Radius=3,NumSides=16,Color=Color3.fromRGB(235,235,240),
            Transparency=1,ZIndex=1001,Visible=false,
        })
        macroNotice.title=noticeDrawing("Text",{
            Text="ahahaha",Size=13,Font=2,Center=false,Outline=false,
            Color=Color3.fromRGB(240,240,245),Transparency=1,ZIndex=1001,Visible=false,
        })
        macroNotice.text=noticeDrawing("Text",{
            Size=13,Font=2,Center=false,Outline=false,
            Color=Color3.fromRGB(150,150,160),Transparency=1,ZIndex=1001,Visible=false,
        })
        macroNotice.parts[#macroNotice.parts+1]=macroNotice.dot
        macroNotice.parts[#macroNotice.parts+1]=macroNotice.title
        macroNotice.parts[#macroNotice.parts+1]=macroNotice.text
    end
    macroNotice.text.Text=on and "Macro is ON" or "Macro is OFF"
    macroNoticeUntil=(tick and tick() or os.clock())+2
end
local function updateMacroNotice()
    if not macroNotice then return end
    local visible=alive and (tick and tick() or os.clock())<macroNoticeUntil
    local camera=world.CurrentCamera
    local size=camera and camera.ViewportSize
    if not size or size.X<=0 then visible=false end
    if visible then
        local width,height,radius=244,38,10
        local x,y=math.max(0,size.X-width-16),16
        macroNotice.horizontal.Position=Vector2.new(x+radius,y)
        macroNotice.horizontal.Size=Vector2.new(width-radius*2,height)
        macroNotice.vertical.Position=Vector2.new(x,y+radius)
        macroNotice.vertical.Size=Vector2.new(width,height-radius*2)
        macroNotice.corners[1].Position=Vector2.new(x+radius,y+radius)
        macroNotice.corners[2].Position=Vector2.new(x+width-radius,y+radius)
        macroNotice.corners[3].Position=Vector2.new(x+radius,y+height-radius)
        macroNotice.corners[4].Position=Vector2.new(x+width-radius,y+height-radius)
        macroNotice.dot.Position=Vector2.new(x+14,y+height/2)
        macroNotice.title.Position=Vector2.new(x+25,y+11)
        macroNotice.text.Position=Vector2.new(x+89,y+11)
    end
    for _,object in ipairs(macroNotice.parts)do object.Visible=visible end
end
-- Persist the master switch without adding another visible control.
local macroSavedState=macrosTab:Toggle({
    Name="Saved macro state",Default=false,Flag="macro_master_enabled",
    Callback=function(on) macrosOn=on end,
})
macroSavedState:SetVisible(false)
macrosOn=macroSavedState.Value==true
macrosTab:Keybind({Name="Toggle Macros",Default="F2",Flag="macro_toggle_key",Mode="Press",Callback=function()
    if not alive or not macroFocused() then return end
    macroSavedState:Set(not macrosOn)
    macrosOn=macroSavedState.Value==true
    window:Save()
    print("[Macros] "..(macrosOn and "ON" or "OFF"))
    local noticeOK,noticeErr=pcall(showMacroNotice,macrosOn)
    if not noticeOK then macroReport(tostring(noticeErr)) end
    if macrosOn and not macroReady() then
        macroReport("Keyboard simulation is unavailable in this runner.")
    end
end})
local function macroTap(vk)
    macroHeldKeys[vk]=true
    macroSendKey(vk,true)
    macroSendKey(vk,false)
    macroHeldKeys[vk]=nil
end
macrosTab:Section("Aizen Macros")
aizenToggle=macrosTab:Toggle({Name="Use Aizen Macro",Default=true,Flag="macro_use_aizen",Callback=function(on)
    aizenOn=on
    if on and dioOn then
        dioOn=false
        if dioToggle then dioToggle:Set(false) end
    end
    if on and gojoOn then
        gojoOn=false
        if gojoToggle then gojoToggle:Set(false) end
    end
end})
local function runMacro(selected)
    if not alive or not macrosOn or not aizenOn or gojoOn or macroBusy or not macroFocused() then return end
    if not macroReady() then
        macroReport("Keyboard simulation is unavailable in this runner.")
        return
    end
    macroBusy=true
    task.spawn(function()
        local ok,err=pcall(function()
            if not alive or not macrosOn or not aizenOn or gojoOn or not macroFocused() then return end
            macroTap(selected.first)
            task.wait(selected.delay)
            if alive and macrosOn and aizenOn and not gojoOn and macroFocused() then macroTap(selected.second) end
        end)
        for vk in pairs(macroHeldKeys)do
            pcall(macroSendKey,vk,false)
            macroHeldKeys[vk]=nil
        end
        macroBusy=false
        if not ok then macroReport(tostring(err)) end
    end)
end
for index,binding in ipairs(macroBindings)do
    local selected=binding
    macrosTab:Keybind({
        Name=string.char(selected.first).." > "..string.char(selected.second).." ("..tostring(math.floor(selected.delay*1000+.5)).." ms)",
        Default=selected.trigger,
        Flag="macro_sequence_"..tostring(index),
        Mode="Press",
        Callback=function() runMacro(selected) end,
    })
end


macrosTab:Section("Gojo Macros")
gojoToggle=macrosTab:Toggle({Name="Use Gojo Macros",Default=false,Flag="macro_use_gojo",Callback=function(on)
    gojoOn=on
    if on and dioOn then
        dioOn=false
        if dioToggle then dioToggle:Set(false) end
    end
    if on and aizenOn then
        aizenOn=false
        if aizenToggle then aizenToggle:Set(false) end
    end
end})
local gojoBindings={
    {name="TP + Pull Blue",key="Z",steps={{0x33,.072},{0x33,.020},{0x51,0}}},
    {name="Instant Blue TP",key="T",steps={{0x33,.092},{0x51,0}}},
    {name="Purple Combo",key="MButton",steps={{0x33,.010},{0x32,1.550},{0x20,0},{0x51,0}}},
    {name="TP + Blue (blue)",key="V",steps={{0x33,.020},{0x51,0}}},
}
local function runGojoMacro(selected)
    if not alive or not macrosOn or not gojoOn or macroBusy or not macroFocused() then return end
    if not macroReady() then
        macroReport("Keyboard simulation is unavailable in this runner.")
        return
    end
    macroBusy=true
    task.spawn(function()
        local ok,err=pcall(function()
            for _,step in ipairs(selected.steps)do
                if not alive or not macrosOn or not gojoOn or not macroFocused() then return end
                macroTap(step[1])
                if step[2]>0 then task.wait(step[2]) end
            end
        end)
        for vk in pairs(macroHeldKeys)do
            pcall(macroSendKey,vk,false)
            macroHeldKeys[vk]=nil
        end
        macroBusy=false
        if not ok then macroReport(tostring(err)) end
    end)
end
for index,binding in ipairs(gojoBindings)do
    local selected=binding
    macrosTab:Keybind({
        Name=selected.name,Default=selected.key,
        Flag="gojo_macro_sequence_"..tostring(index),Mode="Press",
        Callback=function() runGojoMacro(selected) end,
    })
end


macrosTab:Section("DIO Macros")
dioToggle=macrosTab:Toggle({Name="Use DIO Macros",Default=false,Flag="macro_use_dio",Callback=function(on)
    dioOn=on
    if on then
        aizenOn=false;gojoOn=false
        if aizenToggle then aizenToggle:Set(false) end
        if gojoToggle then gojoToggle:Set(false) end
    end
end})
local function runDioMacro()
    if not alive or not macrosOn or not dioOn or macroBusy or not macroFocused() then return end
    if not macroReady() or not ((type(nativeMousepress)=="function" and type(nativeMouserelease)=="function") or macroVIM) then
        macroReport("DIO needs keyboard and mouse simulation support.")
        return
    end
    macroBusy=true
    task.spawn(function()
        local mouseHeld,spaceHeld=false,false
        local function active() return alive and macrosOn and dioOn and macroFocused() end
        local ok,err=pcall(function()
            if not active() then return end
            mouseHeld=true;macroMouseHeld=true;macroSendMouse(true)
            task.wait(.230)
            if not active() then return end
            spaceHeld=true;macroHeldKeys[0x20]=true;macroSendKey(0x20,true)
            task.wait(.210)
            if not active() then return end
            macroTap(0x33)
        end)
        if spaceHeld then pcall(macroSendKey,0x20,false);macroHeldKeys[0x20]=nil end
        if mouseHeld then pcall(macroSendMouse,false);macroMouseHeld=false end
        for vk in pairs(macroHeldKeys)do
            pcall(macroSendKey,vk,false);macroHeldKeys[vk]=nil
        end
        macroBusy=false
        if not ok then macroReport(tostring(err)) end
    end)
end
macrosTab:Keybind({Name="Uptilt",Default="X",Flag="dio_uptilt_key",Mode="Press",
    Callback=function() runDioMacro() end})

-- Apply saved selections immediately; Nova also restores their callbacks on its next frame.
aizenOn=aizenToggle.Value==true
gojoOn=gojoToggle.Value==true
dioOn=dioToggle.Value==true


macroCleanup=function()
    if macroMouseHeld then pcall(macroSendMouse,false);macroMouseHeld=false end
    for _,event in ipairs(macroFocusConnections)do pcall(function()event:Disconnect()end) end
    for vk in pairs(macroHeldKeys)do pcall(macroSendKey,vk,false);macroHeldKeys[vk]=nil end
end

local subsystemErrors={}
local function runSubsystem(name,fn)
    local ok,err=pcall(fn)
    if not ok then
        local text=tostring(err)
        if subsystemErrors[name]~=text then
            subsystemErrors[name]=text
            print("["..name.."] "..text)
        end
    else subsystemErrors[name]=nil end
end
connection=game:GetService("RunService").Heartbeat:Connect(function()
    if not alive then return end
    runSubsystem("Kokushibo Timing",updateKokushibo)
    runSubsystem("Macro Notification",updateMacroNotice)
    if updateInstaTimings then runSubsystem("Insta Timing",updateInstaTimings) end
    runSubsystem("Nanami Timing",update)
    runSubsystem("Camera Timing",updateOtherTimings)
end)
print("[hahahahahaha] Loaded. Timings and Macros are ready. Right Shift shows/hides the menu.")
