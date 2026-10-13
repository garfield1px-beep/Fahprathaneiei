-- Services
local plrs = game:GetService("Players")
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local sg = game:GetService("StarterGui")
local coreGui = game:GetService("CoreGui")
local vu = game:GetService("VirtualUser")
local cam = workspace.CurrentCamera
local lp = plrs.LocalPlayer

-- Global Configuration
local config = {
    enabled = true,
    useAimlock = true,
    useSilentAim = true,
    useEsp = true,
    farmAtm = false,
    farmBank = false,
    maxLockDistance = 300,
    maxEspDistance = 500,
    part = "Head",
    y_offset = -0.6,
    fov = 120,
    thick = 2,
    idle_clr = Color3.fromRGB(235, 64, 52),
    target_clr = Color3.fromRGB(50, 205, 50)
}

local target = nil
local espDrawings = {}

-- Create Drawing FOV Circle
local circle = Drawing.new("Circle")
circle.Visible = true
circle.Filled = false
circle.Radius = config.fov
circle.Thickness = config.thick
circle.Color = config.idle_clr

---------------------------------------------------------
-- 🎨 CREATE MAIN GUI CONTAINER
---------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FahprathanCamlockUI"
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
LockBtn.Size = UDim2.new(0, 110, 0, 50)
LockBtn.Position = UDim2.new(0.8, 0, 0.4, 0)
LockBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
LockBtn.Text = "LOCK"
LockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LockBtn.Font = Enum.Font.GothamBold
LockBtn.TextSize = 16
LockBtn.Active = true
LockBtn.Draggable = true
LockBtn.Parent = ScreenGui

Instance.new("UICorner", LockBtn).CornerRadius = UDim.new(0, 12)

local LockBtnStroke = Instance.new("UIStroke", LockBtn)
LockBtnStroke.Color = Color3.fromRGB(255, 255, 255)
LockBtnStroke.Thickness = 2

---------------------------------------------------------
-- 🖼️ MAIN UI PANEL
---------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 310)
MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Header Bar
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local CreditTitle = Instance.new("TextLabel")
CreditTitle.Size = UDim2.new(0.6, 0, 1, 0)
CreditTitle.Position = UDim2.new(0, 12, 0, 0)
CreditTitle.BackgroundTransparency = 1
CreditTitle.Text = "Fahprathan script"
CreditTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
CreditTitle.TextXAlignment = Enum.TextXAlignment.Left
CreditTitle.Font = Enum.Font.GothamBold
CreditTitle.TextSize = 15
CreditTitle.Parent = Header

-- Minimize Button
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -35, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 18
MinimizeBtn.Parent = Header

Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)

---------------------------------------------------------
-- 📂 CONTENT & TAB SYSTEM (5 TABS)
---------------------------------------------------------
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -40)
ContentFrame.Position = UDim2.new(0, 0, 0, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 30)
TabBar.Position = UDim2.new(0, 10, 0, 8)
TabBar.BackgroundTransparency = 1
TabBar.Parent = ContentFrame

local TabListLayout = Instance.new("UIListLayout", TabBar)
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 4)

local function createTabBtn(text, layoutOrder)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.185, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(180, 180, 190)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 10
    btn.LayoutOrder = layoutOrder
    btn.Parent = TabBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local Tab1Btn = createTabBtn("Aim", 1)
local Tab2Btn = createTabBtn("Farm", 2)
local Tab3Btn = createTabBtn("ESP", 3)
local Tab4Btn = createTabBtn("Range", 4)
local Tab5Btn = createTabBtn("Target", 5)

local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -20, 0, 215)
Container.Position = UDim2.new(0, 10, 0, 45)
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
local FarmTab = createTabContainer()
local ESPTab = createTabContainer()
local RangeTab = createTabContainer()
local TargetTab = createTabContainer()

AimTab.Visible = true
Tab1Btn.BackgroundColor3 = Color3.fromRGB(60, 110, 240)
Tab1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)

