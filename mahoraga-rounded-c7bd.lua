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
local destroyMahoragaCounter
local destroyPlayerESP

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
    if destroyPlayerESP then pcall(destroyPlayerESP) end
    if destroyMahoragaCounter then pcall(destroyMahoragaCounter) end
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
local positionOffset,guiSizeOffset
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
    local sizeValue=ok and data and data.Offsets and data.Offsets.GuiObject and data.Offsets.GuiObject.Size
    if type(sizeValue)=="string" then sizeValue=tonumber(sizeValue) end
    if type(sizeValue)=="number" and sizeValue>0 and sizeValue<8192 and sizeValue%4==0 then guiSizeOffset=sizeValue end
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
-- Shared zoom timing detector. Character names are deliberately not a whitelist:
-- any move using the shared camera cue is handled, including repeated cues.
-- This infers an input cue from camera motion; ordinary cinematic zooms may match too.
local function newCameraTimingDetector()
    local state
    local function reset(camera,fov,now)
        state={camera=camera,last=fov,baseline=fov,extreme=fov,time=now,direction=0,returning=false}
    end
    return function(camera,fov,now)
        if not camera or type(fov)~="number" or fov~=fov or fov<=0 or fov>=180 then
            state=nil;return false
        end
        if not state or state.camera~=camera or now-state.time>.25 or now<state.time then
            reset(camera,fov,now);return false
        end
        local previous=state.last
        local delta=fov-previous
        state.last=fov;state.time=now
        if state.returning then
            local crossed=(fov-state.baseline)*state.direction<=.25
            if crossed then reset(camera,fov,now);return false end
            if delta*state.direction>.005 then
                -- A new pulse may begin before the preceding cue returns to 70 FOV.
                state.baseline=previous;state.extreme=fov
                state.direction=math.abs(delta)>=1.5 and (delta>0 and 1 or -1) or 0
                state.returning=false
            end
            return false
        end
        if state.direction==0 then
            local distance=fov-state.baseline
            if math.abs(distance)>=1.5 then
                state.direction=distance>0 and 1 or -1;state.extreme=fov
            end
            return false
        end
        if (fov-state.extreme)*state.direction>0 then state.extreme=fov end
        if delta*state.direction<-.0001 and (state.extreme-fov)*state.direction>=.005 then
            state.returning=true
            return true
        end
        return false
    end
end
local detectCameraTiming=newCameraTimingDetector()

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
flashTab:Toggle({Name="Camera Timings",Flag="auto_camera_timings_all",Default=false,Callback=function(on)
    cameraTimingsOn=on
    detectCameraTiming=newCameraTimingDetector()
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
            -- Timeline profiles own their cues; never double-click from FOV motion.
            detectCameraTiming=newCameraTimingDetector()
        elseif detectCameraTiming(cam,fov,now) then
            -- A cue expires on this frame; never send a delayed click into another move.
            local ready=now-lastProfileClick>=.08 and now-lastNanamiClick>=.08
            if ready and type(mouse1click)=="function" then
                mouse1click();lastProfileClick=now
            end
        end
    else
        detectCameraTiming=newCameraTimingDetector()
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
-- Capture camera orientation once; use the runner's native projection for drawing.
local function screenProjection(camera)
    if not camera then return nil end
    local view=camera.ViewportSize
    local frame={camera=camera,width=view.X,height=view.Y}
    pcall(function()
        local fov=camera.FieldOfView
        if type(fov)=="number" and fov>0 and fov<180 then
            frame.fov=fov
            frame.focal=view.Y/(2*math.tan(math.rad(fov)/2))
        end
    end)
    pcall(function() frame.position=camera.CFrame.Position end)
    pcall(function()
        local matrix={camera.CFrame:GetComponents()}
        if #matrix~=12 then return end
        for i=1,12 do
            if type(matrix[i])~="number" or matrix[i]~=matrix[i] then return end
        end
        local rightLength=matrix[4]^2+matrix[7]^2+matrix[10]^2
        local upLength=matrix[5]^2+matrix[8]^2+matrix[11]^2
        local backLength=matrix[6]^2+matrix[9]^2+matrix[12]^2
        if math.abs(rightLength-1)>.01 or math.abs(upLength-1)>.01 or math.abs(backLength-1)>.01 then return end
        frame.right=Vector3.new(matrix[4],matrix[7],matrix[10])
        frame.up=Vector3.new(matrix[5],matrix[8],matrix[11])
        frame.forward=Vector3.new(-matrix[6],-matrix[9],-matrix[12])
        if frame.focal then frame.matrix=matrix end
    end)
    local function readDirection(name)
        local ok,value=pcall(function() return camera.CFrame[name] end)
        if not ok or not value then return nil end
        local valid,x,y,z=pcall(function() return value.X,value.Y,value.Z end)
        if not valid or type(x)~="number" or type(y)~="number" or type(z)~="number" then return nil end
        local length=x*x+y*y+z*z
        if length<.99 or length>1.01 then return nil end
        return Vector3.new(x,y,z)
    end
    if not frame.right then frame.right=readDirection("RightVector") end
    if not frame.up then frame.up=readDirection("UpVector") end
    if not frame.forward then frame.forward=readDirection("LookVector") end
    return frame
end
local function projectToScreen(position,camera,frame)
    if not camera or not position then return nil,false end
    frame=frame or screenProjection(camera)
    local function accept(point,visible)
        if not point then return nil,false end
        local ok,x,y=pcall(function() return point.X,point.Y end)
        if not ok or type(x)~="number" or type(y)~="number" or x~=x or y~=y then return nil,false end
        local depth
        pcall(function() local z=point.Z;if type(z)=="number" then depth=z end end)
        if depth and depth<=0 then return nil,false,depth end
        if visible==nil then
            local v=camera.ViewportSize
            visible=x>=0 and y>=0 and x<=v.X and y<=v.Y
        end
        return point,visible,depth
    end
    -- Keep every point in a frame on the same native projection backend.
    if (not frame or not frame.backend or frame.backend=="WorldToScreen") and type(WorldToScreen)=="function" then
        local ok,point,visible=pcall(WorldToScreen,position)
        if ok and point then
            local accepted,onScreen,depth=accept(point,visible)
            if accepted or depth then
                if frame then frame.backend="WorldToScreen" end
                return accepted,onScreen,depth
            end
        end
        if frame and frame.backend=="WorldToScreen" then return nil,false end
    end
    if not frame or not frame.backend or frame.backend=="Viewport" then
        local ok,point,visible=pcall(function() return camera:WorldToViewportPoint(position) end)
        if ok and point then
            local accepted,onScreen,depth=accept(point,visible)
            if accepted or depth then
                if frame then frame.backend="Viewport" end
                return accepted,onScreen,depth
            end
        end
        if frame and frame.backend=="Viewport" then return nil,false end
    end
    -- Older runners lacking both methods can still use a valid camera matrix.
    if frame and frame.matrix then
        local m=frame.matrix
        local dx,dy,dz=position.X-m[1],position.Y-m[2],position.Z-m[3]
        local depth=-(dx*m[6]+dy*m[9]+dz*m[12])
        if depth<=.01 then return nil,false,depth end
        local x=frame.width/2+(dx*m[4]+dy*m[7]+dz*m[10])*frame.focal/depth
        local y=frame.height/2-(dx*m[5]+dy*m[8]+dz*m[11])*frame.focal/depth
        frame.backend="Matrix"
        return Vector2.new(x,y),x>=0 and y>=0 and x<=frame.width and y<=frame.height,depth
    end
    return nil,false
end

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

    local function notify(content,title,duration)
        pcall(function() window:Notify({Title=title or "Head Ride",Content=tostring(content),Duration=duration or 4}) end)
    end
    local velocityPart
    local function stopRideVelocity()
        local part=velocityPart
        velocityPart=nil
        if not part then return end
        local zero=Vector3.new(0,0,0)
        pcall(function() part.AssemblyLinearVelocity=zero end)
        pcall(function() part.Velocity=zero end)
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
        local cam = safe(function() return world.CurrentCamera end, nil)
        local screen,onScreen=projectToScreen(pos,cam)
        if not screen or not onScreen then return nil end
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
            stopRideVelocity()
            currentTarget, lockedTarget = nil, nil
            lastStatus = "idle"
            return
        end

        local me = myRoot()
        if not me or not isAlive(LocalPlayer) then
            stopRideVelocity()
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
            stopRideVelocity()
            lastStatus = "no target"
            return
        end

        local goal = goalPosition(currentTarget)
        if not goal then
            stopRideVelocity()
            lastStatus = "target has no head"
            return
        end

        local here = safe(function() return me.Position end, nil)
        if not here then
            stopRideVelocity()
            lastStatus = "cannot read position"
            return
        end

        local mode = tonumber(gv("ride_mode", 0)) or 0   -- 0 = position, 1 = velocity

        local delta   = goal - here
        local dist    = delta.Magnitude
        local climb   = tonumber(gv("ride_climb", 45)) or 45   -- studs/s, 0 = instant
        local arrived = dist <= 1.0

        if mode == 0 then
            stopRideVelocity()
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
            if velocityPart and velocityPart~=me then stopRideVelocity() end
            local ok = pcall(function() me.AssemblyLinearVelocity = want end)
            if not ok then
                ok = pcall(function() me.Velocity = want end)
            end
            if ok then
                velocityPart=me
                stepCount = stepCount + 1
                lastStatus = arrived and "riding (velocity)" or "climbing"
            else
                stopRideVelocity()
                lastStatus = "velocity write failed"
            end
        end
    end

    local function updateRide()
        local ok, err = pcall(rideStep)
        if not ok then
            stopRideVelocity()
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

        local screen,onScreen=projectToScreen(pos,world.CurrentCamera)
        if not screen or not onScreen then
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
        stopRideVelocity()
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
        stopRideVelocity()
        lockedTarget, currentTarget = nil, nil
        hideDrawings()
    end})

    return function()
        stopRideVelocity()
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

