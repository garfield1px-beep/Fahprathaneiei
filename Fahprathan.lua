-- Services
local plrs = game:GetService("Players")
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local sg = game:GetService("StarterGui")
local coreGui = game:GetService("CoreGui")
local stats = game:GetService("Stats")
local cam = workspace.CurrentCamera
local lp = plrs.LocalPlayer

-- Global Configuration
local config = {
    enabled = true,
    useAimlock = true,
    useSilentAim = true,
    useEsp = true,
    useTargetTracer = true,
    useRainbowFov = false,
    useCrosshair = false,
    useTargetInfo = true,
    smoothness = 0.15,
    maxLockDistance = 300,
    maxEspDistance = 500,
    part = "Head",
    y_offset = -0.6,
    fov = 120,
    thick = 2,
    idle_clr = Color3.fromRGB(255, 75, 75),
    target_clr = Color3.fromRGB(0, 230, 140)
}

local target = nil
local espDrawings = {}
local rainbowHue = 0

-- Create Custom Crosshair (Center Dot)
local crosshairDot = Drawing.new("Circle")
crosshairDot.Visible = false
crosshairDot.Radius = 3.5
crosshairDot.Filled = true
crosshairDot.Color = Color3.fromRGB(0, 255, 220)

-- Create Target Tracer Line
local targetLine = Drawing.new("Line")
targetLine.Visible = false
targetLine.Thickness = 2
targetLine.Color = Color3.fromRGB(0, 255, 180)

-- Create Drawing FOV Circle
local circle = Drawing.new("Circle")
circle.Visible = true
circle.Filled = false
circle.Radius = config.fov
circle.Thickness = config.thick
circle.Color = config.idle_clr

---------------------------------------------------------
-- 🎨 MAIN GUI CONTAINER & STYLING
---------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FahprathanLuxuryUI"
ScreenGui.ResetOnSpawn = false

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = coreGui
else
    ScreenGui.Parent = lp:WaitForChild("PlayerGui")
end

---------------------------------------------------------
-- 🔴 FLOATING LOCK BUTTON
---------------------------------------------------------
local LockBtn = Instance.new("TextButton")
LockBtn.Name = "FloatingLockBtn"
LockBtn.Size = UDim2.new(0, 115, 0, 52)
LockBtn.Position = UDim2.new(0.8, 0, 0.4, 0)
LockBtn.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
LockBtn.Text = "⚡ LOCK"
LockBtn.TextColor3 = Color3.fromRGB(0, 230, 255)
LockBtn.Font = Enum.Font.GothamBold
LockBtn.TextSize = 15
LockBtn.Active = true
LockBtn.Draggable = true
LockBtn.Parent = ScreenGui

Instance.new("UICorner", LockBtn).CornerRadius = UDim.new(0, 14)

local LockStroke = Instance.new("UIStroke", LockBtn)
LockStroke.Color = Color3.fromRGB(0, 170, 255)
LockStroke.Thickness = 2
LockStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

---------------------------------------------------------
-- 🩸 TARGET INFO DISPLAY CARD
---------------------------------------------------------
local TargetInfoFrame = Instance.new("Frame")
TargetInfoFrame.Name = "TargetInfoFrame"
TargetInfoFrame.Size = UDim2.new(0, 230, 0, 80)
TargetInfoFrame.Position = UDim2.new(0.5, -115, 0.78, 0)
TargetInfoFrame.BackgroundColor3 = Color3.fromRGB(14, 16, 24)
TargetInfoFrame.BorderSizePixel = 0
TargetInfoFrame.Visible = false
TargetInfoFrame.Parent = ScreenGui

Instance.new("UICorner", TargetInfoFrame).CornerRadius = UDim.new(0, 12)

local InfoStroke = Instance.new("UIStroke", TargetInfoFrame)
InfoStroke.Color = Color3.fromRGB(255, 60, 90)
InfoStroke.Thickness = 1.5

local TargetName = Instance.new("TextLabel")
TargetName.Size = UDim2.new(1, -16, 0, 24)
TargetName.Position = UDim2.new(0, 10, 0, 6)
TargetName.BackgroundTransparency = 1
TargetName.Text = "Target: None"
TargetName.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetName.Font = Enum.Font.GothamBold
TargetName.TextSize = 13
TargetName.TextXAlignment = Enum.TextXAlignment.Left
TargetName.Parent = TargetInfoFrame

