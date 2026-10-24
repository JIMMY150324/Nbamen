-- [[ 1. 卡密与核心依赖配置 ]]
local KeySettings = { CorrectKey = "RivalsPremium2026", KeyLink = "https://linkvertise.com", Note = "移动端专用纯净验证版" }
local Rayfield = loadstring(game:HttpGet('https://sirius.menu'))()/rayfield
local Window = Rayfield:CreateWindow({
   Name = "RIVALS Delta Mobile Hub", LoadingTitle = "正在载入Delta优化矩阵...", LoadingSubtitle = "Mobile Stable",
   ConfigurationSaving = { Enabled = false }, KeySystem = true, Title = "安全验证中心", Subtitle = "移动端专用稳定接口",
   Note = KeySettings.Note, FileName = "DeltaRivalsConfig", SaveKey = true, Key = { KeySettings.CorrectKey } 
})

-- [[ 2. 全局环境控制变量 ]]
local Players, RunService = game:GetService("Players"), game:GetService("RunService")
local LocalPlayer, Camera, Mouse = Players.LocalPlayer, workspace.CurrentCamera, LocalPlayer:GetMouse()
local AimbotEnabled, AimSmoothness, AimPart, TeamCheck = false, 0.1, "Head", true     
local FOVEnabled, FOVRadius, ESPEnabled, ESPFillColor = true, 100, false, Color3.fromRGB(255, 0, 0)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness, FOVCircle.NumSides, FOVCircle.Filled, FOVCircle.Transparency = 1.5, 60, false, 1

-- [[ 3. 高度简化的高帧率自瞄核心逻辑 ]]
local function getMobileTarget()
    local closestTarget, shortestDistance = nil, FOVRadius
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(AimPart) then
            if TeamCheck and player.Team == LocalPlayer.Team then continue end
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health <= 0 then continue end
            
            local screenPos, onScreen = Camera:WorldToViewportPoint(player.Character[AimPart].Position)
            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if distance < shortestDistance then
                    closestTarget, shortestDistance = player, distance
                end
            end
        end
    end
    return closestTarget
end

-- [[ 4. 实时刷新主循环 (包含自动高亮透视清理与镜头跟踪) ]]
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
    FOVCircle.Radius = FOVRadius
    FOVCircle.Visible = FOVEnabled
    FOVCircle.Color = Color3.fromRGB(255, 0, 0)

    if AimbotEnabled then
        local target = getMobileTarget()
        if target and target.Character and target.Character:FindFirstChild(AimPart) then
            local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Character[AimPart].Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, AimSmoothness)
        end
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player ~= LocalPlayer then
            local hl = player.Character:FindFirstChild("GlobalESP")
            if ESPEnabled and (not TeamCheck or player.Team ~= LocalPlayer.Team) then
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "GlobalESP"
                    hl.Parent = player.Character
                end
                hl.FillColor = ESPFillColor
                hl.Enabled = true
            else
                if hl then hl:Destroy() end
            end
        end
    end
end)

-- [[ 5. 构筑移动端 UI 控制面板 ]]
local AimTab = Window:CreateTab("自动锁敌", 4483345998)
local EspTab = Window:CreateTab("透视热成像", 4483345998)

AimTab:CreateToggle({ Name = "开启全自动触控锁敌", CurrentValue = false, Callback = function(v) AimbotEnabled = v end })
AimTab:CreateSlider({ Name = "锁定平滑度 (推荐0.1)", Min = 0.05, Max = 1, CurrentValue = 0.1, Increment = 0.05, Callback = function(v) AimSmoothness = v end })
AimTab:CreateToggle({ Name = "显示触控范围圈 (FOV)", CurrentValue = true, Callback = function(v) FOVEnabled = v end })
AimTab:CreateSlider({ Name = "锁敌范围半径", Min = 30, Max = 500, CurrentValue = 100, Increment = 10, Callback = function(v) FOVRadius = v end })
EspTab:CreateToggle({ Name = "开启全图敌人热成像透视", CurrentValue = false, Callback = function(v) ESPEnabled = v end })