local function mountPlayerESP()
    local Players=game:GetService("Players")
    local RunService=game:GetService("RunService")
    local espTab=window:Tab("ESP")
    local modeOn=espTab:Toggle({Name="Mode bar ESP",Default=true,Flag="player_mode_esp"})
    local movesOn=espTab:Toggle({Name="Move cooldown ESP",Default=true,Flag="player_move_esp"})
    local selfOn=espTab:Toggle({Name="Show yourself",Default=false,Flag="player_esp_show_self"})
    local teamFilter=espTab:Toggle({Name="Hide teammates",Default=false,Flag="player_esp_hide_team"})
    local range=espTab:Slider({Name="Maximum distance",Min=100,Max=3000,Default=1000,Increment=50,Flag="player_esp_range"})
    local records={}
    local drawingValues={}
    local stopped=false
    local capture
    local heartbeat
    local green=Color3.fromRGB(90,245,125)
    local modeRed=Color3.fromRGB(235,65,65)
    local secondPurple=Color3.fromRGB(170,85,255)
    local red=Color3.fromRGB(255,110,110)
    local gray=Color3.fromRGB(185,185,195)
    local white=Color3.fromRGB(245,245,250)
    local function number(value)
        return type(value)=="number" and value==value and value>-math.huge and value<math.huge
    end
    local function playerKey(player)
        if not player then return "none" end
        return tostring(player.Name)
    end
    local function characterKey(character)
        if not character then return nil end
        local ok,address=pcall(function() return character.Address end)
        if ok and number(address) and address>0 then return address end
        return character
    end
    local function child(parent,name)
        if not parent then return nil end
        local ok,result=pcall(function() return parent:FindFirstChild(name) end)
        if ok then return result end
    end
    local function componentCooldown(move,attributeName,readString)
        -- version-2c6fd5e09aaf4cfa: Instance.ComponentMap (+0x38) is a
        -- vector of {component pointer, type id} entries, each 0x10 bytes.
        -- Component 9 owns either one attribute (+0x08) or a counted attribute
        -- array (count +0x08, capacity +0x0C, data +0x18). Both layouts verified live.
        if type(memory_read)~="function" then return nil end
        attributeName=attributeName or "COOLDOWN"
        local ok,result=pcall(function()
            local address=move.Address
            if not number(address) or address<4096 then return nil end
            local map=memory_read("uintptr_t",address+0x38)
            if not number(map) or map<4096 then return nil end
            local first,last=memory_read("uintptr_t",map),memory_read("uintptr_t",map+8)
            if not number(first) or not number(last) or first<4096 or last<first
                or (last-first)%16~=0 or last-first>16*64 then return nil end
            for entry=first,last-1,16 do
                local rawKind=memory_read("int",entry+8)
                local kind=number(rawKind) and rawKind%65536 or -1
                if kind==9 then
                    local component=memory_read("uintptr_t",entry)
                    if not number(component) or component<4096 then return nil end
                    local layout=memory_read("int",component)
                    local count,data=1,memory_read("uintptr_t",component+8)
                    if layout==1 then
                        count=memory_read("int",component+8)
                        local capacity=memory_read("int",component+12)
                        if not number(count) or not number(capacity) or count<0 or count>128 or capacity<count or capacity>512 then return nil end
                        data=memory_read("uintptr_t",component+0x18)
                    elseif layout~=0 then return nil end
                    if not number(data) or data<4096 then return nil end
                    for index=0,count-1 do
                        local attribute=data+index*0x58
                        local key=memory_read("uintptr_t",attribute)
                        if not number(key) or key<4096 then return nil end
                        local length=memory_read("int",key+0x10)
                        if length==#attributeName then
                            local capacity=memory_read("int",key+0x18)
                            if number(capacity) and capacity>=8 and capacity<=256 then
                                local text=key
                                if capacity>=16 then text=memory_read("uintptr_t",key) end
                                if number(text) and text>=4096 and memory_read("string",text)==attributeName then
                                    if readString then
                                        local address=attribute+0x18
                                        local size=memory_read("int",address+0x10)
                                        local cap=memory_read("int",address+0x18)
                                        if not number(size) or not number(cap) or size<1 or size>100 or cap<size or cap>256 then return nil end
                                        local dataAddress=cap>=16 and memory_read("uintptr_t",address) or address
                                        if not number(dataAddress) or dataAddress<4096 then return nil end
                                        local text=memory_read("string",dataAddress)
                                        if type(text)=="string" and #text==size then return text end
                                        return nil
                                    end
                                    local value=memory_read("double",attribute+0x18)
                                    if number(value) and value>=0 and value<=20 then return value end
                                    return nil
                                end
                            end
                        end
                    end
                    return nil
                end
            end
        end)
        if ok then return result end
        return nil
    end
    local function attribute(parent,name)
        if not parent then return nil end
        local ok,value=pcall(function() return parent:GetAttribute(name) end)
        if ok and value~=nil then return value end
        local success,attributes=pcall(function() return parent:GetAttributes() end)
        if success and type(attributes)=="table" and attributes[name]~=nil then return attributes[name] end
    end
    local function numeric(parent,name)
        local value=attribute(parent,name)
        if number(value) then return value end
        local obj=child(parent,name)
        if not obj then return nil end
        local ok,result=pcall(function() return obj.Value end)
        if ok and number(result) then return result end
    end
    local function constrainedCharge(charge)
        -- Verified constrained-value layout for Roblox version-2c6fd5e09aaf4cfa:
        -- MaxValue +0xA0, MinValue +0xA8, Value +0xB0.
        -- DoubleConstrainedValue uses Float64; IntConstrainedValue uses integers.
        -- Matcha's generic Value offset (+0xA0) can return the maximum as Value.
        -- Read exactly these fields, never write memory or assume a charge cap.
        if type(memory_read)~="function" then return nil end
        local ok,current,minimum,maximum=pcall(function()
            local class=charge.ClassName
            if class~="DoubleConstrainedValue" and class~="IntConstrainedValue" then return nil end
            local address=charge.Address
            if not number(address) or address<=0 then return nil end
            local kind=class=="IntConstrainedValue" and "int" or "double"
            if kind=="int" then
                -- These nonnegative meter values must fit the bounded low word.
                for _,offset in ipairs({0xA4,0xAC,0xB4}) do
                    if memory_read("int",address+offset)~=0 then return nil end
                end
            end
            return memory_read(kind,address+0xB0),memory_read(kind,address+0xA8),memory_read(kind,address+0xA0)
        end)
        if ok and number(current) and number(minimum) and number(maximum)
            and minimum>=0 and maximum>minimum and maximum<=1000000
            and current>=minimum and current<=maximum then
            return (current-minimum)/(maximum-minimum),current,minimum,maximum
        end
        return nil
    end
    local function readMode(player,character,secondary)
        -- ABA stores awakening charge on the Player as a constrained value.
        -- Read its actual maximum; do not assume that 100 or 1 means full.
        local names=secondary and {"GatesBar","BloodBar","RoomBar","KaidoBar","AstaBar","TimeStopBar","RagnaBar","IndraArrowBar","SecondBar","Charge2","SecondCharge","SecondaryCharge","SecondModeCharge","SecondModeBar","SecondaryBar","ModeBar2","Mode2","SecondMode","Awakening2","Ultimate2"} or {"Charge"}
        local sources={player,character,child(player,"Stats"),child(player,"PlayerData"),child(character,"Stats")}
        for i=1,5 do
            local candidates={}
            for _,name in ipairs(names) do
                local meter=child(sources[i],name)
                if meter then candidates[#candidates+1]=meter end
            end
            if secondary and sources[i] then
                -- Discover shared secondary meters without a character whitelist.
                -- Require both a secondary name and a meter name to avoid health,
                -- souls, kill counters, and other unrelated constrained values.
                local ok,children=pcall(function() return sources[i]:GetChildren() end)
                if ok and type(children)=="table" and #children<=256 then
                    for _,meter in ipairs(children) do
                        local low=tostring(meter.Name):lower()
                        local second=low:find("second",1,true) or low:match("2$")
                        local bar=low:find("bar",1,true) or low:find("charge",1,true)
                            or low:find("mode",1,true) or low:find("awak",1,true) or low:find("ultimate",1,true)
                        if second and bar then
                            local found=false
                            for _,candidate in ipairs(candidates) do
                                if characterKey(candidate)==characterKey(meter) then found=true;break end
                            end
                            if not found then candidates[#candidates+1]=meter end
                        end
                    end
                end
            end
            for _,charge in ipairs(candidates) do
                if charge then
                    local ratio=constrainedCharge(charge)
                    if ratio~=nil then return ratio end
                    local ok,current,maximum=pcall(function() return charge.Value,charge.MaxValue end)
                    local minOk,minimum=pcall(function() return charge.MinValue end)
                    if not minOk then minimum=nil end
                    if not ok or not number(maximum) then
                        local valueOk,value=pcall(function() return charge.Value end)
                        current=valueOk and value or nil
                        maximum=numeric(charge,"MaxValue") or numeric(charge,"Max")
                            or numeric(sources[i],secondary and "MaxCharge2" or "MaxCharge")
                    end
                    minimum=number(minimum) and minimum or 0
                    if number(current) and number(maximum) and maximum>minimum and current>=minimum and current<=maximum then
                        return (current-minimum)/(maximum-minimum)
                    end
                end
            end
        end
        local containers={}
        local function add(obj) if obj then containers[#containers+1]=obj end end
        add(character);add(player);add(child(player,"Stats"));add(child(player,"PlayerData"))
        add(child(character,"Stats"))
        for _,obj in ipairs(containers) do
            for _,key in ipairs(secondary and {"Mode2Percent","SecondModePercent","SecondModePercentage","Awakening2Percent"} or {"ModePercent","ModePercentage","AwakeningPercent"}) do
                local value=numeric(obj,key)
                if number(value) and value>=0 and value<=100 then return value/100 end
            end
            for _,key in ipairs(secondary and {"Mode2Ratio","SecondModeRatio","Awakening2Ratio"} or {"ModeRatio","AwakeningRatio"}) do
                local value=numeric(obj,key)
                if number(value) and value>=0 and value<=1 then return value end
            end
            for _,pair in ipairs(secondary and {{"Mode2","MaxMode2"},{"SecondMode","MaxSecondMode"},{"SecondModeCharge","MaxSecondModeCharge"},{"Awakening2","MaxAwakening2"}} or {{"Mode","MaxMode"},{"Mode","ModeMax"},{"ModeCharge","MaxModeCharge"},{"Awakening","MaxAwakening"}}) do
                local value,maximum=numeric(obj,pair[1]),numeric(obj,pair[2])
                local meter=child(obj,pair[1])
                if not number(maximum) and meter then maximum=attribute(meter,"MaxValue") or attribute(meter,"Max") end
                if number(value) and number(maximum) and maximum>0 and value>=0 and value<=maximum then
                    return value/maximum
                end
            end
        end
        if secondary then
            -- GT Goku's extra awakening uses replicated damage, not Charge2.
            -- Verified against Ultimate2.Bar: normal stage /300; FullPower /225.
            local damage=child(character,"DamageDone")
            if damage then
                -- Some characters (including Jogo) expose a constrained damage
                -- meter with its own actual limits, unlike GT Goku's NumberValue.
                local ratio=constrainedCharge(damage)
                if ratio~=nil then return ratio end
                local ok,value=pcall(function() return damage.Value end)
                if ok and number(value) and value>=0 then
                    local maximum=numeric(damage,"MaxValue") or numeric(damage,"Max")
                        or numeric(character,"MaxDamageDone")
                    local name=componentCooldown(player,"LastLoadedChar",true)
                        or attribute(player,"LastLoadedChar") or attribute(character,"SpawnChar")
                        or attribute(character,"LastLoadedChar")
                    if not number(maximum) and name=="Goku [GT]" then
                        local sidebar=componentCooldown(damage,"Sidebar",true) or attribute(damage,"Sidebar")
                        maximum=sidebar=="FullPower" and 225 or 300
                    end
                    if number(maximum) and maximum>0 then return math.min(1,value/maximum) end
                end
            end
        end
        return nil
    end
    local function hudCooldown(player,slot,name)
        if not slot then return nil end
        -- Only inspect THIS player's GUI. Never substitute the local player's HUD
        -- for another player's hidden data.
        local rows=child(child(child(player,"PlayerGui"),"HUD"),"Moves")
        local row=child(rows,tostring(slot))
        local cd=child(row,"CD")
        if not cd then return nil end
        local display=child(row,"TextLabel")
        local ok,title=pcall(function() return display and display.Text end)
        if ok and type(title)=="string" and title~="" and title~=name then return nil end
        local function progress(scale)
            if number(scale) and scale>=-1.001 and scale<=.001 then
                return math.max(0,math.min(20,(1+scale)*20))
            end
        end
        local ok,scale=pcall(function() return cd.Size.Y.Scale end)
        if ok then local value=progress(scale);if value~=nil then return value end end
        if guiSizeOffset and type(memory_read)=="function" then
            local success,value=pcall(function() return memory_read("float",cd.Address+guiSizeOffset+8) end)
            if success then local result=progress(value);if result~=nil then return result end end
        end
        local success,height,rowHeight=pcall(function() return cd.AbsoluteSize.Y,row.AbsoluteSize.Y end)
        if success and number(height) and number(rowHeight) and rowHeight>0 then
            local fraction=math.abs(height)/rowHeight
            if fraction>=0 and fraction<=1.001 then return math.max(0,math.min(20,(1-fraction)*20)) end
        end
        return nil
    end
    local function readCooldown(move)
        local direct=componentCooldown(move)
        if direct~=nil then return direct,"component attribute" end
        local ok,value=pcall(function() return move:GetAttribute("COOLDOWN") end)
        if ok and number(value) then return value,"attribute" end
        local obj=child(move,"COOLDOWN")
        if obj then
            local readable,current=pcall(function() return obj.Value end)
            if readable and number(current) then return current,"value" end
        end
        -- Match ABA's own client: (GetAttribute("COOLDOWN") or 20).
        -- Reports confirm that the same move gains this attribute while recharging
        -- and can lose it again. Successful nil reads are READY for every player.
        -- GetAttributes can return a value dictionary or a names-only array.
        -- Names-only entries cannot recover a failed numeric read.
        local readable,attributes=pcall(function() return move:GetAttributes() end)
        if readable and type(attributes)=="table" and number(attributes.COOLDOWN) then
            return attributes.COOLDOWN,"attribute fallback"
        end
        if ok and value==nil then return 20,"ready default" end
        return nil,"read failed"
    end
    local function trackCooldown(history,key,cd,source,now)
        local state=history[key]
        if not state then state={sources={},cycle=0,revision=0};history[key]=state end
        local ranks={HUD=1,["attribute fallback"]=2,value=3,attribute=3,["component attribute"]=4}
        local live=ranks[source]~=nil
        local function beginCycle()
            state.sources={};state.active=true;state.rate=nil;state.endsAt=nil
            state.pendingReset=nil;state.correction=nil;state.readySince=nil
            state.last=nil;state.seen=nil;state.fitAt=now
            state.cycle=state.cycle+1;state.revision=state.revision+1
            state.displaySeconds=nil
        end
        local function prediction()
            if state.active and state.rate and state.last and state.seen
                and now-state.seen<=.5 and state.endsAt and state.endsAt>now then
                return math.min(19.999,state.last+math.max(0,now-state.seen)*state.rate),"estimated"
            end
            return nil,"unavailable"
        end
        local function markReady()
            state.active=false;state.last=20;state.seen=now;state.endsAt=nil;state.rate=nil
            state.readySince=nil;state.pendingReset=nil;state.displaySeconds=nil
            return 20,source
        end
        -- Actual absent-attribute readiness does not depend on estimating a rate.
        local readyRead=(live and number(cd) and cd>=20 and cd<=20.001)
            or source=="ready default"
        if readyRead then
            if not state.active then return markReady() end
            state.readySince=state.readySince or now
            if now-state.readySince>=.04 then return markReady() end
            if state.last then return math.min(19.999,state.last),"last observed" end
            return nil,"unavailable"
        end
        state.readySince=nil
        if not live or not number(cd) or cd<0 or cd>=20 then return prediction() end
        if not state.active then beginCycle() end
        local series=state.sources[source]
        if not series then
            series={points={},seen=now,progressAt=now,high=cd}
            state.sources[source]=series
        end
        -- Compare only against this source's own progress, never a different HUD.
        local tolerance=source=="HUD" and .15 or .05
        if series.last and cd<series.last-tolerance then
            local pending=state.pendingReset
            if not pending or pending.source~=source or cd<pending.value-tolerance then
                pending={source=source,value=cd,since=now,count=1}
                state.pendingReset=pending
            else pending.count=pending.count+1;pending.value=cd end
            if pending.count>=3 and now-pending.since>=.08 then
                beginCycle()
                series={points={},seen=now,progressAt=now,high=cd}
                state.sources[source]=series
            else return prediction() end
        elseif state.pendingReset and state.pendingReset.source==source then
            state.pendingReset=nil
        end
        -- A stalled progress feed invalidates its clock, even if reads succeed.
        local meaningful=source=="HUD" and .08 or .02
        if cd>(series.high or cd)+meaningful then
            local interval=now-(series.progressAt or now)
            if interval>0 then series.cadence=series.cadence and series.cadence*.7+interval*.3 or interval end
            if series.paused then series.points={};series.rate=nil;series.endsAt=nil end
            series.high=cd;series.progressAt=now;series.paused=false
        end
        series.last=cd;series.seen=now
        local stallLimit=math.max(.75,math.min(3,(series.cadence or .5)*3))
        series.paused=now-(series.progressAt or now)>stallLimit
        local points=series.points
        if #points==0 or (math.abs(cd-points[#points].cd)>.001 and now-points[#points].time>=.025) then
            points[#points+1]={cd=cd,time=now}
            while #points>32 or (#points>2 and now-points[1].time>1.6) do table.remove(points,1) end
        end
        if series.paused then series.endsAt=nil;series.rate=nil end
        if not series.paused and #points>=2 and now-points[1].time>=.15 then
            local slopes={}
            for i=1,#points-1 do
                for j=i+1,#points do
                    local dt=points[j].time-points[i].time
                    if dt>=.1 then
                        local rate=(points[j].cd-points[i].cd)/dt
                        if rate>.01 and rate<=400 then slopes[#slopes+1]=rate end
                    end
                end
            end
            if #slopes>=1 then
                local function median(values)
                    table.sort(values)
                    local n=#values
                    if n%2==0 then return (values[n/2]+values[n/2+1])/2 end
                    return values[(n+1)/2]
                end
                local rate=median(slopes)
                local low=slopes[math.max(1,math.floor(#slopes*.25))]
                local high=slopes[math.max(1,math.floor(#slopes*.75))]
                local first=points[1]
                local span=now-first.time
                local gain=cd-first.cd
                local consistent=#slopes<6 or (high-low)/rate<=.5
                -- Coarse/unevenly replicated meters can lack a tight slope cluster.
                -- Their longer observed span still gives a useful seconds estimate.
                if not consistent and span>=.4 and gain>.05 then
                    rate=gain/span;consistent=rate>.01 and rate<=400
                end
                if consistent then
                    local intercepts={}
                    for _,point in ipairs(points) do intercepts[#intercepts+1]=point.cd-rate*(point.time-first.time) end
                    local candidate=first.time+(20-median(intercepts))/rate
                    if candidate>now then series.rate=rate;series.endsAt=candidate end
                end
            end
        end
        -- Source histories survive switching. Prefer fresh direct data to the HUD.
        local chosen,chosenSource,rank
        for name,entry in pairs(state.sources) do
            if now-entry.seen<=.5 and not entry.paused and entry.endsAt
                and entry.endsAt>now and (not rank or ranks[name]>rank) then
                chosen,chosenSource,rank=entry,name,ranks[name]
            end
        end
        if chosen then
            local candidate=chosen.endsAt
            if not state.endsAt then
                state.endsAt=candidate;state.revision=state.revision+1
                state.correction=nil
            elseif math.abs(candidate-state.endsAt)>.35 then
                local correction=state.correction
                if not correction or correction.source~=chosenSource or math.abs(candidate-correction.value)>.35 then
                    state.correction={source=chosenSource,value=candidate,since=now,count=1}
                else
                    correction.count=correction.count+1;correction.value=correction.value*.5+candidate*.5
                    if correction.count>=3 and now-correction.since>=.15 then
                        state.endsAt=correction.value;state.revision=state.revision+1;state.correction=nil
                    end
                end
            else
                local limit=math.max(0,now-(state.fitAt or now))*.1
                state.endsAt=state.endsAt+math.max(-limit,math.min(limit,candidate-state.endsAt))
                state.correction=nil
            end
            state.rate=chosen.rate
        else
            state.endsAt=nil;state.rate=nil;state.correction=nil
        end
        state.fitAt=now;state.last=cd;state.seen=now
        return cd,source
    end
    local function cooldownSeconds(state,now)
        if not state or not state.active or not number(state.endsAt) then return nil end
        local remaining=math.max(0,state.endsAt-now)
        local seconds=math.max(1,math.ceil(remaining-.000001))
        if state.displayCycle~=state.cycle then
            state.displayCycle=state.cycle
            state.displaySeconds=nil;state.displayIncrease=nil
        end
        local previous=state.displaySeconds
        if previous and seconds>previous then
            local allowIncrease=false
            -- Absorb small boundary corrections by holding the current number.
            -- A real extension must persist, rather than be one revised estimate.
            if remaining-previous>=.75 then
                local pending=state.displayIncrease
                if not pending or math.abs(state.endsAt-pending.endsAt)>.2 then
                    pending={since=now,endsAt=state.endsAt,count=1}
                    state.displayIncrease=pending
                else
                    pending.count=pending.count+1
                    pending.endsAt=pending.endsAt*.8+state.endsAt*.2
                end
                local fraction=remaining-math.floor(remaining)
                local awayFromBoundary=fraction>=.25 or fraction<.000001
                if pending.count>=5 and now-pending.since>=.6 and awayFromBoundary then
                    allowIncrease=true
                    state.displayIncrease=nil
                end
            else state.displayIncrease=nil end
            if not allowIncrease then seconds=previous end
        else
            state.displayIncrease=nil
        end
        state.displaySeconds=seconds;state.displayRevision=state.revision
        return seconds
    end
    local guardbreakKeys={"Guardbreak","GuardBreak","Guardbreaks","GuardBreaks",
        "GUARDBREAK","GUARDBREAKS","GuardBreakMove","CanGuardBreak","BreaksGuard","BlockBreak","Blockbreak","GB"}
    local function guardbreakBoolean(value)
        if type(value)=="boolean" then return value end
        if number(value) then return value>0 end
        if type(value)=="string" then
            local low=value:lower():gsub("[%s_%-]","")
            if low=="true" or low=="yes" or low=="1" or low=="on"
                or low=="guardbreak" or low=="guardbreaks" or low=="blockbreak" then return true end
            if low=="false" or low=="no" or low=="0" or low=="off" or low=="none" then return false end
        end
        return nil
    end
    -- Game source: LocalCharacterScriptNew.UpdateMoveNames uses
    -- move:HasTag("Guardbreaks"), or that tag on the selected variant value.
    local guardCollection
    pcall(function() guardCollection=game:GetService("CollectionService") end)
    local taggedGuardMoves,nextGuardScan={},0
    local function refreshGuardbreakTags(now)
        now=now or (tick and tick() or os.clock())
        if now<nextGuardScan then return end
        nextGuardScan=now+.25
        local ok,items=pcall(function() return guardCollection:GetTagged("Guardbreaks") end)
        if ok and type(items)=="table" then
            local found={}
            for _,item in ipairs(items) do found[characterKey(item)]=true end
            taggedGuardMoves=found
        end
    end
    local function gameTag(instance,tag)
        if not instance then return nil end
        if tag=="Guardbreaks" and taggedGuardMoves[characterKey(instance)] then return true end
        local knownFalse=false
        local ok,value=pcall(function() return instance:HasTag(tag) end)
        if ok and type(value)=="boolean" then
            if value then return true end
            knownFalse=true
        end
        local tagsOK,tags=pcall(function() return instance:GetTags() end)
        if tagsOK and type(tags)=="table" then
            for key,value in pairs(tags) do
                if value==tag or (key==tag and value==true) then return true end
            end
            knownFalse=true
        end
        local collectionOK,present=pcall(function() return guardCollection:HasTag(instance,tag) end)
        if collectionOK and type(present)=="boolean" then
            if present then return true end
            knownFalse=true
        end
        if knownFalse then return false end
        return nil
    end
    local function moveHUDRow(player,slot)
        if not slot then return nil end
        return child(child(child(child(player,"PlayerGui"),"HUD"),"Moves"),tostring(slot))
    end
    local function valueOf(object)
        if not object then return nil end
        local ok,value=pcall(function() return object.Value end)
        if ok then return value end
    end
    local function selectedMove(player,character,move,config,slot)
        local name=valueOf(child(config,"NewName"))
        if type(name)~="string" or name=="" then name=tostring(move.Name) end
        -- The player's own visible HUD already resolves air/block/run variants.
        local row=moveHUDRow(player,slot)
        local ok,hudName=pcall(function() return child(row,"TextLabel").Text end)
        if ok and type(hudName)=="string" and hudName~="" then
            for _,key in ipairs({"AirVar","AttackVariant","EvasiveVariant","RunVar","BlockVar","MoveVar","NeutralVar"}) do
                local variant=child(config,key)
                if variant and valueOf(variant)==hudName then return hudName,variant end
            end
            if hudName==name or hudName==valueOf(child(config,"ChangedName")) then return hudName,move end
        end
        -- Mirror the source's variant priority when replicated state is exposed.
        local humanoid=character and character:FindFirstChildOfClass("Humanoid")
        local air=false
        pcall(function()
            local current=tostring(humanoid:GetState())
            air=current:find("Freefall",1,true)~=nil or current:find("Jumping",1,true)~=nil
        end)
        local moving
        pcall(function() moving=humanoid.MoveDirection.Magnitude>0 end)
        local running=guardbreakBoolean(attribute(character,"Running"))
            or guardbreakBoolean(attribute(character,"Sprinting"))
            or guardbreakBoolean(valueOf(child(character,"Running")))
        local blocking=guardbreakBoolean(valueOf(child(character,"Blocking")))==true
        local choices={
            {"AirVar",air},
            {"AttackVariant",gameTag(character,"AttackVariant")==true},
            {"EvasiveVariant",gameTag(character,"creator")==true},
            {"RunVar",running==true},
            {"BlockVar",blocking},
            {"MoveVar",moving==true},
            {"NeutralVar",moving==false},
        }
        for _,choice in ipairs(choices) do
            local variant=choice[2] and child(config,choice[1]) or nil
            local title=valueOf(variant)
            if variant and type(title)=="string" and title~="" then return title,variant end
        end
        return name,move
    end
    local function hudGuardbreak(player,slot,name)
        if not slot then return nil end
        local rows=child(child(child(player,"PlayerGui"),"HUD"),"Moves")
        local row=child(rows,tostring(slot))
        if not row then return nil end
        local title=child(row,"TextLabel")
        local titleOK,titleText=pcall(function() return title and title.Text end)
        if titleOK and type(titleText)=="string" and titleText~="" and titleText~=name then return nil end
        local rowOK,rowVisible=pcall(function() return row.Visible end)
        if rowOK and rowVisible==false then return nil end
        local info=child(row,"InfoTag")
        if info then
            local infoOK,visible=pcall(function() return info.Visible end)
            if infoOK and type(visible)=="boolean" then return visible end
        end
        local ok,labels=pcall(function() return row:GetChildren() end)
        if not ok or type(labels)~="table" then return nil end
        for _,label in ipairs(labels) do
            local readable,text,visible=pcall(function() return label.Text,label.Visible end)
            if readable and visible==true and type(text)=="string" then
                local low=text:lower():gsub("[%s_%-]","")
                if low=="guardbreak" or low=="guardbreaks" or low=="blockbreak" then return true end
            end
        end
        return nil
    end
    local function readGuardbreak(player,move,config,slot,name,target)
        local hud=hudGuardbreak(player,slot,name)
        if hud~=nil then return hud end
        -- UpdateMoves also listens to this exact attribute for runtime changes.
        local override=guardbreakBoolean(attribute(move,"GUARDBREAKS"))
        if override~=nil then return override end
        target=target or move
        local tagged=gameTag(target,"Guardbreaks")
        if tagged~=nil then return tagged end
        local containers=target==move and {config,move} or {target}
        for _,container in ipairs(containers) do
            for _,key in ipairs(guardbreakKeys) do
                local flag=guardbreakBoolean(attribute(container,key))
                if flag~=nil then return flag end
                local marker=child(container,key)
                if marker then
                    local ok,value=pcall(function() return marker.Value end)
                    if ok then
                        local markerFlag=guardbreakBoolean(value)
                        if markerFlag~=nil then return markerFlag end
                    end
                    local classOK,class=pcall(function() return marker.ClassName end)
                    if classOK and (class=="Folder" or class=="Configuration") then return true end
                end
            end
        end
        return nil
    end
    local function readMoves(player,character,record,now)
        local moves,seen={},{}
        refreshGuardbreakTags(now)
        if record then record.cooldowns=record.cooldowns or {} end
        local present={}
        local foldersSeen={}
        local function scan(container,depth)
            if not container or foldersSeen[container] then return end
            foldersSeen[container]=true
            local success,children=pcall(function() return container:GetChildren() end)
            if not success then return end
            for _,move in ipairs(children) do
                local config=child(move,".Config")
                local identity=characterKey(move)
                if config and move.ClassName=="Configuration" and not seen[identity] then
                    seen[identity]=true
                    local slot
                    local ok,markers=pcall(function() return config:GetChildren() end)
                    if ok then
                        for _,marker in ipairs(markers) do
                            local candidate=tonumber(tostring(marker.Name):match("^Slot(%d+)$"))
                            if candidate and candidate>=1 and candidate<=99 and (not slot or candidate<slot) then slot=candidate end
                        end
                    end
                    if not slot then
                        local candidate=numeric(config,"Slot")
                        if number(candidate) and candidate>=1 and candidate<=99 and candidate%1==0 then slot=candidate end
                    end
                    local name,guardTarget=selectedMove(player,character,move,config,slot)
                    local cd,source=readCooldown(move)
                    local hud=hudCooldown(player,slot,tostring(name))
                    local previous=record and record.cooldowns[tostring(identity)]
                    local primary=previous and previous.sources and previous.sources[source]
                    local stalled=primary and number(cd) and number(primary.last)
                        and cd<=primary.last+.02 and now-(primary.progressAt or now)>.35
                    if number(hud) and (not number(cd) or source=="ready default"
                        or (stalled and math.abs(hud-cd)>.15)) then
                        cd,source=hud,"HUD"
                    end
                    if not number(cd) then cd,source=nil,"unavailable" end
                    -- NewName can change with charges/variants; the underlying move
                    -- instance owns the cooldown independently of its display name.
                    local key=tostring(identity)
                    present[key]=true
                    moves[#moves+1]={name=tostring(name),slot=slot,cd=number(cd) and cd or nil,
                        source=source,instance=identity,moveObject=move,moveConfig=config}
                elseif depth>0 and move.ClassName=="Folder" and move.Name~=".Config" then
                    scan(move,depth-1)
                end
            end
        end
        scan(child(player,"Backpack"),2);scan(character,2)
        -- Match ABA's fallback assignment for moves without a Slot marker.
        local occupied={}
        for _,move in ipairs(moves) do if move.slot then occupied[move.slot]=true end end
        for _,move in ipairs(moves) do
            if not move.slot then
                for slot=1,5 do
                    if not occupied[slot] then move.slot=slot;occupied[slot]=true;break end
                end
                local value=hudCooldown(player,move.slot,move.name)
                if value~=nil and move.source~="component attribute" and move.source~="attribute"
                    and move.source~="value" and move.source~="attribute fallback" then
                    move.cd,move.source=value,"HUD"
                end
            end
        end
        for _,move in ipairs(moves) do
            -- Resolve again after inferred slots are assigned, so the correct
            -- HUD variant/InfoTag also works for moves lacking Slot markers.
            if move.moveObject then
                local title,target=selectedMove(player,character,move.moveObject,move.moveConfig,move.slot)
                move.name=title
                move.guardbreak=readGuardbreak(player,move.moveObject,move.moveConfig,move.slot,title,target)
            end
            if move.guardbreak==nil then move.guardbreak=hudGuardbreak(player,move.slot,move.name) end
            if record then
                move.cd,move.source=trackCooldown(record.cooldowns,tostring(move.instance),move.cd,move.source,now)
            end
            local history=record and record.cooldowns[tostring(move.instance)]
            if number(move.cd) and move.cd<20 and history and number(history.endsAt) then
                move.cooldownEndsAt=history.endsAt
                move.cooldownSeconds=cooldownSeconds(history,now)
            end
        end
        if record then
            for key in pairs(record.cooldowns) do if not present[key] then record.cooldowns[key]=nil end end
        end
        table.sort(moves,function(a,b)
            if (a.slot or 99)~=(b.slot or 99) then return (a.slot or 99)<(b.slot or 99) end
            return a.name<b.name
        end)
        return moves
    end
    local function notify(title,text)
        pcall(function() window:Notify({Title=title,Content=text}) end)
    end
    local function captureTick(list,now)
        if not capture then return end
        local job=capture
        local function line(text) if #job.lines<1400 then job.lines[#job.lines+1]=text end end
        for _,player in ipairs(list) do
            local key=playerKey(player)
            local rows=readMoves(player,player.Character)
            local using=child(player.Character,"UsingSkill")
            local skill="none"
            if using then pcall(function() skill=tostring(using.Value) end) end
            local parts={"skill="..skill,"character="..tostring(characterKey(player.Character))}
            local record=records[key]
            for _,move in ipairs(rows) do
                local displayed="not rendered"
                for _,shown in ipairs(record and record.moves or {}) do
                    if shown.slot==move.slot and shown.name==move.name then
                        displayed=tostring(shown.cd).."/"..shown.source;break
                    end
                end
                parts[#parts+1]=tostring(move.slot)..":"..move.name.."="..tostring(move.cd).."/"..move.source.." display="..displayed
            end
            local state=table.concat(parts,"; ")
            local changed=job.last[key]~=state
            if changed then
                job.last[key]=state
                line(string.format("%.2fs %s%s %s",now-job.start,key,key==playerKey(Players.LocalPlayer) and " SELF" or " OTHER",state))
            end
            if changed then
                local pack=child(player,"Backpack")
                local ok,children=pcall(function() return pack and pack:GetChildren() or {} end)
                if ok then
                    for _,move in ipairs(children) do
                        if child(move,".Config") then
                            local ok,address=pcall(function() return move.Address end)
                            if ok and number(address) and address>0 and type(memory_read)=="function" then
                                local success,header=pcall(function()
                                    local container=memory_read("uintptr_t",address+0x48)
                                    if not number(container) or container<4096 then return "no storage" end
                                    local values={}
                                    for offset=0,0x30,8 do values[#values+1]=string.format("+%X=%s",offset,tostring(memory_read("uintptr_t",container+offset))) end
                                    return table.concat(values," ")
                                end)
                                local storageKey=key.."/"..tostring(move.Name)
                                local text=success and header or "unreadable"
                                if job.headers[storageKey]~=text then
                                    job.headers[storageKey]=text
                                    line("STORAGE "..storageKey.." "..text)
                                end
                            end
                        end
                    end
                end
            end
        end
        if now>=job.finish then
            capture=nil
            local report=table.concat(job.lines,"\n")
            local copied=false
            if type(setclipboard)=="function" then copied=pcall(setclipboard,report) end
            if not copied and type(toclipboard)=="function" then copied=pcall(toclipboard,report) end
            local saved=false
            if type(writefile)=="function" then saved=pcall(writefile,"aba-cooldown-timeline.txt",report) end
            print(report)
            notify("Cooldown recording finished",copied and "Report copied. Paste it into this chat." or saved and "Saved aba-cooldown-timeline.txt in the Matcha workspace." or "Report printed in Matcha output.")
        end
    end
    local function set(d,key,value)
        local values=drawingValues[d]
        if not values then values={};drawingValues[d]=values end
        if values[key]~=value then d[key]=value;values[key]=value end
    end
    local function hide(record)
        for _,d in pairs(record.drawings) do pcall(function() set(d,"Visible",false) end) end
    end
    local function release(record)
        hide(record)
        for _,d in pairs(record.drawings) do
            local ok=pcall(function() d:Remove() end)
            if not ok then pcall(function() d:Destroy() end) end
            for i=#ownedDrawings,1,-1 do if ownedDrawings[i]==d then table.remove(ownedDrawings,i);break end end
            drawingValues[d]=nil
        end
        record.drawings={}
    end
    local function project(position,camera,frame)
        return projectToScreen(position,camera,frame)
    end
    local function projectAnchor(record,position,camera,frame,now)
        -- Reject isolated native projection samples. Center and size are then
        -- smoothed together once the complete pose has been measured.
        local samples,xs,ys={},{},{}
        for i=1,3 do
            local point,visible,depth=project(position,camera,frame)
            if point and number(point.X) and number(point.Y) then
                samples[#samples+1]={x=point.X,y=point.Y,visible=visible,depth=depth}
                xs[#xs+1]=point.X;ys[#ys+1]=point.Y
            end
        end
        if #samples==0 then return nil,false end
        local function median(values)
            table.sort(values)
            local n=#values
            if n%2==0 then return (values[n/2]+values[n/2+1])/2 end
            return values[(n+1)/2]
        end
        local x,y=median(xs),median(ys)
        local selected,best
        for _,sample in ipairs(samples) do
            local error=math.abs(sample.x-x)+math.abs(sample.y-y)
            if not best or error<best then selected=sample;best=error end
        end
        return Vector2.new(x,y),selected.visible,selected.depth
    end
    local function object(record,key,kind)
        local d=record.drawings[key]
        if d then return d end
        d=Drawing.new(kind);record.drawings[key]=d;ownedDrawings[#ownedDrawings+1]=d
        d.Visible=false;d.Transparency=1;d.ZIndex=kind=="Text" and 902 or 900
        if kind=="Text" then d.Size=14;d.Font=2;d.Center=false;d.Outline=true
        else d.Filled=true end
        return d
    end
    local function label(record,key,text,x,y,color)
        local d=object(record,key,"Text")
        set(d,"Text",text);set(d,"Position",Vector2.new(x,y));set(d,"Color",color);set(d,"Visible",true)
        record.used[key]=true
    end
    local function square(record,key,x,y,w,h,color)
        local d=object(record,key,"Square")
        set(d,"Position",Vector2.new(x,y));set(d,"Size",Vector2.new(w,h));set(d,"Color",color);set(d,"Visible",w>0 and h>0)
        record.used[key]=true
    end
    local function smoothESPPose(record,point,scale,worldPosition,camera,frame,now)
        local previous=record.poseMotion
        local logScale=math.log(scale)
        local reset=not previous or previous.camera~=camera or now<previous.time or now-previous.time>.25
        if previous and not reset then
            if frame and frame.fov and previous.fov and math.abs(frame.fov-previous.fov)>3 then reset=true end
            pcall(function() if (worldPosition-previous.worldPosition).Magnitude>12 then reset=true end end)
            if frame and frame.position and previous.cameraPosition then
                pcall(function() if (frame.position-previous.cameraPosition).Magnitude>12 then reset=true end end)
            end
            if math.abs(point.X-previous.x)>300 or math.abs(point.Y-previous.y)>300 then reset=true end
        end
        if reset then
            previous={camera=camera,time=now,x=point.X,y=point.Y,l=logScale,samples={}}
            record.poseMotion=previous
        end
        local samples=previous.samples
        if #samples==0 or now>samples[#samples].time then
            samples[#samples+1]={x=point.X,y=point.Y,l=logScale,time=now}
        end
        while #samples>11 or (#samples>3 and now-samples[1].time>.1) do table.remove(samples,1) end
        local function fit(list)
            local n,st,stt,sx,sy,sl,stx,sty,stl=#list,0,0,0,0,0,0,0,0
            for _,sample in ipairs(list) do
                local t=sample.time-now
                st=st+t;stt=stt+t*t
                sx=sx+sample.x;sy=sy+sample.y;sl=sl+sample.l
                stx=stx+t*sample.x;sty=sty+t*sample.y;stl=stl+t*sample.l
            end
            local denominator=n*stt-st*st
            if n<3 or denominator<=.000000001 then
                return {x=point.X,y=point.Y,l=logScale,vx=0,vy=0,vl=0}
            end
            local vx=(n*stx-st*sx)/denominator
            local vy=(n*sty-st*sy)/denominator
            local vl=(n*stl-st*sl)/denominator
            return {x=(sx-vx*st)/n,y=(sy-vy*st)/n,l=(sl-vl*st)/n,vx=vx,vy=vy,vl=vl}
        end
        local trajectory=fit(samples)
        local residuals={}
        for _,sample in ipairs(samples) do
            local t=sample.time-now
            local dx=sample.x-(trajectory.x+trajectory.vx*t)
            local dy=sample.y-(trajectory.y+trajectory.vy*t)
            local ds=(sample.l-(trajectory.l+trajectory.vl*t))*80
            residuals[#residuals+1]=math.sqrt(dx*dx+dy*dy+ds*ds)
        end
        table.sort(residuals)
        local noise=residuals[math.floor((#residuals+1)/2)] or 0
        local threshold=math.max(1,noise*2.5)
        local clean={}
        for _,sample in ipairs(samples) do
            local t=sample.time-now
            local dx=sample.x-(trajectory.x+trajectory.vx*t)
            local dy=sample.y-(trajectory.y+trajectory.vy*t)
            local ds=(sample.l-(trajectory.l+trajectory.vl*t))*80
            if dx*dx+dy*dy+ds*ds<=threshold*threshold then clean[#clean+1]=sample end
        end
        if #clean>=3 then trajectory=fit(clean) end
        -- Only predict sustained movement, not alternating one-frame noise.
        local span=math.max(.001,now-samples[1].time)
        if math.sqrt(trajectory.vx^2+trajectory.vy^2)*span<math.max(1,noise*2.5) then
            trajectory.vx=0;trajectory.vy=0
        end
        local dt=math.max(0,math.min(.1,now-previous.time))
        if dt>0 then
            local response=55
            local blend=1-math.exp(-response*dt)
            -- Short motion compensation avoids the trailing of a plain low-pass.
            local lead=math.min(.012,dt/(math.exp(response*dt)-1))
            local tx=trajectory.x+trajectory.vx*lead
            local ty=trajectory.y+trajectory.vy*lead
            local tl=trajectory.l+math.max(-2.5,math.min(2.5,trajectory.vl))*lead
            previous.x=previous.x+(tx-previous.x)*blend
            previous.y=previous.y+(ty-previous.y)*blend
            previous.l=previous.l+(tl-previous.l)*blend
        end
        previous.time=now;previous.worldPosition=worldPosition
        previous.cameraPosition=frame and frame.position or nil
        previous.fov=frame and frame.fov or nil
        local anchorX=point.X+math.max(-.75,math.min(.75,previous.x-point.X))
        local anchorY=point.Y+math.max(-.75,math.min(.75,previous.y-point.Y))
        local fittedScale=math.exp(previous.l)
        fittedScale=math.max(scale*.98,math.min(scale*1.02,fittedScale))
        return Vector2.new(anchorX,anchorY),fittedScale
    end
    local function bodyBounds(record,character,root,camera,rootPosition,rootPoint,frame,now)
        -- Read sizes rather than animated limb positions. Refresh on every draw so
        -- transforms, scaling and late-loading rig parts immediately update bounds.
        local function dimension(part,axis,fallback)
            local ok,value=pcall(function() return part.Size[axis] end)
            if ok and number(value) and value>0 then return value end
            return fallback
        end
        local head=child(character,"Head")
        local torso=child(character,"UpperTorso") or child(character,"Torso")
        local arm=child(character,"LeftUpperArm") or child(character,"Left Arm")
        local leg=child(character,"Left Leg") or child(character,"Right Leg")
        local foot=child(character,"LeftFoot") or child(character,"RightFoot")
        local rootHalf=dimension(root,"Y",2)/2
        local headHeight=dimension(head,"Y",1)
        local legHeight=dimension(leg,"Y",2)
        if foot then
            legHeight=dimension(child(character,"LeftUpperLeg"),"Y",1)
                +dimension(child(character,"LeftLowerLeg"),"Y",1)+dimension(foot,"Y",1)
        end
        local hip
        pcall(function()
            local hum=character:FindFirstChildOfClass("Humanoid")
            if number(hum.HipHeight) and hum.HipHeight>=0 then hip=hum.HipHeight end
        end)
        local upper=rootHalf+headHeight+.5
        local lower=rootHalf+(foot and (hip or legHeight) or legHeight+(hip or 0))
        local halfWidth=dimension(torso,"X",2)/2+dimension(arm,"X",1)+.15
        record.bounds={upper=upper,lower=lower,halfWidth=halfWidth}
        local center=rootPosition or root.Position
        local point=rootPoint or project(center,camera,frame)
        if not point or not number(point.X) or not number(point.Y) then return nil end
        frame=frame or screenProjection(camera)
        local scale
        -- Derive size from one captured camera pose, not differences between
        -- screen projections sampled at different points in camera motion.
        if frame and frame.focal then
            local depth
            if frame.matrix then
                local m=frame.matrix
                depth=-((center.X-m[1])*m[6]+(center.Y-m[2])*m[9]+(center.Z-m[3])*m[12])
            elseif frame.position and frame.forward then
                pcall(function()
                    local relative=center-frame.position
                    depth=relative.X*frame.forward.X+relative.Y*frame.forward.Y+relative.Z*frame.forward.Z
                end)
            end
            if (not number(depth) or depth<=.01) and frame.position then
                pcall(function() depth=(center-frame.position).Magnitude end)
            end
            if number(depth) and depth>.01 then scale=frame.focal/depth end
        end
        if not number(scale) or scale<=0 then
            -- Older runners may not expose camera basis/FOV. This is only a size
            -- fallback; the position still comes from the single root projection.
            local top=project(center+Vector3.new(0,upper,0),camera,frame)
            local bottom=project(center-Vector3.new(0,lower,0),camera,frame)
            if top and bottom then scale=math.abs(bottom.Y-top.Y)/(upper+lower) end
            if not number(scale) or scale<.1 then scale=record.lastScale or 12 end
        end
        -- Filter center and size as one pose, keeping every bar and card together.
        now=now or (tick and tick() or os.clock())
        point,scale=smoothESPPose(record,point,scale,center,camera,frame,now)
        record.lastScale=scale
        local height=(upper+lower)*scale
        if height<3 then height=3;scale=height/(upper+lower) end
        if not number(height) or height<=0 then return nil end
        return point.X-halfWidth*scale,point.X+halfWidth*scale,
            point.Y-upper*scale,math.max(3,height)
    end
    local function verticalMeter(record,key,ratio,x,top,height,color)
        -- Keep a small percentage just outside each vertical mode line.
        local percentKey=key.."Percent"
        local percent=object(record,percentKey,"Text")
        local uiScale=math.min(1.35,math.max(.3,height/160))
        set(percent,"Size",math.max(6,math.floor(12*uiScale+.5)))
        set(percent,"Center",true)
        local percentGap=math.max(7,22*uiScale)
        local percentX=key=="mode2" and x+percentGap or x-percentGap
        local lineWidth=math.max(1,2*uiScale)
        local borderWidth=math.max(.5,uiScale)
        local value=ratio~=nil and string.format("%.0f%%",math.max(0,math.min(1,ratio))*100) or "--%"
        label(record,percentKey,value,percentX,top,color)
        square(record,key.."Outline",x-borderWidth,top-borderWidth,lineWidth+borderWidth*2,height+borderWidth*2,Color3.fromRGB(15,15,18))
        set(record.drawings[key.."Outline"],"ZIndex",900)
        if ratio~=nil then
            local fill=height*math.max(0,math.min(1,ratio))
            square(record,key.."Fill",x,top+height-fill,lineWidth,fill,color)
            set(record.drawings[key.."Fill"],"ZIndex",901)
        end
    end
    local function moveBox(record,index,move,x,y,w,h,now)
        local key="moveBox"..index
        local value=move.cd
        local known=number(value)
        local ready=known and value>=20
        local tint=move.guardbreak==true and Color3.fromRGB(0,110,255) or Color3.fromRGB(250,0,0)
        local radius=math.min(w,h)*.16
        square(record,key.."Body",x,y,w,h,tint)
        set(record.drawings[key.."Body"],"ZIndex",901)
        pcall(function() set(record.drawings[key.."Body"],"Corner",radius) end)
        -- cd is readiness on a 0..20 scale: 0 = just used, 20 = ready.
        -- Keep the bottom edge fixed so the gray area drains downward.
        local remaining=known and (1-math.max(0,math.min(20,value))/20) or 0
        local overlayHeight=h*remaining
        -- Clip the cooldown fill to the rounded silhouette so gray does not
        -- square off the bottom corners as the move approaches readiness.
        if overlayHeight>0 then
            local cuts={0}
            for part=1,8 do cuts[#cuts+1]=radius*part/8 end
            cuts[#cuts+1]=h-radius
            for part=1,8 do cuts[#cuts+1]=h-radius+radius*part/8 end
            for part=1,#cuts-1 do
                local first=math.max(cuts[part],h-overlayHeight)
                local last=cuts[part+1]
                if last>first then
                    local edge=math.min(first,h-last)
                    local inset=0
                    if edge<radius then
                        local dy=radius-math.max(0,edge)
                        inset=radius-math.sqrt(math.max(0,radius*radius-dy*dy))
                    end
                    local fillKey=key.."Cooldown"..part
                    square(record,fillKey,x+inset,y+first,math.max(0,w-inset*2),last-first,Color3.fromRGB(100,103,110))
                    set(record.drawings[fillKey],"ZIndex",902)
                    set(record.drawings[fillKey],"Transparency",.75)
                end
            end
        end
        local function text(suffix,text,tx,ty,size,center)
            local d=object(record,key..suffix,"Text")
            set(d,"Size",size);set(d,"Center",center);set(d,"ZIndex",903)
            label(record,key..suffix,text,tx,ty,white)
        end
        local textScale=math.min(w/64,h/64)
        record.moveTextLayouts=record.moveTextLayouts or {}
        local layout=record.moveTextLayouts[key]
        if not layout then layout={compact=h<20,lines=h>=36 and 2 or 1};record.moveTextLayouts[key]=layout end
        local function font(name,raw)
            local previous=layout[name]
            if not previous or raw>previous+.7 or raw<previous-.7 then
                previous=math.max(4,math.floor(raw+.5));layout[name]=previous
            end
            return previous
        end
        local nameSize=font("nameSize",14*textScale)
        local stateSize=font("stateSize",8*textScale)
        local slotSize=font("slotSize",10*textScale)
        if h>22 then layout.compact=false elseif h<18 then layout.compact=true end
        if h>38 then layout.lines=2 elseif h<34 then layout.lines=1 end
        if not layout.compact then
            text("Slot",tostring(move.slot or index),x+math.max(1,2*textScale),y+math.max(1,2*textScale),slotSize,false)
            local lines={}
            local current=""
            local maxChars=math.max(3,math.floor((w-math.max(2,4*textScale))/(nameSize*.5)))
            local name=tostring(move.name or "Unknown")
            for token in name:gmatch("%S+") do
                local word=token
                while #word>maxChars do
                    if current~="" then lines[#lines+1]=current;current="" end
                    lines[#lines+1]=word:sub(1,maxChars);word=word:sub(maxChars+1)
                end
                if #current+#word+1>maxChars and current~="" then
                    lines[#lines+1]=current;current=word
                else current=current=="" and word or current.." "..word end
            end
            if current~="" then lines[#lines+1]=current end
            if #lines==0 then lines={"Unknown"} end
            local maxLines=layout.lines
            if #lines>maxLines then lines[maxLines]=lines[maxLines]:sub(1,math.max(1,maxChars-2))..".." end
            local count=math.min(maxLines,#lines)
            local nameY=y+(h-count*(nameSize+1))/2
            for row=1,count do text("Name"..row,lines[row],x+w/2,nameY+(row-1)*(nameSize+1),nameSize,true) end
        end
        local seconds=number(move.cooldownSeconds) and move.cooldownSeconds or nil
        local state=not known and "UNKNOWN" or ready and "READY"
            or (seconds and (math.max(1,math.ceil(seconds-.000001)).."s") or "...")
        local stateY=layout.compact and y+(h-stateSize)/2 or y+h-stateSize-2
        if not ready then text("State",state,x+w/2,stateY,stateSize,true) end
    end
    local function updatePlayer(player,record,now,frame)
        local character=player.Character
        local identity=characterKey(character)
        if record.character~=identity then
            hide(record);record.character=identity;record.bounds=nil;record.poseMotion=nil;record.lastScale=nil;record.moveTextLayouts=nil;record.boxSide=nil;record.nextRead=0;record.mode=nil;record.mode2=nil;record.moves={};record.cooldowns={};record.lastMovesRead=nil
        end
        if not modeOn.Value and not movesOn.Value then hide(record);return end
        local me=Players.LocalPlayer
        if teamFilter.Value and me and playerKey(player)~=playerKey(me) and me.Team~=nil and player.Team==me.Team then hide(record);return end
        local head=child(character,"Head") or child(character,"HumanoidRootPart")
        local root=child(character,"HumanoidRootPart") or child(character,"UpperTorso") or child(character,"Torso")
        local humanoid=character and character:FindFirstChildOfClass("Humanoid")
        local camera=world.CurrentCamera
        if not head or not root or not camera or (humanoid and humanoid.Health<=0) then hide(record);return end
        local okDistance,distance=pcall(function()
            local origin=child(me and me.Character,"HumanoidRootPart")
            return (head.Position-(origin and origin.Position or camera.CFrame.Position)).Magnitude
        end)
        if okDistance and number(distance) and distance>range.Value then hide(record);return end
        local rootPosition=root.Position
        if not frame or frame.camera~=camera then frame=screenProjection(camera) end
        local point,visible,depth=projectAnchor(record,rootPosition,camera,frame,now)
        if not point or (depth and depth<=0) then hide(record);return end
        local left,right,top,bodyHeight=bodyBounds(record,character,root,camera,rootPosition,point,frame,now)
        local view=camera.ViewportSize
        local inside=point.X>=0 and point.Y>=0 and point.X<=view.X and point.Y<=view.Y
        if not left or right<0 or left>view.X or top+bodyHeight<0 or top>view.Y
            or (visible==false and inside) then hide(record);return end
        if now>=record.nextRead then
            if modeOn.Value then
                local success,value=pcall(readMode,player,character)
                if success then record.mode=value end
                local secondOk,secondValue=pcall(readMode,player,character,true)
                if secondOk then record.mode2=secondValue end
            end
            if movesOn.Value then
                local success,value=pcall(readMoves,player,character,record,now)
                if success and type(value)=="table" and #value>0 then
                    record.moves=value;record.lastMovesRead=now
                elseif not record.lastMovesRead or now-record.lastMovesRead>.5 then
                    record.moves={}
                end
            end
            record.nextRead=now+.05
        end
        record.used={}
        if modeOn.Value then
            local ratio=record.mode
            if left then
                verticalMeter(record,"mode",ratio,left-5,top,bodyHeight,modeRed)
                if record.mode2~=nil then
                    verticalMeter(record,"mode2",record.mode2,right+3,top,bodyHeight,secondPurple)
                end
            end
        end
        if movesOn.Value then
            local slotCount=math.max(1,#record.moves)
            for _,move in ipairs(record.moves) do
                if number(move.slot) and move.slot>=1 and move.slot<=99 and move.slot%1==0 then
                    slotCount=math.max(slotCount,move.slot)
                end
            end
            -- Fit the ENTIRE stack within the mode lines, including every gap.
            -- Never impose a minimum card height that could overflow the bars.
            local gap=math.min(4,bodyHeight/(slotCount*12))
            local available=math.max(0,bodyHeight-gap*(slotCount-1))
            local cardSize=available/slotCount
            local cardScale=cardSize/64
            -- Stable player-relative offsets. Do not flip sides or clamp the
            -- stack against the screen edge independently of the character.
            local boxX=right+math.max(18,math.min(64,46*cardScale))
            local boxY=top
            if #record.moves==0 then
                moveBox(record,1,{name="Moves",source="unknown"},boxX,boxY,cardSize,cardSize,now)
            else
                for i,move in ipairs(record.moves) do
                    local slot=number(move.slot) and move.slot>=1 and move.slot<=99
                        and move.slot%1==0 and move.slot or i
                    moveBox(record,i,move,boxX,boxY+(slot-1)*(cardSize+gap),cardSize,cardSize,now)
                end
            end
        end
        for key,d in pairs(record.drawings) do if not record.used[key] then set(d,"Visible",false) end end
    end
    local function renderESP()
        if stopped or not alive then return end
        local now=tick and tick() or os.clock()
        local present={}
        local frame=screenProjection(world.CurrentCamera)
        local ok,list=pcall(function() return Players:GetPlayers() end)
        if not ok then for _,record in pairs(records) do hide(record) end;return end
        for _,player in ipairs(list) do
            local identity=playerKey(player)
            if identity~=playerKey(Players.LocalPlayer) or selfOn.Value then
                present[identity]=true
                local record=records[identity]
                if not record then record={drawings={},nextRead=0,moves={}};records[identity]=record end
                local success,err=pcall(updatePlayer,player,record,now,frame)
                if not success then
                    hide(record)
                    local message=tostring(err)
                    if record.lastError~=message then
                        record.lastError=message
                        print("[ESP] "..tostring(player.Name)..": "..message)
                    end
                else record.lastError=nil end
            end
        end
        if capture then
            local success,err=pcall(captureTick,list,now)
            if not success then
                capture=nil
                print("[ESP recording] "..tostring(err))
                notify("Cooldown recording failed","See Matcha output for the recording error.")
            end
        end
        local removed={}
        for player in pairs(records) do if not present[player] then removed[#removed+1]=player end end
        for _,player in ipairs(removed) do release(records[player]);records[player]=nil end
    end
    local renderConnection,renderBinding
    local lastRenderSignal=-math.huge
    local function onRender()
        if stopped or not alive then return end
        lastRenderSignal=tick and tick() or os.clock()
        renderESP()
    end
    pcall(function()
        if type(RunService.BindToRenderStep)=="function" then
            local name="ABAModeESP_"..tostring(state)
            RunService:BindToRenderStep(name,201,onRender)
            renderBinding=name
        end
    end)
    if not renderBinding then
        pcall(function() renderConnection=RunService.RenderStepped:Connect(onRender) end)
    end
    heartbeat=RunService.Heartbeat:Connect(function()
        if stopped or not alive then return end
        local now=tick and tick() or os.clock()
        if now-lastRenderSignal>.1 then renderESP() end
    end)
    return function()
        if stopped then return end
        stopped=true
        capture=nil
        if renderBinding then pcall(function() RunService:UnbindFromRenderStep(renderBinding) end) end
        if renderConnection then pcall(function() renderConnection:Disconnect() end) end
        if heartbeat then pcall(function() heartbeat:Disconnect() end) end
        for _,record in pairs(records) do release(record) end
        records={}
    end
end
destroyPlayerESP=mountPlayerESP()


-- Reads the same replicated value as aba.rbxl's built-in spin GUI.
local function mountMahoragaCounter()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local counterTab = window:Tab("Mahoraga")
    counterTab:Section("Wheel spin counter")
    local showSelf = counterTab:Toggle({Name="Show my wheel bar", Default=true, Flag="mahoraga_self"})
    local showOthers = {Value=true}
    local counterColor = Color3.fromRGB(255,220,120)
    local barColor = counterTab:Colorpicker({Name="Bar colour", Default=Color3.fromRGB(35,255,0), Flag="mahoraga_bar_color"})

    local drawings, stopped, elapsed = {}, false, 0
    local bar = {}
    local barSignature, barVisible
    local heartbeat
    local function hide(drawing)
        if drawing then pcall(function() if drawing.Visible then drawing.Visible=false end end) end
    end
    local function barObject(key, kind, layer)
        if bar[key] then return bar[key] end
        local d=Drawing.new(kind)
        bar[key]=d
        ownedDrawings[#ownedDrawings+1]=d
        d.Visible=false; d.Transparency=1; d.ZIndex=layer
        if kind=="Square" or kind=="Circle" then d.Filled=true end
        if kind=="Circle" then d.NumSides=24 end
        return d
    end
    local function rectangle(key,x,y,w,h,r,g,b,layer)
        local d=barObject(key,"Square",layer)
        d.Position=Vector2.new(x,y); d.Size=Vector2.new(w,h)
        d.Color=Color3.fromRGB(r,g,b); d.Visible=w>0 and h>0
        return d
    end
    local function hideBar()
        if not barVisible then return end
        for _,d in pairs(bar) do hide(d) end
        barVisible=false
        barSignature=nil
    end
    local function roundedRectangle(key,x,y,w,h,r,color,layer)
        if w<=0 or h<=0 then
            for _,suffix in ipairs({"body","middle","tl","tr","bl","br"}) do hide(bar[key..suffix]) end
            return
        end
        r=math.min(r,w/2,h/2)
        local function square(suffix,px,py,pw,ph)
            local d=rectangle(key..suffix,px,py,pw,ph,0,0,0,layer)
            d.Color=color
        end
        square("body",x+r,y,w-r*2,h)
        square("middle",x,y+r,w,h-r*2)
        local corners={{"tl",x+r,y+r},{"tr",x+w-r,y+r},{"bl",x+r,y+h-r},{"br",x+w-r,y+h-r}}
        for _,corner in ipairs(corners) do
            local d=barObject(key..corner[1],"Circle",layer)
            d.Position=Vector2.new(corner[2],corner[3]); d.Radius=r
            d.Color=color; d.Visible=true
        end
    end
    local function roundedOutline(x,y,w,h)
        -- Pixel strips form a continuous hollow frame without line-join spikes.
        local thickness,r=7,9
        local innerRadius=r-thickness
        for row=0,r-1 do
            local dy=r-row-.5
            local outer=math.floor(r-math.sqrt(math.max(0,r*r-dy*dy))+.5)
            local inner=w/2
            if row>=thickness then
                local iy=innerRadius-(row-thickness)-.5
                inner=thickness+innerRadius-math.sqrt(math.max(0,innerRadius*innerRadius-iy*iy))
            end
            local edge=math.max(0,math.ceil(inner)-outer)
            if row<thickness then
                rectangle("borderTop"..row,x+outer,y+row,w-outer*2,1,45,45,45,1000)
                rectangle("borderBottom"..row,x+outer,y+h-row-1,w-outer*2,1,45,45,45,1000)
            else
                rectangle("borderTL"..row,x+outer,y+row,edge,1,45,45,45,1000)
                rectangle("borderTR"..row,x+w-outer-edge,y+row,edge,1,45,45,45,1000)
                rectangle("borderBL"..row,x+outer,y+h-row-1,edge,1,45,45,45,1000)
                rectangle("borderBR"..row,x+w-outer-edge,y+h-row-1,edge,1,45,45,45,1000)
            end
        end
        rectangle("borderLeft",x,y+r,thickness,h-r*2,45,45,45,1000)
        rectangle("borderRight",x+w-thickness,y+r,thickness,h-r*2,45,45,45,1000)
    end
    local function drawBar(camera,count)
        local viewport=camera.ViewportSize
        local spins=math.max(0,math.min(4,math.floor(count)))
        local tint=barColor.Value
        local signature=table.concat({viewport.X,viewport.Y,spins,tint.R,tint.G,tint.B},":")
        if barVisible and barSignature==signature then return end
        -- Keep the existing objects on screen; never hide/re-show a healthy bar.
        barVisible=true
        local h=math.floor(math.max(120,math.min(640,viewport.Y*.44))+.5)
        h=math.min(h,math.max(20,viewport.Y-32))
        local w=math.floor(math.max(52,math.min(60,viewport.Y*.04))+.5)
        local x,y=4,math.floor(math.max(8,math.min(viewport.Y*.29,viewport.Y-h-8))+.5)
        local inset=7
        local ix,iy,iw,ih=x+inset,y+inset,w-inset*2,h-inset*2
        local ratio=spins/4
        -- A hollow outline keeps the unfilled area fully see-through.
        roundedOutline(x,y,w,h)
        local fillHeight=math.floor(ih*ratio+.5)
        roundedRectangle("fill",ix,iy+ih-fillHeight,iw,fillHeight,4,tint,1002)
        local dark=Color3.new(tint.R*.12,tint.G*.58,tint.B*.12)
        roundedRectangle("shade",ix+iw-7,iy+ih-fillHeight,7,fillHeight,3,dark,1003)
        -- Three interior dividers and the frame define four 25% sections.
        for i=1,3 do
            local gap=4
            local dash=(iw-gap*2)/3
            for j=0,2 do
                rectangle("tick"..i.."_"..j,ix+j*(dash+gap),math.floor(iy+ih*i/4-2),dash,4,45,45,45,1004)
            end
        end
        -- Individual lines avoid executor-specific multiline text layout glitches.
        local lines={"WHEEL","SPINS",spins.."/4",(spins*25).."%"}
        for i,text in ipairs(lines) do
            local label=barObject("label"..i,"Text",1005)
            label.Center=true; label.Outline=true; label.Font=2; label.Size=14
            label.Color=Color3.fromRGB(255,255,255); label.Text=text
            label.Position=Vector2.new(x+w/2,math.floor(y+h/2-38+(i-1)*19))
            label.Visible=true
        end
        barSignature=signature
    end
    local function remove(player)
        local drawing = drawings[player]
        if not drawing then return end
        hide(drawing)
        local ok = pcall(function() drawing:Remove() end)
        if not ok then pcall(function() drawing:Destroy() end) end
        drawings[player] = nil
        for i=#ownedDrawings,1,-1 do
            if ownedDrawings[i] == drawing then table.remove(ownedDrawings,i); break end
        end
    end
    local function textFor(player)
        if drawings[player] then return drawings[player] end
        local drawing = Drawing.new("Text")
        drawings[player] = drawing
        ownedDrawings[#ownedDrawings+1] = drawing
        drawing.Visible=false
        drawing.Center=true
        drawing.Outline=true
        drawing.Size=18
        drawing.Font=2
        drawing.Transparency=1
        drawing.ZIndex=1000
        return drawing
    end
    local function spinValue(character)
        local value = character and character:FindFirstChild("WheelSpins")
        if not value then return nil end
        local ok, count = pcall(function() return value.Value end)
        if ok and type(count)=="number" and count==count and count>=0 and count<math.huge then
            return count
        end
        return nil
    end
    local lastCounterError
    local function refresh()
        local camera = world.CurrentCamera
        local present = {}
        local localPlayer = Players.LocalPlayer
        local localCount = localPlayer and spinValue(localPlayer.Character)
        if camera and showSelf.Value and localCount~=nil then
            local humanoid=localPlayer.Character:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health>0 then drawBar(camera,localCount) else hideBar() end
        else
            hideBar()
        end
        for _,player in ipairs(Players:GetPlayers()) do
            present[player] = true
            hide(drawings[player])
            -- A player leaving or replacing a character must not break other counters.
            pcall(function()
                local isSelf = player == localPlayer
                if isSelf then return end
                if (isSelf and not showSelf.Value) or (not isSelf and not showOthers.Value) then return end
                if not camera then return end
                local character = player.Character
                local count = spinValue(character)
                if count == nil then return end
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health <= 0 then return end
                local position, caption
                if isSelf then
                    local viewport = camera.ViewportSize
                    position = Vector2.new(viewport.X/2,80)
                    caption = "Mahoraga | Spins: "..tostring(count)
                else
                    local head = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
                    if not head then return end
                    local point,onScreen=projectToScreen(head.Position+Vector3.new(0,3,0),camera)
                    if not point or not onScreen then return end
                    position = Vector2.new(point.X,point.Y)
                    caption = tostring(player.DisplayName or player.Name).." | Spins: "..tostring(count)
                end
                local drawing = textFor(player)
                drawing.Text=caption
                drawing.Position=position
                drawing.Color=counterColor
                drawing.Visible=true
            end)
        end
        local departed = {}
        for player in pairs(drawings) do
            if not present[player] then departed[#departed+1] = player end
        end
        for _,player in ipairs(departed) do remove(player) end
    end
    heartbeat = RunService.Heartbeat:Connect(function(dt)
        if stopped or not alive then return end
        elapsed = elapsed + (tonumber(dt) or 0.1)
        if elapsed < 0.1 then return end
        elapsed = 0
        local ok, err = pcall(refresh)
        if not ok then
            hideBar()
            for _,drawing in pairs(drawings) do hide(drawing) end
            local text = "Wheel counter unavailable: "..tostring(err)
            if text ~= lastCounterError then
                lastCounterError=text
                print("[Mahoraga] "..text)
            end
        end
    end)
    return function()
        if stopped then return end
        stopped=true
        if heartbeat then pcall(function() heartbeat:Disconnect() end) end
        local remaining = {}
        for player in pairs(drawings) do remaining[#remaining+1]=player end
        for _,player in ipairs(remaining) do remove(player) end
        for _,drawing in pairs(bar) do
            hide(drawing)
            local ok=pcall(function() drawing:Remove() end)
            if not ok then pcall(function() drawing:Destroy() end) end
            for i=#ownedDrawings,1,-1 do
                if ownedDrawings[i]==drawing then table.remove(ownedDrawings,i); break end
            end
        end
        bar={}
    end
end
destroyMahoragaCounter = mountMahoragaCounter()


print("[hahahahahaha] Loaded. Open Timings for Nanami, Camera Timings and Kokushibo, or Head Ride for Head Ride controls. Right Shift shows/hides the menu.")
