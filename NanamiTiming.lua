-- Nanami timing menu, extracted from the supplied aba.rbxl.
local player = game:GetService("Players").LocalPlayer
assert(player, "Run this script on the client")
local PlayerGui_1 = player:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local nanamiCheck = ReplicatedStorage:WaitForChild("NanamiCheck", 15)
assert(nanamiCheck and nanamiCheck:IsA("RemoteFunction"), "NanamiCheck was not found. Run this in the supplied ABA place after it loads.")
local cutTemplate = ReplicatedStorage:WaitForChild("NanamiCutGUI", 15)
assert(cutTemplate, "NanamiCutGUI was not found in this place")

-- Local Nanami practice controls. Defaults to manual timing each session.
local nanamiAutoTiming = false
do
    local gui = Instance.new("ScreenGui")
    gui.Name = "NanamiTimingMenu"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 50
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local previous = PlayerGui_1:FindFirstChild(gui.Name)
    if previous then previous:Destroy() end
    local panel = Instance.new("Frame")
    panel.Name = "Panel"
    panel.AnchorPoint = Vector2.new(1, 0)
    panel.Position = UDim2.new(1, -18, 0, 70)
    panel.Size = UDim2.fromOffset(240, 144)
    panel.BackgroundColor3 = Color3.fromRGB(24, 27, 34)
    panel.BorderSizePixel = 0
    panel.Parent = gui
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", panel)
    stroke.Color = Color3.fromRGB(75, 84, 101)
    local title = Instance.new("TextLabel", panel)
    title.Size = UDim2.new(1, -52, 0, 42)
    title.Position = UDim2.fromOffset(14, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextColor3 = Color3.fromRGB(240, 243, 250)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "Nanami Timing"
    local collapse = Instance.new("TextButton", panel)
    collapse.Name = "Collapse"
    collapse.Position = UDim2.new(1, -42, 0, 5)
    collapse.Size = UDim2.fromOffset(34, 32)
    collapse.BackgroundTransparency = 1
    collapse.Font = Enum.Font.GothamBold
    collapse.TextSize = 22
    collapse.TextColor3 = title.TextColor3
    collapse.Text = "-"
    local toggle = Instance.new("TextButton", panel)
    toggle.Name = "AutoTimingToggle"
    toggle.Position = UDim2.fromOffset(12, 48)
    toggle.Size = UDim2.new(1, -24, 0, 42)
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 14
    toggle.TextColor3 = Color3.new(1, 1, 1)
    toggle.BorderSizePixel = 0
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 7)
    local hint = Instance.new("TextLabel", panel)
    hint.Position = UDim2.fromOffset(14, 98)
    hint.Size = UDim2.new(1, -28, 0, 34)
    hint.BackgroundTransparency = 1
    hint.Font = Enum.Font.Gotham
    hint.TextSize = 12
    hint.TextColor3 = Color3.fromRGB(178, 187, 204)
    hint.TextWrapped = true
    local function refresh()
        toggle.Text = "Auto Timing: " .. (nanamiAutoTiming and "ON" or "OFF")
        toggle.BackgroundColor3 = nanamiAutoTiming and Color3.fromRGB(35, 116, 82) or Color3.fromRGB(57, 64, 79)
        hint.Text = nanamiAutoTiming and "Automatically confirms inside the ratio window." or "Manual timing: click, tap, or press B."
        gui:SetAttribute("AutoTimingEnabled", nanamiAutoTiming)
    end
    toggle.Activated:Connect(function()
        nanamiAutoTiming = not nanamiAutoTiming
        refresh()
    end)
    local expanded = true
    collapse.Activated:Connect(function()
        expanded = not expanded
        toggle.Visible = expanded
        hint.Visible = expanded
        panel.Size = UDim2.fromOffset(240, expanded and 144 or 42)
        collapse.Text = expanded and "-" or "+"
    end)
    refresh()
    gui.Parent = PlayerGui_1
end

nanamiCheck.OnClientInvoke = function(a1, a2, a3)
    --[[
      line: 373
    ]]
    if typeof(a1) ~= "Instance" or typeof(a3) ~= "Instance" or type(a2) ~= "number" or a2 <= 0 or a2 ~= a2 or a2 == math.huge then
        return false, nil, true
    end
    local HumanoidRootPart_6 = a1:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart_6 then return false, nil, true end
    local v24 = cutTemplate:Clone()
    v24.MainBar.Rotation = -80
    v24.Parent = HumanoidRootPart_6
    v24.Adornee = HumanoidRootPart_6
    local UserInputService_2 = game:GetService("UserInputService")
    local u1 = false
    local u2 = false
    local u3 = false
    local v25 = UserInputService_2.InputBegan:Connect(
        function(a4, gameProcessedEvent)
            --[[
              line: 387
              upvalues:
                u1 (ref, index: 1)
                u2 (ref, index: 2)
                u3 (ref, index: 3)
            ]]
            if gameProcessedEvent or nanamiAutoTiming or u1 or a4.UserInputType ~= Enum.UserInputType.MouseButton1 and a4.UserInputType ~= Enum.UserInputType.Touch and a4.KeyCode ~= Enum.KeyCode.ButtonB then
                return
            end
            if u2 then
                u3 = true
            else
                u1 = true
            end
        end
    )
    local v26 = 0.005
    local v28 = 0
    while v26 < 1 and a3.Parent and HumanoidRootPart_6.Parent and (a3:GetAttribute("NANAMIAIM")) and not u1 and not u3 do
        local v29 = task.wait()
        local v30 = v29 / a2
        local v31 = math.abs(0.7 - v26)
        if v26 >= 0.7 then
            v24.MainBar.Rotation = 0
        else
            v24.MainBar.Rotation = ((v26 / 0.7) * 80) + -80
        end
        if v31 >= 0.025 then
            if v31 < 0.05 then
                v30 = v30 / 4
            end
        else
            v30 = v30 / 8
        end
        local previousPosition = v26
        v26 = v26 + v30
        -- Catch a crossing even if one slow frame jumps over the entire window.
        if nanamiAutoTiming and previousPosition <= 0.7 and v26 >= 0.7 then
            v26 = 0.7
        end
        v24.MainBar.Cutter.Position = UDim2.new(v26, 0, 0.5, 0)
        if math.abs(0.7 - v26) >= 0.02 then
            u2 = false
        else
            u2 = true
        end
        -- Use the same success flag and acceptance window as manual input.
        if nanamiAutoTiming and u2 then
            u3 = true
        end
        v28 = (u2 and (v28 + v29)) or v28
    end
    v25:Disconnect()
    if (u3) and (a3:GetAttribute("NANAMIAIM")) then
        v24.MainBar.Cutter.Position = UDim2.new(0.7, 0, 0.5, 0)
        local v32 = TweenInfo.new(0.25)
        local tbl_5 = {}
        tbl_5.Size = UDim2.new(10, 200, 10, 200)
        game.TweenService:Create(v24, v32, tbl_5):Play()
        v24.MainBar.Cutter.Size = UDim2.new(0.016, 0, 12, 0)
        local v33 = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
        local tbl_6 = {BackgroundTransparency = 1}
        tbl_6.Size = UDim2.new(0, 0, 24, 0)
        tbl_6.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        game.TweenService:Create(v24.MainBar.Cutter, v33, tbl_6):Play()
        local v34 = Instance.new("ColorCorrectionEffect")
        v34.Parent = game.Lighting
        v34.TintColor = Color3.fromRGB()
        game.Debris:AddItem(v34, 0.15)
    end
    game.Debris:AddItem(v24, 0.5)
    local v35 = u3
    return v35, nil, true
end