local HealthBarBackground = Instance.new("Frame")
HealthBarBackground.Size = UDim2.new(1, -20, 0, 8)
HealthBarBackground.Position = UDim2.new(0, 10, 0, 34)
HealthBarBackground.BackgroundColor3 = Color3.fromRGB(30, 32, 45)
HealthBarBackground.BorderSizePixel = 0
HealthBarBackground.Parent = TargetInfoFrame

Instance.new("UICorner", HealthBarBackground).CornerRadius = UDim.new(0, 4)

local HealthBarFill = Instance.new("Frame")
HealthBarFill.Size = UDim2.new(1, 0, 1, 0)
HealthBarFill.BackgroundColor3 = Color3.fromRGB(0, 230, 140)
HealthBarFill.BorderSizePixel = 0
HealthBarFill.Parent = HealthBarBackground

Instance.new("UICorner", HealthBarFill).CornerRadius = UDim.new(0, 4)

local TargetDistLabel = Instance.new("TextLabel")
TargetDistLabel.Size = UDim2.new(1, -20, 0, 20)
TargetDistLabel.Position = UDim2.new(0, 10, 0, 48)
TargetDistLabel.BackgroundTransparency = 1
TargetDistLabel.Text = "HP: 100%  |  Distance: 0m"
TargetDistLabel.TextColor3 = Color3.fromRGB(170, 175, 195)
TargetDistLabel.Font = Enum.Font.GothamSemibold
TargetDistLabel.TextSize = 11
TargetDistLabel.TextXAlignment = Enum.TextXAlignment.Left
TargetDistLabel.Parent = TargetInfoFrame

---------------------------------------------------------
-- 🖼️ MAIN UI PANEL
---------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 365, 0, 315)
MainFrame.Position = UDim2.new(0.05, 0, 0.22, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(35, 42, 60)
MainStroke.Thickness = 1.5

-- Top Neon Line Accent
local NeonLine = Instance.new("Frame")
NeonLine.Size = UDim2.new(1, 0, 0, 2)
NeonLine.Position = UDim2.new(0, 0, 0, 0)
NeonLine.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
NeonLine.BorderSizePixel = 0
NeonLine.Parent = MainFrame

-- Header Bar
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 14)

local CreditTitle = Instance.new("TextLabel")
CreditTitle.Size = UDim2.new(0.48, 0, 1, 0)
CreditTitle.Position = UDim2.new(0, 14, 0, 0)
CreditTitle.BackgroundTransparency = 1
CreditTitle.Text = "✦ Fahprathan"
CreditTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
CreditTitle.TextXAlignment = Enum.TextXAlignment.Left
CreditTitle.Font = Enum.Font.GothamBold
CreditTitle.TextSize = 15
CreditTitle.Parent = Header

-- Ping / FPS Status Badge
local StatusFrame = Instance.new("Frame")
StatusFrame.Size = UDim2.new(0, 125, 0, 22)
StatusFrame.Position = UDim2.new(0.5, -5, 0.5, -11)
StatusFrame.BackgroundColor3 = Color3.fromRGB(25, 28, 40)
StatusFrame.BorderSizePixel = 0
StatusFrame.Parent = Header

Instance.new("UICorner", StatusFrame).CornerRadius = UDim.new(0, 6)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 1, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "FPS: 60  |  0ms"
StatusLabel.TextColor3 = Color3.fromRGB(0, 220, 255)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 10
StatusLabel.Parent = StatusFrame

-- Minimize Button
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)
MinimizeBtn.Position = UDim2.new(1, -34, 0, 7)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 34, 48)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 16
MinimizeBtn.Parent = Header

Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 8)

---------------------------------------------------------
-- 📂 TAB SYSTEM (5 TABS)
---------------------------------------------------------
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -42)
ContentFrame.Position = UDim2.new(0, 0, 0, 42)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 32)
TabBar.Position = UDim2.new(0, 10, 0, 8)
TabBar.BackgroundTransparency = 1
TabBar.Parent = ContentFrame

local TabListLayout = Instance.new("UIListLayout", TabBar)
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 4)