local function switchTab(selectedBtn, selectedTab)
    for _, btn in ipairs(TabBar:GetChildren()) do
        if btn:IsA("TextButton") then
            btn.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
            btn.TextColor3 = Color3.fromRGB(180, 180, 190)
        end
    end
    AimTab.Visible = false
    FarmTab.Visible = false
    ESPTab.Visible = false
    RangeTab.Visible = false
    TargetTab.Visible = false
    
    selectedBtn.BackgroundColor3 = Color3.fromRGB(60, 110, 240)
    selectedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    selectedTab.Visible = true
end

Tab1Btn.MouseButton1Click:Connect(function() switchTab(Tab1Btn, AimTab) end)
Tab2Btn.MouseButton1Click:Connect(function() switchTab(Tab2Btn, FarmTab) end)
Tab3Btn.MouseButton1Click:Connect(function() switchTab(Tab3Btn, ESPTab) end)
Tab4Btn.MouseButton1Click:Connect(function() switchTab(Tab4Btn, RangeTab) end)
Tab5Btn.MouseButton1Click:Connect(function() switchTab(Tab5Btn, TargetTab) end)

---------------------------------------------------------
-- ⚙️ MENU CONTROLS
---------------------------------------------------------

-- 1. Aim Tab
local AimlockToggle = Instance.new("TextButton")
AimlockToggle.Size = UDim2.new(1, 0, 0, 42)
AimlockToggle.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
AimlockToggle.Text = "Cam Lock (กล้องตาม): ON"
AimlockToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AimlockToggle.Font = Enum.Font.GothamBold
AimlockToggle.TextSize = 12
AimlockToggle.Parent = AimTab
Instance.new("UICorner", AimlockToggle).CornerRadius = UDim.new(0, 6)

local SilentAimToggle = Instance.new("TextButton")
SilentAimToggle.Size = UDim2.new(1, 0, 0, 42)
SilentAimToggle.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
SilentAimToggle.Text = "Silent Aim (กระสุนโค้ง): ON"
SilentAimToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
SilentAimToggle.Font = Enum.Font.GothamBold
SilentAimToggle.TextSize = 12
SilentAimToggle.Parent = AimTab
Instance.new("UICorner", SilentAimToggle).CornerRadius = UDim.new(0, 6)

-- 2. Auto Farm Tab
local AtmFarmToggle = Instance.new("TextButton")
AtmFarmToggle.Size = UDim2.new(1, 0, 0, 42)
AtmFarmToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
AtmFarmToggle.Text = "Auto Farm ATM: OFF"
AtmFarmToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AtmFarmToggle.Font = Enum.Font.GothamBold
AtmFarmToggle.TextSize = 12
AtmFarmToggle.Parent = FarmTab
Instance.new("UICorner", AtmFarmToggle).CornerRadius = UDim.new(0, 6)

local BankFarmToggle = Instance.new("TextButton")
BankFarmToggle.Size = UDim2.new(1, 0, 0, 42)
BankFarmToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
BankFarmToggle.Text = "Auto Farm Bank Vault: OFF"
BankFarmToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
BankFarmToggle.Font = Enum.Font.GothamBold
BankFarmToggle.TextSize = 12
BankFarmToggle.Parent = FarmTab
Instance.new("UICorner", BankFarmToggle).CornerRadius = UDim.new(0, 6)

-- 3. ESP Tab
local EspToggle = Instance.new("TextButton")
EspToggle.Size = UDim2.new(1, 0, 0, 38)
EspToggle.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
EspToggle.Text = "ESP มองทะลุกำแพง: ON"
EspToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
EspToggle.Font = Enum.Font.GothamBold
EspToggle.TextSize = 12
EspToggle.Parent = ESPTab
Instance.new("UICorner", EspToggle).CornerRadius = UDim.new(0, 6)

