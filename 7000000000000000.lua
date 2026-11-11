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
    "        settings:Button({Name=\"Upload background\", Callback=function()",
    "            local ok = pcall(writefile, folder .. \"/discord-background-request.txt\", tostring(tick()))",
    "            Window:Notify({Title=\"Upload background\", Content=ok and \"Checking Discord for the latest PNG or JPG. Keep the Discord background helper running.\" or \"The executor workspace is unavailable.\"})",
    "        end})",
    "",
}, "\n")
local accentMarker="        accentEl.menuAccent = true"
local accentStart,accentEnd=source:find(accentMarker,1,true)
assert(accentStart,"Nova Settings layout changed")
source=source:sub(1,accentEnd).."\n"..menuColorSource..source:sub(accentEnd+1)
source=source:gsub("__accent = accentHex, __mouseoffset", "__accent = accentHex, __menu = colorToHex(C.bg), __mouseoffset")
source=source:gsub("applyAccent%(c%); markChanged%(%)", "applyAccent(c); markChanged(); Window:Save()")
local smoothScrollSource=table.concat({
    "    local wheelDelta, nativeWheelDelta, lastNativeWheel = 0, 0, -math.huge",
    "    local wheelConnection",
    "    local wheelSignal = folder .. \"/menu-wheel.txt\"",
    "    local wheelSession, wheelTotal, nextWheelRead = nil, 0, 0",
    "    local function readWheelBridge(now)",
    "        if type(readfile) ~= \"function\" or now < nextWheelRead then return 0 end",
    "        nextWheelRead = now + 0.05",
    "        local ok, signal = pcall(readfile, wheelSignal)",
    "        if not ok or type(signal) ~= \"string\" then return 0 end",
    "        local session, count = signal:match(\"^(%d+):(%-?%d+)$\")",
    "        if not session then return 0 end",
    "        count = tonumber(count)",
    "        local delta = wheelSession == session and count - wheelTotal or 0",
    "        wheelSession, wheelTotal = session, count",
    "        return clamp(delta, -12, 12)",
    "    end",
    "    pcall(function()",
    "        local input = game:GetService(\"UserInputService\")",
    "        wheelConnection = input.InputChanged:Connect(function(event)",
    "            if tostring(event.UserInputType):find(\"MouseWheel\", 1, true) then",
    "                nativeWheelDelta = nativeWheelDelta + event.Position.Z",
    "                lastNativeWheel = tick()",
    "            end",
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
    "            if open then s.target=s.target+wheelDelta*48 end",
    "            if key(0x28) then s.target=s.target+42 end",
    "            if key(0x26) then s.target=s.target-42 end",
    "            if key(0x22) then s.target=s.target+h*.85 end",
    "            if key(0x21) then s.target=s.target-h*.85 end",
    "            if pressed(x,y,w,h)then s.grab=M.y;s.grabTarget=s.target end",
    "        end",
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
local menuBackgroundSource=table.concat({
    "        local backgroundPath = folder .. \"/menu-background\"",
    "        local background, backgroundVersion, nextBackgroundRead",
    "        local alphabet = \"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/\"",
    "        local digits = {}",
    "        for i = 1, #alphabet do digits[alphabet:byte(i)] = i - 1 end",
    "        local function decodeBackground(encoded)",
    "            if #encoded > 2796204 or #encoded % 4 ~= 0 then return nil end",
    "            local chunks = {}",
    "            for i = 1, #encoded, 4 do",
    "                local a, b, c, d = encoded:byte(i, i + 3)",
    "                local first, second, third, fourth = digits[a], digits[b], digits[c], digits[d]",
    "                if not first or not second then return nil end",
    "                local high = first * 4 + math.floor(second / 16)",
    "                if third and fourth then",
    "                    chunks[#chunks + 1] = string.char(high, (second % 16) * 16 + math.floor(third / 4), (third % 4) * 64 + fourth)",
    "                elseif i + 3 == #encoded and d == 61 and (third or c == 61) then",
    "                    chunks[#chunks + 1] = third and string.char(high, (second % 16) * 16 + math.floor(third / 4)) or string.char(high)",
    "                else",
    "                    return nil",
    "                end",
    "            end",
    "            local data = table.concat(chunks)",
    "            if data:sub(1, 4) == \"\\137PNG\" or data:sub(1, 3) == \"\\255\\216\\255\" then return data end",
    "        end",
    "        local function drawBackground(x, y, w, h)",
    "            local now = tick()",
    "            if type(readfile) == \"function\" and now >= (nextBackgroundRead or 0) then",
    "                nextBackgroundRead = now + 0.75",
    "                local ok, version = pcall(readfile, backgroundPath .. \"-version.txt\")",
    "                if ok and version ~= backgroundVersion then",
    "                    local loaded, encoded = pcall(readfile, backgroundPath .. \".txt\")",
    "                    if loaded and type(encoded) == \"string\" then",
    "                        local decoded = decodeBackground(encoded)",
    "                        if decoded then background, backgroundVersion = decoded, version end",
    "                    end",
    "                end",
    "            end",
    "            if background then picture(\"__menu_background\", background, x, y, w, h, 2, 0.42) end",
    "        end",
}, "\n") .. "\n"
local pageStart=source:find("    local function drawPage(",1,true)
local pageEnd=pageStart and source:find("    local function drawWindow(",pageStart,true)
assert(pageStart and pageEnd,"Nova scroll layout changed")
source=source:sub(1,pageStart-1)..smoothScrollSource..menuBackgroundSource..source:sub(pageEnd)
-- Consume wheel updates even while the menu is closed so old input is discarded.
local wheelFrame = "        readInput()"
local wheelFrameStart, wheelFrameEnd = source:find(wheelFrame, 1, true)
assert(wheelFrameStart, "Nova input loop changed")
source = source:sub(1, wheelFrameEnd) .. [=[

        local wheelNow = tick()
        local bridgeDelta = readWheelBridge(wheelNow)
        wheelDelta = -nativeWheelDelta
        nativeWheelDelta = 0
        if wheelNow - lastNativeWheel > 0.2 then
            wheelDelta = bridgeDelta
        end
        if type(isrbxactive) == "function" and not isrbxactive() then wheelDelta = 0 end]=] .. source:sub(wheelFrameEnd + 1)
source = source:gsub("alive = false\n        if saveAt", "alive = false\n        if wheelConnection then pcall(function() wheelConnection:Disconnect() end) end\n        if saveAt", 1)
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
-- Let Nova display, save and capture the Gojo middle-mouse shortcut.
source=source:gsub("local KEY_NAME = {}", 'VK.MButton=0x04\nKEY_LABEL[0x04]="Middle Mouse"\nlocal KEY_NAME = {}',1)
-- Add a numeric entry field to Head Ride sliders using Nova's text focus.
local sliderValueStart, sliderValueEnd = source:find([=[
        local shown = tostring(el.Value) .. (el.Suffix or "")
        mtext(shown, x + w - 12 - textWidth(shown, 13), y + 15, C.dim, 13, 5)]=], 1, true)
assert(sliderValueStart, "Nova slider layout changed")
source = source:sub(1, sliderValueStart - 1) .. [=[
        local shown = tostring(el.Value) .. (el.Suffix or "")
        if el.Flag and el.Flag:sub(1, 5) == "ride_" then
            local bx, by, bw, bh = x + w - 88, y + 4, 76, 21
            local focused = focus == el.id
            rect(bx, by, bw, bh, C.panel, 4, 4)
            border(bx, by, bw, bh, focused and C.accent or C.line, 4, 4)
            if focused then shown = focusValue .. "|" end
            if clicked(bx, by, bw, bh) and not focused then
                blur()
                focus, focusValue = el.id, ""
                focusCommit = function(value)
                    local number = tonumber(value)
                    if number and number == number and math.abs(number) < math.huge then
                        el:Set(number)
                    end
                end
            end
        end
        mtext(shown, x + w - 17 - textWidth(shown, 13), y + 15, C.dim, 13, 5)]=] .. source:sub(sliderValueEnd + 1)
-- Sample key state even while a text field or key picker owns the input.
source = source:gsub("        if binding or focus then return end\n        for _, tab", "        local acceptsKeys = not binding and not focus and (not isrbxactive or isrbxactive() == true)\n        for _, tab", 1)
source = source:gsub("local hit, down = key%(el.Value%)", "local hit, down = key(el.Value)\n                    hit, down = hit and acceptsKeys, down and acceptsKeys", 1)
source = source:gsub("local function picture%(key, data, x, y, w, h, z%)", "local function picture(key, data, x, y, w, h, z, alpha)", 1)
source = source:gsub('put%(o, c, "ZIndex", z or 4%) put%(o, c, "Transparency", Fade%)', 'put(o, c, "ZIndex", z or 4) put(o, c, "Transparency", (alpha or 1) * Fade)', 1)
source = source:gsub("        rect%(x, y, w, h, C.bg, 1, 10%)", "        rect(x, y, w, h, C.bg, 1, 10)\n        drawBackground(x + SIDEBAR, y, w - SIDEBAR, h)", 1)
local library = loadstring(source)()
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
local destroyHeadRide

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
    if destroyHeadRide then pcall(destroyHeadRide) end
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
local function readRatio(bar,cutter)
    local ok,value=pcall(function()return cutter.Position.X.Scale end)
    if ok and type(value)=="number" and value>=0 and value<=1 then return value,"local" end
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

local koku={gui=nil,positions={},moved=false,stable=0,fired=false}
kokuTab:Toggle({Name="Auto Kokushibo",Default=false,Callback=function(on)
    kokuOn=on;koku={gui=nil,positions={},moved=false,stable=0,fired=false}
    
end})
local function localX(obj)
    local ok,x=pcall(function()return obj.Position.X.Scale end)
    if ok and type(x)=="number" then return x end
    if positionOffset and type(memory_read)=="function" then
        local success,value=pcall(function()return memory_read("float",obj.Address+positionOffset)end)
        if success and type(value)=="number" and value==value then return value end
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
                if delta<-.05 then flash.descending=true end
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
            if fov>=65 then flash={last=fov,minimum=fov,descending=false,fired=false}
            else flash.minimum=math.min(flash.minimum,fov);flash.last=fov end
        end
    end
    if kokuOn then
        local player=players.LocalPlayer
        local pg=player and player:FindFirstChild("PlayerGui")
        local gui=pg and pg:FindFirstChild("FrenchKokushibo")
        if not gui then koku={gui=nil,positions={},moved=false,stable=0,fired=false};return end
        local key=gui.Address or gui
        if key~=koku.gui then koku={gui=key,positions={},moved=false,stable=0,fired=false} end
        if koku.fired then return end
        local changed=false
        local count=0
        for _,eye in ipairs(gui:GetChildren())do
            local x=localX(eye)
            if x then
                count=count+1
                local id=eye.Address or eye
                local previousX=koku.positions[id]
                if previousX and math.abs(x-previousX)>.000001 then changed=true end
                koku.positions[id]=x
            end
        end
        if count==0 then return end
        if changed then koku.moved=true;koku.stable=0
        elseif koku.moved then koku.stable=koku.stable+1 end
        if koku.stable>=2 then
            if type(mouse2click)=="function" then
                mouse2click();koku.fired=true
            end
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
        local key=gui.Address or gui
        seen[key]=true
        local prompt=prompts[key] or {fired=false}
        prompts[key]=prompt
        local ratio,method=readRatio(bar,cutter)
        if ratio then
            if ratio == ratio and ratio >= -.1 and ratio <= 1.1 then
                -- A reused GUI can contain multiple timing rounds within one move.
                if prompt.last and prompt.last >= .65 and ratio < .3 then prompt.fired=false end
                prompt.last=ratio
                if not prompt.fired then
                    if math.abs(ratio-.7) < .018 and not sent then
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

-- Lua equivalent of x.ahk. All key codes below are Windows virtual-key codes.
local macrosTab=window:Tab("Macros")
local macrosOn=false
local gojoOn=false
local aizenOn=false
local aizenToggle,gojoToggle,dioToggle,yusukeToggle
local dioOn=false
local yusukeOn=false
local macroBusy=false
local macroHeldKeys={}
local macroError
local macroBindings={
    {trigger=0x45,first=0x32,second=0x31,delay=.020},
    {trigger=0x54,first=0x32,second=0x34,delay=.040},
    {trigger=0x5A,first=0x33,second=0x31,delay=.040},
    {trigger=0x58,first=0x33,second=0x34,delay=.040},
}
local function robloxFocused()
    if type(isrbxactive)~="function" then return false end
    local ok,active=pcall(isrbxactive)
    return ok and active==true
end
local _, chatConfig = pcall(function()
    return game:GetService("TextChatService"):FindFirstChild("ChatInputBarConfiguration")
end)
local _, inputService = pcall(function() return game:GetService("UserInputService") end)
local chatFromShortcut, slashWasDown = false, false

local function robloxTextFocused()
    local chatOK, chatFocused = pcall(function() return chatConfig.IsFocused end)
    if chatOK and chatFocused == true then return true end
    local boxOK, textBox = pcall(function() return inputService:GetFocusedTextBox() end)
    if boxOK then return not not textBox end
    if chatOK and chatFocused == false then return false end
end

local function macroInputAllowed()
    if not robloxFocused() then return false end
    local focused = robloxTextFocused()
    if focused ~= nil then return not focused end

    -- External runtimes may only expose raw keyboard state.
    if type(iskeypressed) ~= "function" then return false end
    local slashDown = iskeypressed(0xBF)
    if slashDown and not slashWasDown then chatFromShortcut = true end
    slashWasDown = slashDown
    if iskeypressed(0x0D) or iskeypressed(0x1B) then chatFromShortcut = false end
    return not chatFromShortcut
end

local function macroReady()
    return type(iskeypressed)=="function" and type(keypress)=="function"
        and type(keyrelease)=="function" and type(isrbxactive)=="function"
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
local function showToggleNotice(on, feature)
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
    macroNotice.text.Text=feature .. (on and " is ON" or " is OFF")
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
-- The master switch starts off on every load.
local macroMasterSwitch=macrosTab:Toggle({
    Name="Macros Enabled",Default=false,
    Callback=function(on) macrosOn=on end,
})
macrosOn=macroMasterSwitch.Value==true
macrosTab:Keybind({Name="Toggle Macros",Default="F2",Flag="macro_toggle_key",Mode="Press",Callback=function()
    if not alive or not robloxFocused() or robloxTextFocused() then return end
    macroMasterSwitch:Set(not macroMasterSwitch.Value)
    macrosOn=macroMasterSwitch.Value==true
    print("[Macros] "..(macrosOn and "ON" or "OFF"))
    local noticeOK,noticeErr=pcall(showToggleNotice,macrosOn,"Macro")
    if not noticeOK then macroReport(tostring(noticeErr)) end
    if macrosOn and not macroReady() then
        macroReport("Requires iskeypressed, keypress, keyrelease, isrbxactive and task APIs.")
    end
end})
local function macroTap(vk)
    macroHeldKeys[vk]=true
    keypress(vk)
    keyrelease(vk)
    macroHeldKeys[vk]=nil
end
macrosTab:Section("Aizen Macros")
aizenToggle=macrosTab:Toggle({Name="Use Aizen Macro",Default=false,Callback=function(on)
    aizenOn=on
    if on and yusukeOn then
        yusukeOn=false
        if yusukeToggle then yusukeToggle:Set(false) end
    end
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
    if not alive or not macrosOn or not aizenOn or gojoOn or macroBusy or not macroInputAllowed() then return end
    if not macroReady() then
        macroReport("Requires iskeypressed, keypress, keyrelease, isrbxactive and task APIs.")
        return
    end
    macroBusy=true
    task.spawn(function()
        local ok,err=pcall(function()
            if not alive or not macrosOn or not aizenOn or gojoOn or not macroInputAllowed() then return end
            macroTap(selected.first)
            task.wait(selected.delay)
            if alive and macrosOn and aizenOn and not gojoOn and macroInputAllowed() then macroTap(selected.second) end
        end)
        for vk in pairs(macroHeldKeys)do
            pcall(keyrelease,vk)
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
gojoToggle=macrosTab:Toggle({Name="Use Gojo Macros",Default=false,Callback=function(on)
    gojoOn=on
    if on and yusukeOn then
        yusukeOn=false
        if yusukeToggle then yusukeToggle:Set(false) end
    end
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
    if not alive or not macrosOn or not gojoOn or macroBusy or not macroInputAllowed() then return end
    if not macroReady() then
        macroReport("Requires iskeypressed, keypress, keyrelease, isrbxactive and task APIs.")
        return
    end
    macroBusy=true
    task.spawn(function()
        local ok,err=pcall(function()
            for _,step in ipairs(selected.steps)do
                if not alive or not macrosOn or not gojoOn or not macroInputAllowed() then return end
                macroTap(step[1])
                if step[2]>0 then task.wait(step[2]) end
            end
        end)
        for vk in pairs(macroHeldKeys)do
            pcall(keyrelease,vk)
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
dioToggle=macrosTab:Toggle({Name="Use DIO Macros",Default=false,Callback=function(on)
    dioOn=on
    if on and yusukeOn then
        yusukeOn=false
        if yusukeToggle then yusukeToggle:Set(false) end
    end
    if on then
        aizenOn=false;gojoOn=false
        if aizenToggle then aizenToggle:Set(false) end
        if gojoToggle then gojoToggle:Set(false) end
    end
end})
local function runUptiltMacro(profile, isSelected)
    if not alive or not macrosOn or not isSelected() or macroBusy or not macroInputAllowed() then return end
    if not macroReady() or type(mouse1press)~="function" or type(mouse1release)~="function" then
        macroReport(profile.." requires mouse1press and mouse1release plus the keyboard macro APIs.")
        return
    end
    macroBusy=true
    task.spawn(function()
        local mouseHeld,spaceHeld=false,false
        local function active() return alive and macrosOn and isSelected() and macroInputAllowed() end
        local ok,err=pcall(function()
            if not active() then return end
            mouseHeld=true;mouse1press()
            task.wait(.230)
            if not active() then return end
            spaceHeld=true;keypress(0x20)
            task.wait(.210)
            if not active() then return end
            macroTap(0x33)
        end)
        if spaceHeld then pcall(keyrelease,0x20) end
        if mouseHeld then pcall(mouse1release) end
        for vk in pairs(macroHeldKeys)do
            pcall(keyrelease,vk);macroHeldKeys[vk]=nil
        end
        macroBusy=false
        if not ok then macroReport(tostring(err)) end
    end)
end
macrosTab:Keybind({Name="Uptilt",Default="X",Flag="dio_uptilt_key",Mode="Press",
    Callback=function() runUptiltMacro("DIO", function() return dioOn end) end})

macrosTab:Section("Yusuke Macros")
yusukeToggle=macrosTab:Toggle({Name="Use Yusuke Macros",Default=false,Callback=function(on)
    yusukeOn=on
    if on then
        aizenToggle:Set(false)
        gojoToggle:Set(false)
        dioToggle:Set(false)
    end
end})
macrosTab:Keybind({Name="Uptilt",Default="X",Flag="yusuke_uptilt_key",Mode="Press",
    Callback=function() runUptiltMacro("Yusuke", function() return yusukeOn end) end})

connection=game:GetService("RunService").Heartbeat:Connect(function()
    pcall(updateMacroNotice)
    if not alive then return end
    local inputOK, acceptsInput = pcall(macroInputAllowed)
    if not inputOK or not acceptsInput then return end
    local ok,err=pcall(update)
    if not ok then
        message("Tracking unavailable; see Matcha output.")
        if tostring(err) ~= lastError then lastError=tostring(err); print("[Nanami Timing] "..lastError) end
    end
    local otherOK,otherError=pcall(updateOtherTimings)
    if not otherOK and tostring(otherError)~=lastError then
        lastError=tostring(otherError);print("[ABA Timings] "..lastError)
    end
end)
local function mountHeadRide()
    --[[
        Anime Battle Arena - Head Ride 

        gotta use or own settings 
    depends on ping and  what not
    ]]

    local controls = {}
    local connections = {}
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

    local function gv(id, default)
        local control = controls[id]
        if control and control.Value ~= nil then
            if control.Options then return (table.find(control.Options, control.Value) or 1) - 1 end
            return control.Value
        end
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
    local rideKb
    local lockedTarget = nil
    local lastStatus   = "idle"
    local stepCount    = 0
    local stepRate     = 0

    -- ===========================================================================
    -- target list (polled - cheap, and avoids leaning on join/leave events)
    -- ===========================================================================
    task.spawn(function()
        while alive do
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
        local projected, screen, onScreen = pcall(WorldToScreen, pos)
        if not projected or not screen or not onScreen then return nil end
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
        if not isAlive(plr) or (gv("ride_team", false) and sameTeam(plr)) then return false end
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
        return rideKb and rideKb.Value and rideKb.State == true
    end

    local function rideEnabled()
        return gv("ride_on", false) and keybindActive() and macroInputAllowed()
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
            currentTarget, lockedTarget = nil, nil
            lastStatus = "idle"
            return
        end

        local me = myRoot()
        if not me or not isAlive(LocalPlayer) then
            currentTarget, lockedTarget = nil, nil
            lastStatus = "no living character"
            return
        end

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
            if climb > 0 then
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
                stepCount = stepCount + 1
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
                stepCount = stepCount + 1
                lastStatus = arrived and "riding (velocity)" or "climbing"
            else
                lastStatus = "velocity write failed"
            end
        end
    end

    local function updateRide()
        local ok, err = pcall(rideStep)
        if not ok then
            currentTarget, lockedTarget = nil, nil
            lastStatus = tostring(err)
        end
    end

    connections[#connections + 1] = RunService.Heartbeat:Connect(function()
        if not alive then return end
        if updateSource() == 0 then updateRide() end
    end)

    connections[#connections + 1] = RunService.RenderStepped:Connect(function()
        if not alive then return end
        if updateSource() == 1 then updateRide() end
    end)

    -- dedicated loop, so the correction rate is not capped by your frame rate
    task.spawn(function()
        while alive do
            if updateSource() == 2 then
                updateRide()
                local hz = math.clamp(tonumber(gv("ride_hz", 200)) or 200, 30, 1000)
                wait(1 / hz)
            else
                wait(0.1)
            end
        end
    end)

    -- sample the achieved rate once a second so the menu can show it
    task.spawn(function()
        while alive do
            wait(1)
            stepRate  = stepCount
            stepCount = 0
        end
    end)

    -- ===========================================================================
    -- target indicator
    -- ===========================================================================
    local circle, label, line

    local function makeDrawing(kind, configure)
        local drawing = safe(function() return Drawing.new(kind) end, nil)
        if drawing then
            pcall(function() drawing.Visible = false end)
            pcall(configure, drawing)
        end
        return drawing
    end

    local function hideDrawings()
        for _, drawing in pairs({circle, label, line}) do
            pcall(function() drawing.Visible = false end)
        end
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

    connections[#connections + 1] = RunService.RenderStepped:Connect(function()
        if not alive then return end
        local showMarker = gv("ride_marker", true)
        local showTracer = gv("ride_tracer", false)
        if not currentTarget or not rideEnabled() or not (showMarker or showTracer) then
            hideDrawings()
            return
        end

        local char = charOf(currentTarget)
        local head = partOf(char, "Head") or rootOf(char)
        local pos  = head and safe(function() return head.Position end, nil)
        if not pos then
            hideDrawings()
            return
        end

        local projected, screen, onScreen = pcall(WorldToScreen, pos)
        if not projected or not screen or not onScreen then
            hideDrawings()
            return
        end

        local col    = indicatorColour()
        local origin = myPos()
        local dist   = origin and (pos - origin).Magnitude or 0

        if showMarker then
            circle = circle or makeDrawing("Circle", function(draw)
                draw.Thickness, draw.Radius = 2, 14
            end)
            label = label or makeDrawing("Text", function(draw)
                draw.Center, draw.Outline = true, true
                draw.FontSize = 13
            end)
            if circle then
                pcall(function()
                    circle.Color, circle.Position = col, Vector2.new(screen.X, screen.Y)
                    circle.Visible = true
                end)
            end
            if label then
                pcall(function()
                    label.Color = col
                    label.Text = safe(function() return currentTarget.Name end, "?")
                        .. "  " .. math.floor(dist) .. " studs"
                    label.Position, label.Visible = Vector2.new(screen.X, screen.Y - 30), true
                end)
            end
        else
            if circle then pcall(function() circle.Visible = false end) end
            if label then pcall(function() label.Visible = false end) end
        end

        local viewport = showTracer and safe(function() return workspace.CurrentCamera.ViewportSize end, nil)
        if viewport then
            line = line or makeDrawing("Line", function(draw) draw.Thickness = 1 end)
            if line then
                pcall(function()
                    line.Color = col
                    line.From = Vector2.new(viewport.X / 2, viewport.Y)
                    line.To = Vector2.new(screen.X, screen.Y)
                    line.Visible = true
                end)
            end
        elseif line then
            pcall(function() line.Visible = false end)
        end
    end)

    -- ===========================================================================
    -- UI
    -- ===========================================================================

    local tab = window:Tab("Head Ride")
    local function toggle(id, name, default)
        controls[id] = tab:Toggle({Name = name, Default = default, Flag = id})
    end
    local function slider(id, name, min, max, default, increment)
        controls[id] = tab:Slider({Name = name, Min = min, Max = max, Default = default, Increment = increment, Flag = id})
    end
    local function dropdown(id, name, options, default)
        controls[id] = tab:Dropdown({Name = name, Options = options, Default = options[default + 1], Flag = id})
    end

    controls.ride_on = tab:Toggle({Name = "Enabled", Default = false})
    tab:Keybind({
        Name = "Toggle Head Ride", Default = "F3", Mode = "Press", Flag = "ride_toggle_key",
        Callback = function()
            if macroInputAllowed() then
                local enabled = controls.ride_on
                enabled:Set(not enabled.Value)
                pcall(showToggleNotice, enabled.Value, "Head Ride")
            end
        end,
    })
    tab:Section("Head Ride Settings")
    rideKb = tab:Keybind({
        Name = "Hold to Head Ride", Default = "9", Mode = "Hold", Flag = "ride_kb",
    })
    slider("ride_height", "Height above head", 0, 12, 1.5, 0.1)
    slider("ride_pred", "Prediction (s)", 0, 0.5, 0.32, 0.01)
    slider("ride_range", "Max range", 10, 500, 10, 1)
    dropdown("ride_mode", "Move by", {"Set position", "Velocity"}, 1)
    slider("ride_climb", "Rise speed (studs/s)", 0, 300, 87, 1)
    slider("ride_gain", "Velocity gain", 1, 40, 12, 0.1)
    dropdown("ride_tick", "Update on", {"Heartbeat", "RenderStepped", "Fast loop"}, 2)
    slider("ride_hz", "Fast loop rate (per second)", 30, 1000, 1000, 1)

    tab:Section("Target")
    dropdown("ride_target", "Pick by", {"Nearest", "Closest to crosshair"}, 0)
    toggle("ride_lock", "Stay on one target", true)
    toggle("ride_team", "Ignore teammates", true)
    tab:Button({Name = "Drop target", Callback = function()
        lockedTarget, currentTarget = nil, nil
    end})

    tab:Section("Indicator")
    toggle("ride_marker", "Show target marker", true)
    controls.ride_colour = tab:Colorpicker({Name = "Marker color", Default = Color3.fromRGB(255, 255, 255), Flag = "ride_colour"})
    toggle("ride_tracer", "Tracer line", true)

    tab:Section("Misc")
    local status = tab:Paragraph({Name = "Live status", Content = "idle"})
    task.spawn(function()
        while alive do
            local targetName = currentTarget and safe(function() return currentTarget.Name end, "?") or "none"
            local ping = safe(function() return GetPingValue() end, "?")
            status:Set(string.format("Status: %s | Updates: %d/s\nTarget: %s | Players: %d | Ping: %s ms",
                lastStatus, stepRate, targetName, #targets, tostring(ping)))
            wait(0.25)
        end
    end)
    tab:Button({Name = "Test movement write", Callback = function()
            -- yielding inside the render callback would stall the UI, so spawn it
            task.spawn(function()
                if not alive or not robloxFocused() then return end
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
                if not alive then return end
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
        end})
    tab:Button({Name = "Reset", Callback = function()
        controls.ride_on:Set(false)
        lockedTarget, currentTarget = nil, nil
        hideDrawings()
    end})

    return function()
        for _, connection in ipairs(connections) do
            pcall(function() connection:Disconnect() end)
        end
        hideDrawings()
        for _, drawing in pairs({circle, label, line}) do
            pcall(function() drawing:Remove() end)
        end
    end
end
destroyHeadRide = mountHeadRide()

print("[hahahahahaha] Loaded. Open Timings for Nanami, Camera Timings and Kokushibo, or Head Ride for Head Ride controls. Right Shift shows/hides the menu.")