local function createTabBtn(text, layoutOrder)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.188, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(20, 23, 32)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(150, 155, 175)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 10
    btn.LayoutOrder = layoutOrder
    btn.Parent = TabBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local Tab1Btn = createTabBtn("Aim", 1)
local Tab2Btn = createTabBtn("Visuals", 2)
local Tab3Btn = createTabBtn("Range", 3)
local Tab4Btn = createTabBtn("Target", 4)
local Tab5Btn = createTabBtn("Misc", 5)

local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -20, 0, 215)
Container.Position = UDim2.new(0, 10, 0, 48)
Container.BackgroundTransparency = 1
Container.Parent = ContentFrame

local function createTabContainer()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.Parent = Container
    
    local layout = Instance.new("UIListLayout", frame)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    return frame
end

local AimTab = createTabContainer()
local VisualsTab = createTabContainer()
local RangeTab = createTabContainer()
local TargetTab = createTabContainer()
local MiscTab = createTabContainer()

AimTab.Visible = true
Tab1Btn.BackgroundColor3 = Color3.fromRGB(0, 130, 230)
Tab1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)

local function switchTab(selectedBtn, selectedTab)
    for _, btn in ipairs(TabBar:GetChildren()) do
        if btn:IsA("TextButton") then
            btn.BackgroundColor3 = Color3.fromRGB(20, 23, 32)
            btn.TextColor3 = Color3.fromRGB(150, 155, 175)
        end
    end
    AimTab.Visible = false
    VisualsTab.Visible = false
    RangeTab.Visible = false
    TargetTab.Visible = false
    MiscTab.Visible = false
    
    selectedBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 230)
    selectedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    selectedTab.Visible = true
end

Tab1Btn.MouseButton1Click:Connect(function() switchTab(Tab1Btn, AimTab) end)
Tab2Btn.MouseButton1Click:Connect(function() switchTab(Tab2Btn, VisualsTab) end)
Tab3Btn.MouseButton1Click:Connect(function() switchTab(Tab3Btn, RangeTab) end)
Tab4Btn.MouseButton1Click:Connect(function() switchTab(Tab4Btn, TargetTab) end)
Tab5Btn.MouseButton1Click:Connect(function() switchTab(Tab5Btn, MiscTab) end)

---------------------------------------------------------
-- ⚙️ MENU CONTROLS & STYLED BUTTONS
---------------------------------------------------------

-- 1. Aim Tab
local AimlockToggle = Instance.new("TextButton")
AimlockToggle.Size = UDim2.new(1, 0, 0, 38)
AimlockToggle.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
AimlockToggle.Text = "Cam Lock (กล้องตาม): ON"
AimlockToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AimlockToggle.Font = Enum.Font.GothamBold
AimlockToggle.TextSize = 12
AimlockToggle.Parent = AimTab
Instance.new("UICorner", AimlockToggle).CornerRadius = UDim.new(0, 8)

local SilentAimToggle = Instance.new("TextButton")
SilentAimToggle.Size = UDim2.new(1, 0, 0, 38)
SilentAimToggle.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
SilentAimToggle.Text = "Silent Aim (กระสุนโค้ง): ON"
SilentAimToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
SilentAimToggle.Font = Enum.Font.GothamBold
SilentAimToggle.TextSize = 12
SilentAimToggle.Parent = AimTab
Instance.new("UICorner", SilentAimToggle).CornerRadius = UDim.new(0, 8)

local SmoothLabel = Instance.new("TextLabel")
SmoothLabel.Size = UDim2.new(1, 0, 0, 18)
SmoothLabel.BackgroundTransparency = 1
SmoothLabel.Text = "Cam Smoothness (ความพริ้ว): " .. config.smoothness
SmoothLabel.TextColor3 = Color3.fromRGB(190, 195, 215)
SmoothLabel.Font = Enum.Font.GothamSemibold
SmoothLabel.TextSize = 11
SmoothLabel.Parent = AimTab

local SmoothFrame = Instance.new("Frame")
SmoothFrame.Size = UDim2.new(1, 0, 0, 32)
SmoothFrame.BackgroundTransparency = 1
SmoothFrame.Parent = AimTab

