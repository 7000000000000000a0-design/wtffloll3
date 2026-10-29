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
local characterTimings={Yuji=false,Todo=false,["TS Law"]=false,Geto=false}
local characterOverride="Auto"
local m1Cooldown,quietAfterNanami=.2,.6
local lastProfileClick=-math.huge
local detectedCharacter,nextCharacterScan=nil,0

for _,name in ipairs({"Yuji","Todo","TS Law","Geto"})do
    local characterName=name
    flashTab:Toggle({Name="Auto "..characterName,Default=false,Callback=function(on)
        characterTimings[characterName]=on
        flash={last=nil,minimum=math.huge,descending=false,fired=false}
    end})
end



local function characterFrom(value)
    if type(value)~="string" then return end
    local text=value:lower():gsub("[%s_%-]","")
    if text:find("yuji",1,true) or text:find("itadori",1,true) then return "Yuji" end
    if text:find("todo",1,true) then return "Todo" end
    if text:find("tslaw",1,true) or text:find("timeskiplaw",1,true) or text=="law" then return "TS Law" end
    if text:find("geto",1,true) or text:find("suguru",1,true) then return "Geto" end
end
local function enabledCharacterProfile(now)
    if not (characterTimings.Yuji or characterTimings.Todo or characterTimings["TS Law"] or characterTimings.Geto)then return false end
    if characterOverride~="Auto" then
        
        return characterTimings[characterOverride]==true
    end
    if now>=nextCharacterScan then
        nextCharacterScan=now+.5;detectedCharacter=nil
        local player=players.LocalPlayer
        local roots={player,player and player.Character,player and player:FindFirstChild("ReplicatedStats")}
        for i=1,3 do
            local root=roots[i]
            if root then
                local ok,attrs=pcall(function()return root:GetAttributes()end)
                if ok and type(attrs)=="table" then
                    for _,v in pairs(attrs)do detectedCharacter=detectedCharacter or characterFrom(v) end
                end
                for _,obj in ipairs(root:GetChildren())do
                    local success,value=pcall(function()return obj.Value end)
                    if success then detectedCharacter=detectedCharacter or characterFrom(value) end
                end
            end
        end
    end
    
    if detectedCharacter then return characterTimings[detectedCharacter]==true end
    return true
end
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
    local profileEnabled=enabledCharacterProfile(now)
    if profileEnabled then
        local cam=world.CurrentCamera
        local fov=cam and cam.FieldOfView
        if type(fov)=="number" then
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
connection=game:GetService("RunService").Heartbeat:Connect(function()
    if not alive then return end
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
print("[hahahahahaha] Loaded. Open Timings for all six toggles. Right Shift shows/hides the menu.")
