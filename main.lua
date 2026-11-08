-- ==========================================
-- Delta 手机端「全能通解」适配菜单
-- ==========================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- 清理可能残留的旧菜单
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
if PlayerGui:FindFirstChild("DeltaMegaMenu") then PlayerGui.DeltaMegaMenu:Destroy() end

-- 功能配置状态
local Config = {
    Speed = 16,
    JumpPower = 50,
    InfJump = false,
    Aimbot = false,
    Esp = false
}

-- 核心 UI 容器
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaMegaMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- 主背景板
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 320)
MainFrame.Position = UDim2.new(0.15, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- 霓虹顶部装饰条
local GlowLine = Instance.new("Frame")
GlowLine.Size = UDim2.new(1, 0, 0, 4)
GlowLine.BackgroundColor3 = Color3.fromRGB(0, 255, 204)
GlowLine.BorderSizePixel = 0
GlowLine.Parent = MainFrame
local LineCorner = Instance.new("UICorner")
LineCorner.CornerRadius = UDim.new(0, 12)
LineCorner.Parent = GlowLine

-- 标题
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 4)
Title.Text = "⚡ DELTA ALL-IN-ONE ⚡"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.Parent = MainFrame

-- 滚动区域（防止功能太多装不下）
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -60)
Scroll.Position = UDim2.new(0, 10, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.CanvasSize = UDim2.new(0, 0, 0, 360)
Scroll.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 8)
ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ListLayout.Parent = Scroll

-- 通用功能按钮生成器
local function addToggle(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 42)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Text = text .. " [关]"
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 15
    btn.Parent = Scroll

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and text .. " [开]" or text .. " [关]"
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 180, 130) or Color3.fromRGB(45, 45, 55)
        btn.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
        callback(state)
    end)
end

-- ==========================================
-- 功能核心逻辑实现
-- ==========================================

-- 1. 速度与高跳维持
RunService.Heartbeat:Connect(function()
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Config.Speed
            LocalPlayer.Character.Humanoid.JumpPower = Config.JumpPower
        end
    end)
end)

-- 2. 无限跳跃
UserInputService.JumpRequest:Connect(function()
    if Config.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- 3. 自瞄 (自动锁定最近敌人)
local function getClosestPlayer()
    local closest = nil
    local maxDist = 300 -- 屏幕像素锁定范围
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
            if onScreen then
                local mouse = UserInputService:GetMouseLocation()
                local dist = (Vector2.new(pos.X, pos.Y) - mouse).Magnitude
                if dist < maxDist then
                    closest = p
                    maxDist = dist
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if Config.Aimbot then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

-- 4. 手机透视 (高光 Highlight 模式，比画方框更稳且不卡顿)
local function applyESP(p)
    if p == LocalPlayer then return end
    local function setup(char)
        task.wait(0.5)
        if char:FindFirstChild("EspGlow") then char.EspGlow:Destroy() end
        local hl = Instance.new("Highlight")
        hl.Name = "EspGlow"
        hl.FillColor = Color3.fromRGB(255, 50, 50)
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.5
        hl.Enabled = Config.Esp
        hl.Parent = char
    end
    if p.Character then setup(p.Character) end
    p.CharacterAdded:Connect(setup)
end

for _, p in ipairs(Players:GetPlayers()) do applyESP(p) end
Players.PlayerAdded:Connect(applyESP)

-- ==========================================
-- 绑定功能到按钮
-- ==========================================

addToggle("人物急速挂", function(state)
    Config.Speed = state and 65 or 16
end)

addToggle("超级高跳", function(state)
    Config.JumpPower = state and 120 or 50
end)

addToggle("无线连跳 (InfJump)", function(state)
    Config.InfJump = state
end)

addToggle("全自动自瞄 (锁头)", function(state)
    Config.Aimbot = state
end)

addToggle("全局玩家透视 (透视)", function(state)
    Config.Esp = state
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("EspGlow") then
            p.Character.EspGlow.Enabled = state
        end
    end
end)

-- 关闭菜单按钮
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(1, -10, 0, 35)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Text = "安全销毁菜单"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 14
CloseBtn.Parent = Scroll
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