local SmoothMinus = Instance.new("TextButton")
SmoothMinus.Size = UDim2.new(0.48, 0, 1, 0)
SmoothMinus.BackgroundColor3 = Color3.fromRGB(24, 28, 40)
SmoothMinus.Text = "- Smooth"
SmoothMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
SmoothMinus.Font = Enum.Font.GothamSemibold
SmoothMinus.TextSize = 11
SmoothMinus.Parent = SmoothFrame
Instance.new("UICorner", SmoothMinus).CornerRadius = UDim.new(0, 6)

local SmoothPlus = Instance.new("TextButton")
SmoothPlus.Size = UDim2.new(0.48, 0, 1, 0)
SmoothPlus.Position = UDim2.new(0.52, 0, 0, 0)
SmoothPlus.BackgroundColor3 = Color3.fromRGB(24, 28, 40)
SmoothPlus.Text = "+ Smooth"
SmoothPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
SmoothPlus.Font = Enum.Font.GothamSemibold
SmoothPlus.TextSize = 11
SmoothPlus.Parent = SmoothFrame
Instance.new("UICorner", SmoothPlus).CornerRadius = UDim.new(0, 6)

-- 2. Visuals Tab
local EspToggle = Instance.new("TextButton")
EspToggle.Size = UDim2.new(1, 0, 0, 38)
EspToggle.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
EspToggle.Text = "ESP Box & Name: ON"
EspToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
EspToggle.Font = Enum.Font.GothamBold
EspToggle.TextSize = 12
EspToggle.Parent = VisualsTab
Instance.new("UICorner", EspToggle).CornerRadius = UDim.new(0, 8)

local TargetTracerToggle = Instance.new("TextButton")
TargetTracerToggle.Size = UDim2.new(1, 0, 0, 38)
TargetTracerToggle.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
TargetTracerToggle.Text = "Locked Target Line: ON"
TargetTracerToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetTracerToggle.Font = Enum.Font.GothamBold
TargetTracerToggle.TextSize = 12
TargetTracerToggle.Parent = VisualsTab
Instance.new("UICorner", TargetTracerToggle).CornerRadius = UDim.new(0, 8)

local RainbowFovToggle = Instance.new("TextButton")
RainbowFovToggle.Size = UDim2.new(1, 0, 0, 38)
RainbowFovToggle.BackgroundColor3 = Color3.fromRGB(180, 45, 55)
RainbowFovToggle.Text = "Rainbow FOV Circle: OFF"
RainbowFovToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
RainbowFovToggle.Font = Enum.Font.GothamBold
RainbowFovToggle.TextSize = 12
RainbowFovToggle.Parent = VisualsTab
Instance.new("UICorner", RainbowFovToggle).CornerRadius = UDim.new(0, 8)

-- 3. Range & FOV Tab
local FovLabel = Instance.new("TextLabel")
FovLabel.Size = UDim2.new(1, 0, 0, 18)
FovLabel.BackgroundTransparency = 1
FovLabel.Text = "FOV Circle Size: " .. config.fov
FovLabel.TextColor3 = Color3.fromRGB(190, 195, 215)
FovLabel.Font = Enum.Font.GothamSemibold
FovLabel.TextSize = 11
FovLabel.Parent = RangeTab

local FovControlFrame = Instance.new("Frame")
FovControlFrame.Size = UDim2.new(1, 0, 0, 32)
FovControlFrame.BackgroundTransparency = 1
FovControlFrame.Parent = RangeTab

local FovMinus = Instance.new("TextButton")
FovMinus.Size = UDim2.new(0.48, 0, 1, 0)
FovMinus.BackgroundColor3 = Color3.fromRGB(24, 28, 40)
FovMinus.Text = "- 10 FOV"
FovMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
FovMinus.Font = Enum.Font.GothamSemibold
FovMinus.TextSize = 11
FovMinus.Parent = FovControlFrame
Instance.new("UICorner", FovMinus).CornerRadius = UDim.new(0, 6)

local FovPlus = Instance.new("TextButton")
FovPlus.Size = UDim2.new(0.48, 0, 1, 0)
FovPlus.Position = UDim2.new(0.52, 0, 0, 0)
FovPlus.BackgroundColor3 = Color3.fromRGB(24, 28, 40)
FovPlus.Text = "+ 10 FOV"
FovPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
FovPlus.Font = Enum.Font.GothamSemibold
FovPlus.TextSize = 11
FovPlus.Parent = FovControlFrame
Instance.new("UICorner", FovPlus).CornerRadius = UDim.new(0, 6)

