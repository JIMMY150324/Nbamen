-- [[ 1. 安全卡密系统配置 ]]
local KeySettings = {
    CorrectKey = "RivalsPremium2026", -- 🔑 在这里设置你的卡密
    KeyLink = "https://linkvertise.com", -- 🌐 获取卡密的链接
    Note = "提示：加入官方社区频道即可免费获取今日最新卡密解锁特权！"
}

-- [[ 2. 初始化 UI 并触发卡密验证 ]]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu'))()
local Window = Rayfield:CreateWindow({
   Name = "RIVALS Open-Source Community Hub",
   LoadingTitle = "正在注入核心矩阵...",
   LoadingSubtitle = "by Community Open-Source Project",
   ConfigurationSaving = { Enabled = false },
   KeySystem = true, 
   Title = "安全验证中心",
   Subtitle = "验证通过后即可无缝兼容端手双端",
   Note = KeySettings.Note,
   FileName = "RivalsPremiumConfig",
   SaveKey = true, 
   Key = { KeySettings.CorrectKey } 
})

-- 卡密获取标签页
local KeyTab = Window:CreateTab("卡密获取", 4483345998)
KeyTab:CreateButton({
   Name = "点击复制卡密获取链接",
   Callback = function()
       pcall(function() setclipboard(KeySettings.KeyLink) end)
       Rayfield:Notify({Title = "成功", Content = "卡密网址已复制到剪贴板！", Duration = 3})
   end,
})

-- [[ 3. 核心依赖服务与全局防抖变量 ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- 作弊控制核心变量
local AimbotMode = "Legit" 
local AimbotEnabled = false
local AimSmoothness = 0.1
local AimPart = "Head"
local TeamCheck = true     

local FOVEnabled = true
local FOVRadius = 100
local FOVColor = Color3.fromRGB(255, 0, 0)

local ESPEnabled = false
local ESPFillColor = Color3.fromRGB(255, 0, 0)     
local ESPOutlineColor = Color3.fromRGB(255, 255, 255) 
local ESPFillTrans = 0.5                          

-- 屏幕 FOV 渲染组件
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 60
FOVCircle.Filled = false
FOVCircle.Transparency = 1

-- [[ 4. 高级算法：获取最精确的合法敌对目标 ]]
local function getBestTarget(maxDistance)
    local closestTarget = nil
    local shortestDistance = maxDistance

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(AimPart) then
            if TeamCheck and player.Team == LocalPlayer.Team then continue end
            
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health <= 0 then continue end

            local targetPart = player.Character[AimPart]
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)

            if onScreen then
                local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

                if distance < shortestDistance then
                    closestTarget = player
                    shortestDistance = distance
                end
            end
        end
    end
    return closestTarget
end

-- [[ 5. 高性能防卡顿 ESP 模块 ]]
local function applyESP(player)
    if not ESPEnabled or player == LocalPlayer then return end
    if TeamCheck and player.Team == LocalPlayer.Team then 
        local oldEsp = player.Character and player.Character:FindFirstChild("GlobalESP")
        if oldEsp then oldEsp:Destroy() end
        return 
    end
    
    if player.Character then
        local highlight = player.Character:FindFirstChild("GlobalESP")
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Name = "GlobalESP"
            highlight.Parent = player.Character
        end
        highlight.FillColor = ESPFillColor
        highlight.OutlineColor = ESPOutlineColor
        highlight.FillTransparency = ESPFillTrans
        highlight.Enabled = true
    end
end

local function removeESP(player)
    if player.Character then
        local highlight = player.Character:FindFirstChild("GlobalESP")
        if highlight then highlight:Destroy() end
    end
end

-- [[ 6. 核心功能：篡改元表实现暴力静默自瞄 (Rage Mode) ]]
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if AimbotEnabled and AimbotMode == "Rage" and not checkcaller() then
        if method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "Raycast" then
            local target = getBestTarget(FOVRadius)
            if target and target.Character and target.Character:FindFirstChild(AimPart) then
                return target.Character[AimPart], target.Character[AimPart].Position, Vector3.new(0, 1, 0), target.Character[AimPart].Material
            end
        end
    end
    return oldNamecall(self, ...)
end)