local EspRangeLabel = Instance.new("TextLabel")
EspRangeLabel.Size = UDim2.new(1, 0, 0, 20)
EspRangeLabel.BackgroundTransparency = 1
EspRangeLabel.Text = "ESP Range: " .. config.maxEspDistance .. "m"
EspRangeLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
EspRangeLabel.Font = Enum.Font.GothamSemibold
EspRangeLabel.TextSize = 12
EspRangeLabel.Parent = ESPTab

local EspRangeFrame = Instance.new("Frame")
EspRangeFrame.Size = UDim2.new(1, 0, 0, 32)
EspRangeFrame.BackgroundTransparency = 1
EspRangeFrame.Parent = ESPTab

local EspRangeMinus = Instance.new("TextButton")
EspRangeMinus.Size = UDim2.new(0.48, 0, 1, 0)
EspRangeMinus.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
EspRangeMinus.Text = "- 50m ESP"
EspRangeMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
EspRangeMinus.Font = Enum.Font.GothamSemibold
EspRangeMinus.TextSize = 12
EspRangeMinus.Parent = EspRangeFrame
Instance.new("UICorner", EspRangeMinus).CornerRadius = UDim.new(0, 6)

local EspRangePlus = Instance.new("TextButton")
EspRangePlus.Size = UDim2.new(0.48, 0, 1, 0)
EspRangePlus.Position = UDim2.new(0.52, 0, 0, 0)
EspRangePlus.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
EspRangePlus.Text = "+ 50m ESP"
EspRangePlus.TextColor3 = Color3.fromRGB(255, 255, 255)
EspRangePlus.Font = Enum.Font.GothamSemibold
EspRangePlus.TextSize = 12
EspRangePlus.Parent = EspRangeFrame
Instance.new("UICorner", EspRangePlus).CornerRadius = UDim.new(0, 6)

-- 4. Range & FOV Tab
local FovLabel = Instance.new("TextLabel")
FovLabel.Size = UDim2.new(1, 0, 0, 20)
FovLabel.BackgroundTransparency = 1
FovLabel.Text = "FOV Circle Size: " .. config.fov
FovLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
FovLabel.Font = Enum.Font.GothamSemibold
FovLabel.TextSize = 12
FovLabel.Parent = RangeTab

local FovControlFrame = Instance.new("Frame")
FovControlFrame.Size = UDim2.new(1, 0, 0, 32)
FovControlFrame.BackgroundTransparency = 1
FovControlFrame.Parent = RangeTab

local FovMinus = Instance.new("TextButton")
FovMinus.Size = UDim2.new(0.48, 0, 1, 0)
FovMinus.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
FovMinus.Text = "- 10 FOV"
FovMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
FovMinus.Font = Enum.Font.GothamSemibold
FovMinus.TextSize = 12
FovMinus.Parent = FovControlFrame
Instance.new("UICorner", FovMinus).CornerRadius = UDim.new(0, 6)

local FovPlus = Instance.new("TextButton")
FovPlus.Size = UDim2.new(0.48, 0, 1, 0)
FovPlus.Position = UDim2.new(0.52, 0, 0, 0)
FovPlus.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
FovPlus.Text = "+ 10 FOV"
FovPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
FovPlus.Font = Enum.Font.GothamSemibold
FovPlus.TextSize = 12
FovPlus.Parent = FovControlFrame
Instance.new("UICorner", FovPlus).CornerRadius = UDim.new(0, 6)

local LockRangeLabel = Instance.new("TextLabel")
LockRangeLabel.Size = UDim2.new(1, 0, 0, 20)
LockRangeLabel.BackgroundTransparency = 1
LockRangeLabel.Text = "Lock Distance: " .. config.maxLockDistance .. "m"
LockRangeLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
LockRangeLabel.Font = Enum.Font.GothamSemibold
LockRangeLabel.TextSize = 12
LockRangeLabel.Parent = RangeTab

local LockRangeFrame = Instance.new("Frame")
LockRangeFrame.Size = UDim2.new(1, 0, 0, 32)
LockRangeFrame.BackgroundTransparency = 1
LockRangeFrame.Parent = RangeTab