local LockRangeLabel = Instance.new("TextLabel")
LockRangeLabel.Size = UDim2.new(1, 0, 0, 18)
LockRangeLabel.BackgroundTransparency = 1
LockRangeLabel.Text = "Lock Distance: " .. config.maxLockDistance .. "m"
LockRangeLabel.TextColor3 = Color3.fromRGB(190, 195, 215)
LockRangeLabel.Font = Enum.Font.GothamSemibold
LockRangeLabel.TextSize = 11
LockRangeLabel.Parent = RangeTab

local LockRangeFrame = Instance.new("Frame")
LockRangeFrame.Size = UDim2.new(1, 0, 0, 32)
LockRangeFrame.BackgroundTransparency = 1
LockRangeFrame.Parent = RangeTab

local LockRangeMinus = Instance.new("TextButton")
LockRangeMinus.Size = UDim2.new(0.48, 0, 1, 0)
LockRangeMinus.BackgroundColor3 = Color3.fromRGB(24, 28, 40)
LockRangeMinus.Text = "- 50m Lock"
LockRangeMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
LockRangeMinus.Font = Enum.Font.GothamSemibold
LockRangeMinus.TextSize = 11
LockRangeMinus.Parent = LockRangeFrame
Instance.new("UICorner", LockRangeMinus).CornerRadius = UDim.new(0, 6)

local LockRangePlus = Instance.new("TextButton")
LockRangePlus.Size = UDim2.new(0.48, 0, 1, 0)
LockRangePlus.Position = UDim2.new(0.52, 0, 0, 0)
LockRangePlus.BackgroundColor3 = Color3.fromRGB(24, 28, 40)
LockRangePlus.Text = "+ 50m Lock"
LockRangePlus.TextColor3 = Color3.fromRGB(255, 255, 255)
LockRangePlus.Font = Enum.Font.GothamSemibold
LockRangePlus.TextSize = 11
LockRangePlus.Parent = LockRangeFrame
Instance.new("UICorner", LockRangePlus).CornerRadius = UDim.new(0, 6)

-- 4. Target Tab
local HeadBtn = Instance.new("TextButton")
HeadBtn.Size = UDim2.new(1, 0, 0, 40)
HeadBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 230)
HeadBtn.Text = "Target: Head (หัว)"
HeadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HeadBtn.Font = Enum.Font.GothamSemibold
HeadBtn.TextSize = 12
HeadBtn.Parent = TargetTab
Instance.new("UICorner", HeadBtn).CornerRadius = UDim.new(0, 8)

local TorsoBtn = Instance.new("TextButton")
TorsoBtn.Size = UDim2.new(1, 0, 0, 40)
TorsoBtn.BackgroundColor3 = Color3.fromRGB(20, 23, 32)
TorsoBtn.Text = "Target: HumanoidRootPart (ลำตัว)"
TorsoBtn.TextColor3 = Color3.fromRGB(160, 165, 185)
TorsoBtn.Font = Enum.Font.GothamSemibold
TorsoBtn.TextSize = 12
TorsoBtn.Parent = TargetTab
Instance.new("UICorner", TorsoBtn).CornerRadius = UDim.new(0, 8)

-- 5. Misc Tab
local TargetInfoToggle = Instance.new("TextButton")
TargetInfoToggle.Size = UDim2.new(1, 0, 0, 38)
TargetInfoToggle.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
TargetInfoToggle.Text = "Target Info Display: ON"
TargetInfoToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetInfoToggle.Font = Enum.Font.GothamBold
TargetInfoToggle.TextSize = 12
TargetInfoToggle.Parent = MiscTab
Instance.new("UICorner", TargetInfoToggle).CornerRadius = UDim.new(0, 8)

local CrosshairToggle = Instance.new("TextButton")
CrosshairToggle.Size = UDim2.new(1, 0, 0, 38)
CrosshairToggle.BackgroundColor3 = Color3.fromRGB(180, 45, 55)
CrosshairToggle.Text = "Custom Center Crosshair: OFF"
CrosshairToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
CrosshairToggle.Font = Enum.Font.GothamBold
CrosshairToggle.TextSize = 12
CrosshairToggle.Parent = MiscTab
Instance.new("UICorner", CrosshairToggle).CornerRadius = UDim.new(0, 8)