-- [[ 7. 本地视觉全解锁（异步线程安全模式） ]]
local function doUnlockAll()
    task.spawn(function() 
        local paths = {
            LocalPlayer:FindFirstChild("PlayerData"),
            LocalPlayer:FindFirstChild("Inventory"),
            ReplicatedStorage:FindFirstChild("PlayerData") and ReplicatedStorage.PlayerData:FindFirstChild(LocalPlayer.Name),
            LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Menu")
        }
        for _, root in pairs(paths) do
            if root then
                for _, val in pairs(root:GetDescendants()) do
                    if val:IsA("BoolValue") and (string.find(string.lower(val.Name), "own") or string.find(string.lower(val.Name), "unlock")) then
                        val.Value = true
                    elseif val:IsA("Folder") and (val.Name == "Skins" or val.Name == "Weapons") then
                        for _, item in pairs(val:GetChildren()) do
                            if item:IsA("BoolValue") then item.Value = true end
                        end
                    end
                end
            end
        end
        Rayfield:Notify({Title = "矩阵解锁", Content = "全道具、皮肤已全部本地激活！", Duration = 4})
    end)
end

-- [[ 8. 后台高帧率实时刷新渲染循环 ]]
RunService.RenderStepped:Connect(function()
    if FOVEnabled then
        FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
        FOVCircle.Radius = FOVRadius
        FOVCircle.Color = FOVColor
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end

    if AimbotEnabled and AimbotMode == "Legit" then
        local target = getBestTarget(FOVRadius)
        if target and target.Character and target.Character:FindFirstChild(AimPart) then
            local targetPos = target.Character[AimPart].Position
            local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, AimSmoothness)
        end
    end

    for _, player in pairs(Players:GetPlayers()) do
        if ESPEnabled then applyESP(player) else removeESP(player) end
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.Characterget:Connect(function()
        task.wait(0.5)
        if ESPEnabled then applyESP(player) end
    end)
end)

-- [[ 9. 构筑多功能控制面板界面 ]]
local AimTab = Window:CreateTab("智能自瞄", 4483345998)
local EspTab = Window:CreateTab("视觉透视", 4483345998)
local UtilityTab = Window:CreateTab("全物品解锁", 4483345998)

-- == 智能自瞄配置 ==
AimTab:CreateToggle({
   Name = "启用全自动锁敌（双端通用）",
   CurrentValue = false,
   Callback = function(Value) AimbotEnabled = Value end,
})

AimTab:CreateDropdown({
   Name = "自瞄模式选择",
   Options = {"Legit (平滑微调防封)", "Rage (静默子弹追踪)"},
   CurrentOption = {"Legit (平滑微调防封)"},
   MultipleOptions = false,
   Callback = function(Option) 
       if string.find(Option, "Legit") then AimbotMode = "Legit" else AimbotMode = "Rage" end
   end,
})

AimTab:CreateDropdown({
   Name = "精准锁敌部位",
   Options = {"Head", "HumanoidRootPart"},
   CurrentOption = {"Head"},
   MultipleOptions = false,
   Callback = function(Option) AimPart = Option end,
})

AimTab:CreateSlider({
   Name = "自瞄平滑度 (仅对Legit模式有效)",
   Min = 0.05,
   Max = 1,
   CurrentValue = 0.1,
   Increment = 0.05,
   Callback = function(Value) AimSmoothness = Value end,
})

AimTab:CreateToggle({
   Name = "智能过滤队友 (Team Check)",
   CurrentValue = true,
   Callback = function(Value) TeamCheck = Value end,
})

AimTab:CreateToggle({
   Name = "显示当前 FOV 圆圈",
   CurrentValue = true,
   Callback = function(Value) FOVEnabled = Value end,
})

AimTab:CreateSlider({
   Name = "FOV 锁敌范围半径",
   Min = 30,
   Max = 800,
   CurrentValue = 100,
   Increment = 10,
   Callback = function(Value) FOVRadius = Value end,
})

-- == 视觉透视配置 ==
EspTab:CreateToggle({
   Name = "开启全图敌人热成像 ESP",
   CurrentValue = false,
   Callback = function(Value) 
       ESPEnabled = Value 
       if not Value then
           for _, p in pairs(Players:GetPlayers()) do removeESP(p) end
       end
   end,
})

EspTab:CreateColorPicker({
    Name = "热成像高亮颜色",
    Color = Color3.fromRGB(255, 0, 0),
    Callback = function(Value) ESPFillColor = Value end
})

-- == 全物品解锁配置 ==
UtilityTab:CreateButton({
   Name = "⚡ 彻底解锁所有武器/刀具/皮肤 (本地视觉)",
   Callback = function() doUnlockAll() end,
})

Rayfield:Notify({Title = "核心矩阵加载成功", Content = "RIVALS 社区纯净开源版已就绪！", Duration = 5})