local LockRangeMinus = Instance.new("TextButton")
LockRangeMinus.Size = UDim2.new(0.48, 0, 1, 0)
LockRangeMinus.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
LockRangeMinus.Text = "- 50m Lock"
LockRangeMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
LockRangeMinus.Font = Enum.Font.GothamSemibold
LockRangeMinus.TextSize = 12
LockRangeMinus.Parent = LockRangeFrame
Instance.new("UICorner", LockRangeMinus).CornerRadius = UDim.new(0, 6)

local LockRangePlus = Instance.new("TextButton")
LockRangePlus.Size = UDim2.new(0.48, 0, 1, 0)
LockRangePlus.Position = UDim2.new(0.52, 0, 0, 0)
LockRangePlus.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
LockRangePlus.Text = "+ 50m Lock"
LockRangePlus.TextColor3 = Color3.fromRGB(255, 255, 255)
LockRangePlus.Font = Enum.Font.GothamSemibold
LockRangePlus.TextSize = 12
LockRangePlus.Parent = LockRangeFrame
Instance.new("UICorner", LockRangePlus).CornerRadius = UDim.new(0, 6)

-- 5. Target Tab
local HeadBtn = Instance.new("TextButton")
HeadBtn.Size = UDim2.new(1, 0, 0, 40)
HeadBtn.BackgroundColor3 = Color3.fromRGB(60, 110, 240)
HeadBtn.Text = "Target: Head (หัว)"
HeadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HeadBtn.Font = Enum.Font.GothamSemibold
HeadBtn.TextSize = 13
HeadBtn.Parent = TargetTab
Instance.new("UICorner", HeadBtn).CornerRadius = UDim.new(0, 6)

local TorsoBtn = Instance.new("TextButton")
TorsoBtn.Size = UDim2.new(1, 0, 0, 40)
TorsoBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
TorsoBtn.Text = "Target: HumanoidRootPart (ลำตัว)"
TorsoBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
TorsoBtn.Font = Enum.Font.GothamSemibold
TorsoBtn.TextSize = 13
TorsoBtn.Parent = TargetTab
Instance.new("UICorner", TorsoBtn).CornerRadius = UDim.new(0, 6)

---------------------------------------------------------
-- ⚙️ UI EVENT LOGIC
---------------------------------------------------------

AimlockToggle.MouseButton1Click:Connect(function()
    config.useAimlock = not config.useAimlock
    AimlockToggle.Text = config.useAimlock and "Cam Lock (กล้องตาม): ON" or "Cam Lock (กล้องตาม): OFF"
    AimlockToggle.BackgroundColor3 = config.useAimlock and Color3.fromRGB(40, 160, 80) or Color3.fromRGB(180, 50, 50)
end)

SilentAimToggle.MouseButton1Click:Connect(function()
    config.useSilentAim = not config.useSilentAim
    SilentAimToggle.Text = config.useSilentAim and "Silent Aim (กระสุนโค้ง): ON" or "Silent Aim (กระสุนโค้ง): OFF"
    SilentAimToggle.BackgroundColor3 = config.useSilentAim and Color3.fromRGB(40, 160, 80) or Color3.fromRGB(180, 50, 50)
end)

AtmFarmToggle.MouseButton1Click:Connect(function()
    config.farmAtm = not config.farmAtm
    if config.farmAtm then config.farmBank = false BankFarmToggle.Text = "Auto Farm Bank Vault: OFF" BankFarmToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50) end
    AtmFarmToggle.Text = config.farmAtm and "Auto Farm ATM: ON" or "Auto Farm ATM: OFF"
    AtmFarmToggle.BackgroundColor3 = config.farmAtm and Color3.fromRGB(40, 160, 80) or Color3.fromRGB(180, 50, 50)
end)