---------------------------------------------------------
-- ⚙️ UI EVENT LOGIC
---------------------------------------------------------

AimlockToggle.MouseButton1Click:Connect(function()
    config.useAimlock = not config.useAimlock
    AimlockToggle.Text = config.useAimlock and "Cam Lock (กล้องตาม): ON" or "Cam Lock (กล้องตาม): OFF"
    AimlockToggle.BackgroundColor3 = config.useAimlock and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(180, 45, 55)
end)

SilentAimToggle.MouseButton1Click:Connect(function()
    config.useSilentAim = not config.useSilentAim
    SilentAimToggle.Text = config.useSilentAim and "Silent Aim (กระสุนโค้ง): ON" or "Silent Aim (กระสุนโค้ง): OFF"
    SilentAimToggle.BackgroundColor3 = config.useSilentAim and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(180, 45, 55)
end)

SmoothMinus.MouseButton1Click:Connect(function()
    config.smoothness = math.max(0.02, math.floor((config.smoothness - 0.02) * 100) / 100)
    SmoothLabel.Text = "Cam Smoothness (ความพริ้ว): " .. config.smoothness
end)

SmoothPlus.MouseButton1Click:Connect(function()
    config.smoothness = math.min(1, math.floor((config.smoothness + 0.02) * 100) / 100)
    SmoothLabel.Text = "Cam Smoothness (ความพริ้ว): " .. config.smoothness
end)

EspToggle.MouseButton1Click:Connect(function()
    config.useEsp = not config.useEsp
    EspToggle.Text = config.useEsp and "ESP Box & Name: ON" or "ESP Box & Name: OFF"
    EspToggle.BackgroundColor3 = config.useEsp and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(180, 45, 55)
    if not config.useEsp then
        for _, v in pairs(espDrawings) do for _, d in pairs(v) do d.Visible = false end end
    end
end)

TargetTracerToggle.MouseButton1Click:Connect(function()
    config.useTargetTracer = not config.useTargetTracer
    TargetTracerToggle.Text = config.useTargetTracer and "Locked Target Line: ON" or "Locked Target Line: OFF"
    TargetTracerToggle.BackgroundColor3 = config.useTargetTracer and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(180, 45, 55)
end)

RainbowFovToggle.MouseButton1Click:Connect(function()
    config.useRainbowFov = not config.useRainbowFov
    RainbowFovToggle.Text = config.useRainbowFov and "Rainbow FOV Circle: ON" or "Rainbow FOV Circle: OFF"
    RainbowFovToggle.BackgroundColor3 = config.useRainbowFov and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(180, 45, 55)
end)

LockRangeMinus.MouseButton1Click:Connect(function()
    config.maxLockDistance = math.max(50, config.maxLockDistance - 50)
    LockRangeLabel.Text = "Lock Distance: " .. config.maxLockDistance .. "m"
end)

LockRangePlus.MouseButton1Click:Connect(function()
    config.maxLockDistance = math.min(2000, config.maxLockDistance + 50)
    LockRangeLabel.Text = "Lock Distance: " .. config.maxLockDistance .. "m"
end)

FovMinus.MouseButton1Click:Connect(function()
    config.fov = math.max(10, config.fov - 10)
    FovLabel.Text = "FOV Circle Size: " .. config.fov
end)

FovPlus.MouseButton1Click:Connect(function()
    config.fov = math.min(600, config.fov + 10)
    FovLabel.Text = "FOV Circle Size: " .. config.fov
end)

TargetInfoToggle.MouseButton1Click:Connect(function()
    config.useTargetInfo = not config.useTargetInfo
    TargetInfoToggle.Text = config.useTargetInfo and "Target Info Display: ON" or "Target Info Display: OFF"
    TargetInfoToggle.BackgroundColor3 = config.useTargetInfo and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(180, 45, 55)
    if not config.useTargetInfo then TargetInfoFrame.Visible = false end
end)

CrosshairToggle.MouseButton1Click:Connect(function()
    config.useCrosshair = not config.useCrosshair
    CrosshairToggle.Text = config.useCrosshair and "Custom Center Crosshair: ON" or "Custom Center Crosshair: OFF"
    CrosshairToggle.BackgroundColor3 = config.useCrosshair and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(180, 45, 55)
    crosshairDot.Visible = config.useCrosshair
end)

