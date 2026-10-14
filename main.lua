-- [[ 1. 安全卡密系统配置 ]]
local KeySettings = {
    CorrectKey = "NoisyRivals666", 
    KeyLink = "https://linkvertise.com", 
    Note = "提示：加入 Noisy 社区即可免费获取今日最新卡密解锁特权！"
}

-- [[ 2. 初始化 UI 并触发卡密验证（修复官方库解析路径） ]]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu'))()
local Window = Rayfield:CreateWindow({
   Name = "Noisy's RIVALS Elite Matrix",
   LoadingTitle = "正在注入 Noisy 核心矩阵...",
   LoadingSubtitle = "by Noisy",
   ConfigurationSaving = { Enabled = false },
   KeySystem = true, 
   Title = "Noisy 安全验证中心",
   Subtitle = "验证通过后即可无缝兼容端手双端",
   Note = KeySettings.Note,
   FileName = "NoisyRivalsPremium",
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
local AimbotMode = "Legit" -- "Legit" (平滑自瞄) / "Rage" (静默子弹追踪)
local AimbotEnabled = false
local AimSmoothness = 0.1
local AimPart = "Head"
local TeamCheck = true     -- 👥 智能阵营过滤开关

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
        -- 安全过滤：排除自身，确保角色与目标部位存活存在
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(AimPart) then
            -- 👥 阵营过滤优化
            if TeamCheck and player.Team == LocalPlayer.Team then continue end
            
            -- 🟢 检查健康值：不锁定已经死掉的玩家，防止鞭尸暴露
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
        local oldEsp = player.Character and player.Character:FindFirstChild("NoisyESP")
        if oldEsp then oldEsp:Destroy() end
        return 
    end
    
    if player.Character then
        local highlight = player.Character:FindFirstChild("NoisyESP")
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Name = "NoisyESP"
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
        local highlight = player.Character:FindFirstChild("NoisyESP")
        if highlight then highlight:Destroy() end
    end
end

-- [[ 6. 核心功能：篡改元表实现暴力静默自瞄 (Rage Mode) ]]
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    -- 如果开启了自瞄，且模式为 Rage 暴力，且是游戏引擎底层调用的射线检测
    if AimbotEnabled and AimbotMode == "Rage" and not checkcaller() then
        if method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "Raycast" then
            local target = getBestTarget(FOVRadius)
            if target and target.Character and target.Character:FindFirstChild(AimPart) then
                -- 🚀 强行篡改弹道方向，让子弹100%拐弯打中目标部位
                return target.Character[AimPart], target.Character[AimPart].Position, Vector3.new(0, 1, 0), target.Character[AimPart].Material
            end
        end
    end
    return oldNamecall(self, ...)
end)

-- [[ 7. 本地视觉全解锁（异步线程安全模式） ]]
local function doUnlockAll()
    task.spawn(function() -- 建立独立异步线程，防止游戏主UI挂起假死
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
    -- 更新 FOV 绘制
    if FOVEnabled then
        FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
        FOVCircle.Radius = FOVRadius
        FOVCircle.Color = FOVColor
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end

    -- 合法自瞄模式（Legit Mode）：通过移动玩家的 Camera 镜头进行平滑锁定
    if AimbotEnabled and AimbotMode == "Legit" then
        -- 针对手机端全面优化：只要开启且检测到范围内有人，就会自动追踪锁敌
        local target = getBestTarget(FOVRadius)
        if target and target.Character and target.Character:FindFirstChild(AimPart) then
            local targetPos = target.Character[AimPart].Position
            local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, AimSmoothness)
        end
    end

    -- 刷新房间内所有人的 ESP 状态
    for _, player in pairs(Players:GetPlayers()) do
        if ESPEnabled then applyESP(player) else removeESP(player) end
    end
end)

-- 动态监听新复活或新加房的玩家
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if ESPEnabled then applyESP(player) end
    end)
end)

-- [[ 9. 构筑多功能 Elite 控制面板 界面 ]]
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

Rayfield:Notify({Title = "矩阵加载成功", Content = "Noisy's Rivals 2026 Elite Edition 运行顺畅！", Duration = 5})