BankFarmToggle.MouseButton1Click:Connect(function()
    config.farmBank = not config.farmBank
    if config.farmBank then config.farmAtm = false AtmFarmToggle.Text = "Auto Farm ATM: OFF" AtmFarmToggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50) end
    BankFarmToggle.Text = config.farmBank and "Auto Farm Bank Vault: ON" or "Auto Farm Bank Vault: OFF"
    BankFarmToggle.BackgroundColor3 = config.farmBank and Color3.fromRGB(40, 160, 80) or Color3.fromRGB(180, 50, 50)
end)

EspToggle.MouseButton1Click:Connect(function()
    config.useEsp = not config.useEsp
    EspToggle.Text = config.useEsp and "ESP มองทะลุกำแพง: ON" or "ESP มองทะลุกำแพง: OFF"
    EspToggle.BackgroundColor3 = config.useEsp and Color3.fromRGB(40, 160, 80) or Color3.fromRGB(180, 50, 50)
    if not config.useEsp then
        for _, v in pairs(espDrawings) do
            for _, d in pairs(v) do d.Visible = false end
        end
    end
end)

EspRangeMinus.MouseButton1Click:Connect(function()
    config.maxEspDistance = math.max(50, config.maxEspDistance - 50)
    EspRangeLabel.Text = "ESP Range: " .. config.maxEspDistance .. "m"
end)

EspRangePlus.MouseButton1Click:Connect(function()
    config.maxEspDistance = math.min(3000, config.maxEspDistance + 50)
    EspRangeLabel.Text = "ESP Range: " .. config.maxEspDistance .. "m"
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

local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        ContentFrame.Visible = false
        MainFrame.Size = UDim2.new(0, 350, 0, 40)
        MinimizeBtn.Text = "+"
    else
        ContentFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 350, 0, 310)
        MinimizeBtn.Text = "-"
    end
end)

HeadBtn.MouseButton1Click:Connect(function()
    config.part = "Head"
    config.y_offset = -0.6
    HeadBtn.BackgroundColor3 = Color3.fromRGB(60, 110, 240)
    HeadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TorsoBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
    TorsoBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
end)

TorsoBtn.MouseButton1Click:Connect(function()
    config.part = "HumanoidRootPart"
    config.y_offset = 0
    TorsoBtn.BackgroundColor3 = Color3.fromRGB(60, 110, 240)
    TorsoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    HeadBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
    HeadBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
end)

---------------------------------------------------------
-- 💰 FIXED DAHood AUTO FARM LOGIC
---------------------------------------------------------

local function equipCombatTool()
    if lp.Character then
        local combatTool = lp.Backpack:FindFirstChild("Combat") or lp.Character:FindFirstChild("Combat") or lp.Backpack:FindFirstChild("[Combat]") or lp.Character:FindFirstChild("[Combat]")
        if combatTool then
            if combatTool.Parent == lp.Backpack then
                lp.Character.Humanoid:EquipTool(combatTool)
            end
            return combatTool
        end
    end
    return nil
end

local function pickUpMoney()
    if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local drops = workspace:FindFirstChild("Ignored") and workspace.Ignored:FindFirstChild("Drop") and workspace.Ignored.Drop:GetChildren() or workspace:GetChildren()
    for _, item in ipairs(drops) do
        if string.find(item.Name, "Money") or string.find(item.Name, "Cash") or item.Name == "Drop" then
            local mainPart = item:FindFirstChild("Handle") or item:FindFirstChild("Part") or item
            if mainPart and mainPart:IsA("BasePart") then
                if (mainPart.Position - lp.Character.HumanoidRootPart.Position).Magnitude <= 25 then
                    local clickDetector = item:FindFirstChildOfClass("ClickDetector") or mainPart:FindFirstChildOfClass("ClickDetector")
                    if clickDetector then
                        fireclickdetector(clickDetector)
                    else
                        firetouchinterest(lp.Character.HumanoidRootPart, mainPart, 0)
                        firetouchinterest(lp.Character.HumanoidRootPart, mainPart, 1)
                    end
                end
            end
        end
    end