local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        ContentFrame.Visible = false
        MainFrame.Size = UDim2.new(0, 365, 0, 42)
        MinimizeBtn.Text = "+"
    else
        ContentFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 365, 0, 315)
        MinimizeBtn.Text = "-"
    end
end)

HeadBtn.MouseButton1Click:Connect(function()
    config.part = "Head"
    config.y_offset = -0.6
    HeadBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 230)
    HeadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TorsoBtn.BackgroundColor3 = Color3.fromRGB(20, 23, 32)
    TorsoBtn.TextColor3 = Color3.fromRGB(160, 165, 185)
end)

TorsoBtn.MouseButton1Click:Connect(function()
    config.part = "HumanoidRootPart"
    config.y_offset = 0
    TorsoBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 230)
    TorsoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    HeadBtn.BackgroundColor3 = Color3.fromRGB(20, 23, 32)
    HeadBtn.TextColor3 = Color3.fromRGB(160, 165, 185)
end)

---------------------------------------------------------
-- 🎯 COMBAT LOGIC & RENDER LOOP
---------------------------------------------------------

local function notify(title, msg)
    pcall(function()
        sg:SetCore("SendNotification", { Title = title, Text = msg, Duration = 1.5 })
    end)
end

local function get_closest()
    local dist = config.fov
    local temp_target = nil
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)

    for _, v in ipairs(plrs:GetPlayers()) do
        if v ~= lp and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local hrp = v.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local distance = (hrp.Position - cam.CFrame.Position).Magnitude
                if distance <= config.maxLockDistance then
                    local part = v.Character:FindFirstChild(config.part)
                    if part then
                        local pos, vis = cam:WorldToViewportPoint(part.Position)
                        if vis then
                            local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                            if mag < dist then
                                dist = mag
                                temp_target = part
                            end
                        end
                    end
                end
            end
        end
    end
    return temp_target
end

-- Hooking Silent Aim
local gmt = getrawmetatable(game)
local oldIndex = gmt.__index
local oldNamecall = gmt.__namecall
setreadonly(gmt, false)

gmt.__index = newcclosure(function(self, idx)
    if not checkcaller() and config.useSilentAim and target then
        if idx == "Hit" or idx == "Target" then
            local lock_pos = target.Position + Vector3.new(0, config.y_offset, 0)
            if idx == "Hit" then return CFrame.new(lock_pos)
            elseif idx == "Target" then return target end
        end
    end
    return oldIndex(self, idx)
end)

gmt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if not checkcaller() and config.useSilentAim and target then
        if method == "Raycast" and args[2] then
            local lock_pos = target.Position + Vector3.new(0, config.y_offset, 0)
            args[2] = (lock_pos - args[1]).Unit * 1000
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)

setreadonly(gmt, true)

-- Lock Button Click
LockBtn.MouseButton1Click:Connect(function()
    if target then
        target = nil
        LockBtn.Text = "⚡ LOCK"
        LockBtn.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
        LockBtn.TextColor3 = Color3.fromRGB(0, 230, 255)
        LockStroke.Color = Color3.fromRGB(0, 170, 255)
        TargetInfoFrame.Visible = false
        notify("Fahprathan Script", "Unlocked")
    else
        local found = get_closest()
        if found then
            target = found
            local plrName = plrs:GetPlayerFromCharacter(target.Parent)
            local name = plrName and plrName.DisplayName or "Player"
            LockBtn.Text = "UNLOCK"
            LockBtn.BackgroundColor3 = Color3.fromRGB(180, 45, 55)
            LockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            LockStroke.Color = Color3.fromRGB(255, 60, 90)
            notify("Fahprathan Script", "Locked: " .. name)
        end
    end
end)

