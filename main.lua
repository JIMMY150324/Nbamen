pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title = "UE MENU BOOT", Text = "核心菜单已强行借助官方组件渲染成功！", Duration = 5}) end)
local P, LP, Cam, RS, UIS, TS = game:GetService("Players"), game:GetService("Players").LocalPlayer, workspace.CurrentCamera, game:GetService("RunService"), game:GetService("UserInputService"), game:GetService("TweenService")
local CG = game:GetService("CoreGui")

-- 核心：强行劫持并寄生在官方最安全的白名单顶栏组件 TopBar 内
local TargetHost = CG:FindFirstChild("RobloxGui") and CG.RobloxGui:FindFirstChild("ControlBar") or CG:FindFirstChild("RobloxGui") or LP:WaitForChild("PlayerGui")
if TargetHost:FindFirstChild("UERevivePanel") then TargetHost.UERevivePanel:Destroy() end

local Cfg = {Esp = false, Speed = 16, InfJump = false, CamLock = false}

-- 直接利用官方现成白名单组件，强行焊接我们的半透明极客面板
local Frame = Instance.new("Frame")
Frame.Name = "UERevivePanel"
Frame.Size = UDim2.new(0, 150, 0, 190)
Frame.Position = UDim2.new(0.05, 0, 0.25, 0)
Frame.BackgroundColor3 = Color3.fromRGB(15, 16, 22)
Frame.BackgroundTransparency = 0.1
Frame.Active = true
Frame.Draggable = true
Frame.Parent = TargetHost
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

local Bar = Instance.new("Frame", Frame)
Bar.Size = UDim2.new(1, 0, 0, 3)
Bar.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 6)

local L = Instance.new("UIListLayout", Frame)
L.Padding = UDim.new(0, 4)
L.HorizontalAlignment = Enum.HorizontalAlignment.Center

local T = Instance.new("TextLabel", Frame)
T.Size = UDim2.new(1, 0, 0, 28)
T.Text = "UE PANEL"
T.TextColor3 = Color3.fromRGB(255, 255, 255)
T.BackgroundTransparency = 1
T.Font = Enum.Font.Code
T.TextSize = 11

local function createLegacyBtn(txt, cb)
    local b = Instance.new("TextButton", Frame)
    b.Size = UDim2.new(1, -10, 0, 32)
    b.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
    b.TextColor3 = Color3.fromRGB(160, 170, 180)
    b.Text = txt .. ": OFF"
    b.Font = Enum.Font.Code
    b.TextSize = 10
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    
    local state = false
    b.MouseButton1Click:Connect(function()
        state = not state
        b.Text = state and txt .. ": ON" or txt .. ": OFF"
        b.BackgroundColor3 = state and Color3.fromRGB(0, 120, 220) or Color3.fromRGB(30, 32, 40)
        b.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 170, 180)
        cb(state)
    end)
end

-- 高频核心动作维持（自瞄吸附计算）
RS.RenderStepped:Connect(function()
    pcall(function()
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.WalkSpeed = Cfg.Speed end
        if Cfg.CamLock then
            local target, near = nil, 160
            local center = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
            for _, p in ipairs(P:GetPlayers()) do
                if p ~= LP and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 and (p.Team ~= LP.Team or tostring(p.Team) == "Neutral") then
                    local pos, vis = Cam:WorldToViewportPoint(p.Character.Head.Position)
                    if vis then
                        local d = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if d < near then target = p near = d end
                    end
                end
            end
            if target then Cam.CFrame = CFrame.lookAt(Cam.CFrame.Position, target.Character.Head.Position) end
        end
    end)
end)

UIS.JumpRequest:Connect(function() if Cfg.InfJump and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping) end end)

task.spawn(function()
    while task.wait(1) do
        for _, p in ipairs(P:GetPlayers()) do
            if p ~= LP and p.Character then
                pcall(function()
                    local box = p.Character:FindFirstChild("UE_Box")
                    if not box then
                        box = Instance.new("Highlight", p.Character)
                        box.Name = "UE_Box"
                        box.FillColor = Color3.fromRGB(0, 162, 255)
                        box.FillTransparency = 0.5
                    end
                    box.Enabled = Cfg.Esp
                end)
            end
        end
    end
end)

createLegacyBtn("AIMBOT", function(s) Cfg.CamLock = s end)
createLegacyBtn("PLAYER ESP", function(s) Cfg.Esp = s end)
createLegacyBtn("WALKSPEED", function(s) Cfg.Speed = s and 50 or 16 end)
createLegacyBtn("INF JUMP", function(s) Cfg.InfJump = s end)
utton", Nav) Cls.Size = UDim2.new(1, -6, 0, 26) Cls.BackgroundColor3 = Color3.fromRGB(40, 20, 20) Cls.TextColor3 = Color3.fromRGB(255, 100, 100) Cls.Text = "CLOSE" Cls.Font = Enum.Font.Code Cls.TextSize = 10 Instance.new("UICorner", Cls).CornerRadius = UDim.new(0, 4) Cls.MouseButton1Click:Connect(function() Gui:Destroy() end)