end

task.spawn(function()
    while task.wait(0.15) do
        if config.farmAtm then
            pcall(function()
                if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") or lp.Character.Humanoid.Health <= 0 then return end
                
                local targetPart = nil
                local minDistance = math.huge
                
                -- ค้นหาตู้ ATM ในโฟลเดอร์ของ Da Hood
                local cashiersFolder = workspace:FindFirstChild("Map") and (workspace.Map:FindFirstChild("Cashiers") or workspace.Map:FindFirstChild("ATMs")) or workspace
                for _, obj in ipairs(cashiersFolder:GetDescendants()) do
                    if (string.find(obj.Name, "ATM") or string.find(obj.Name, "Cashier")) then
                        local headPart = obj:FindFirstChild("Head") or obj:FindFirstChild("Part") or obj:FindFirstChild("MainPart") or (obj:IsA("BasePart") and obj)
                        local hum = obj:FindFirstChildOfClass("Humanoid")
                        
                        if headPart and (not hum or hum.Health > 0) then
                            local dist = (headPart.Position - lp.Character.HumanoidRootPart.Position).Magnitude
                            if dist < minDistance then
                                minDistance = dist
                                targetPart = headPart
                            end
                        end
                    end
                end

                if targetPart then
                    -- วาร์ปไปตำแหน่งหน้าตู้
                    lp.Character.HumanoidRootPart.CFrame = targetPart.CFrame * CFrame.new(0, 0, 2)
                    
                    local tool = equipCombatTool()
                    if tool then
                        tool:Activate()
                    end
                    vu:Button1Down(Vector2.new(0,0))
                    vu:Button1Up(Vector2.new(0,0))

                    pickUpMoney()
                end
            end)
        elseif config.farmBank then
            pcall(function()
                if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") or lp.Character.Humanoid.Health <= 0 then return end
                
                local vault = workspace:FindFirstChild("BankVault", true) or workspace:FindFirstChild("Vault", true)
                if vault then
                    local targetPart = vault:IsA("BasePart") and vault or (vault:FindFirstChild("Part") or vault.PrimaryPart or vault:FindFirstChild("Head"))
                    if targetPart then
                        lp.Character.HumanoidRootPart.CFrame = targetPart.CFrame * CFrame.new(0, 0, 2.5)
                        
                        local tool = equipCombatTool()
                        if tool then tool:Activate() end
                        vu:Button1Down(Vector2.new(0,0))
                        vu:Button1Up(Vector2.new(0,0))

                        pickUpMoney()
                    end
                end
            end)
        end
    end
end)

---------------------------------------------------------
-- 🎯 COMBAT LOGIC & ESP RENDERING
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
        LockBtn.Text = "LOCK"
        LockBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
        notify("Fahprathan Script", "Unlocked")
    else
        local found = get_closest()
        if found then
            target = found
            local plrName = plrs:GetPlayerFromCharacter(target.Parent)
            local name = plrName and plrName.DisplayName or "Player"
            LockBtn.Text = "UNLOCK"
            LockBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            notify("Fahprathan Script", "Locked: " .. name)
        end
    end
end)

-- Main Render Loop (Aimlock, FOV, ESP)
rs.RenderStepped:Connect(function()
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    circle.Position = center
    circle.Radius = config.fov

    -- Camlock Logic
    if target and target.Parent and target.Parent:FindFirstChild("Humanoid") and target.Parent.Humanoid.Health > 0 then
        circle.Color = config.target_clr
        if config.useAimlock then
            local lock_pos = target.Position + Vector3.new(0, config.y_offset, 0)
            cam.CFrame = CFrame.new(cam.CFrame.Position, lock_pos)
        end
    else
        if target then
            target = nil
            LockBtn.Text = "LOCK"
            LockBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
            notify("Fahprathan Script", "Target lost")
        end
        circle.Color = config.idle_clr
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
                        box.Color = (v.Character == (target and target.Parent)) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
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