-- Main Render Loop
rs.RenderStepped:Connect(function()
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    circle.Position = center
    circle.Radius = config.fov

    -- Center Crosshair Render
    if config.useCrosshair then
        crosshairDot.Position = center
        crosshairDot.Visible = true
    end

    -- FPS & Ping Counter Update
    local fps = math.floor(1 / rs.RenderStepped:Wait())
    local ping = math.floor(stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    StatusLabel.Text = "FPS: " .. fps .. "  |  " .. ping .. "ms"

    -- Rainbow FOV Mode
    if config.useRainbowFov then
        rainbowHue = (rainbowHue + 0.005) % 1
        circle.Color = Color3.fromHSV(rainbowHue, 0.8, 1)
    end

    -- Camlock & Target Info Logic
    if target and target.Parent and target.Parent:FindFirstChild("Humanoid") and target.Parent.Humanoid.Health > 0 then
        if not config.useRainbowFov then circle.Color = config.target_clr end
        
        local lock_pos = target.Position + Vector3.new(0, config.y_offset, 0)
        
        -- Smooth Camlock Transition
        if config.useAimlock then
            local currentCF = cam.CFrame
            local targetCF = CFrame.new(cam.CFrame.Position, lock_pos)
            cam.CFrame = currentCF:Lerp(targetCF, config.smoothness)
        end

        -- Target Info Display Update
        if config.useTargetInfo then
            local targetPlayer = plrs:GetPlayerFromCharacter(target.Parent)
            local hum = target.Parent:FindFirstChild("Humanoid")
            local hrp = target.Parent:FindFirstChild("HumanoidRootPart")
            
            if hum and hrp then
                local healthPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                local dist = math.floor((hrp.Position - cam.CFrame.Position).Magnitude)
                
                TargetName.Text = "Target: " .. (targetPlayer and targetPlayer.DisplayName or target.Parent.Name)
                TargetDistLabel.Text = "HP: " .. math.floor(healthPct * 100) .. "%  |  Distance: " .. dist .. "m"
                HealthBarFill.Size = UDim2.new(healthPct, 0, 1, 0)
                TargetInfoFrame.Visible = true
            end
        end

        -- Target Tracer Line Render
        if config.useTargetTracer then
            local pos, vis = cam:WorldToViewportPoint(lock_pos)
            if vis then
                targetLine.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
                targetLine.To = Vector2.new(pos.X, pos.Y)
                targetLine.Visible = true
            else
                targetLine.Visible = false
            end
        else
            targetLine.Visible = false
        end
    else
        if target then
            target = nil
            LockBtn.Text = "⚡ LOCK"
            LockBtn.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
            LockBtn.TextColor3 = Color3.fromRGB(0, 230, 255)
            LockStroke.Color = Color3.fromRGB(0, 170, 255)
            notify("Fahprathan Script", "Target lost")
        end
        if not config.useRainbowFov then circle.Color = config.idle_clr end
        targetLine.Visible = false
        TargetInfoFrame.Visible = false
    end

    -- ESP Render Loop
    for _, v in ipairs(plrs:GetPlayers()) do
        if v ~= lp then
            if not espDrawings[v] then
                espDrawings[v] = {
                    Box = Drawing.new("Square"),
                    Name = Drawing.new("Text")
                }
                espDrawings[v].Box.Filled = false
                espDrawings[v].Box.Thickness = 1.5
                espDrawings[v].Name.Size = 13
                espDrawings[v].Name.Center = true
                espDrawings[v].Name.Outline = true
                espDrawings[v].Name.Color = Color3.fromRGB(255, 255, 255)
            end

            local box = espDrawings[v].Box
            local nameText = espDrawings[v].Name

            if config.useEsp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                local hrp = v.Character.HumanoidRootPart
                local pos, vis = cam:WorldToViewportPoint(hrp.Position)
                if vis then
                    local dist = (hrp.Position - cam.CFrame.Position).Magnitude
                    if dist <= config.maxEspDistance then
                        local sizeX = 2000 / pos.Z
                        local sizeY = 3000 / pos.Z
                        
                        box.Size = Vector2.new(sizeX, sizeY)
                        box.Position = Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2)
                        box.Color = (v.Character == (target and target.Parent)) and Color3.fromRGB(0, 230, 140) or Color3.fromRGB(255, 255, 255)
                        box.Visible = true

                        nameText.Text = v.DisplayName .. " [" .. math.floor(dist) .. "m]"
                        nameText.Position = Vector2.new(pos.X, pos.Y - sizeY / 2 - 18)
                        nameText.Visible = true
                    else
                        box.Visible = false
                        nameText.Visible = false
                    end
                else
                    box.Visible = false
                    nameText.Visible = false
                end
            else
                box.Visible = false
                nameText.Visible = false
            end
        end
    end
end)
