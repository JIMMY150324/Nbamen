-- [[ 1. 安全卡密系统配置 ]]
local KeySettings = {
    CorrectKey = "NoisyRivals666", -- 🔑 Noisy 在这里设置卡密
    KeyLink = "https://linkvertise.com", -- 🌐 获取卡密的链接
    Note = "提示：加入 Noisy 频道即可免费获取今日解锁卡密！"
}

-- [[ 2. 初始化 UI 并触发卡密验证 ]]
local Rayfield = 
loadstring(game:HttpGet('https://sirius.menu'))()
local Window = Rayfield:CreateWindow({
   Name = "Noisy's RIVALS Premium Hub",
   LoadingTitle = "正在载入 RIVALS 终极矩阵...",
   LoadingSubtitle = "by Noisy",
   ConfigurationSaving = { Enabled = false },
   
   KeySystem = true, 
   Title = "Noisy 脚本安全验证",
   Subtitle = "请输入有效卡密解锁全部特权",
   Note = KeySettings.Note,
   FileName = "NoisyRivalsPremium",
   SaveKey = true, 
   Key = { KeySettings.CorrectKey } 
})

Rayfield:Notify({Title = "特权解锁", Content = "卡密验证通过！欢迎使用终极三合一脚本。", Duration = 5})

-- 卡密获取标签页
local KeyTab = Window:CreateTab("卡密获取", 4483345998)
KeyTab:CreateButton({
   Name = "点击复制卡密获取链接",
   Callback = function()
       setclipboard(KeySettings.KeyLink)
       Rayfield:Notify({Title = "成功", Content = "链接已复制到剪贴板！", Duration = 3})
   end,
})

-- [[ 3. 核心服务与全局变量 ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- 作弊功能开关状态
local AimbotEnabled = false
local AimSmoothness = 0.1
local AimPart = "Head"
local FOVEnabled = true
local FOVRadius = 100
local FOVColor = Color3.fromRGB(255, 0, 0)

local ESPEnabled = false
local ESPFillColor = Color3.fromRGB(255, 0, 0)     
local ESPOutlineColor = Color3.fromRGB(255, 255, 255) 
local ESPFillTrans = 0.5                          

-- 创建 FOV 范围圈
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 60
FOVCircle.Filled = false
FOVCircle.Transparency = 1

-- [[ 4. 功能模块 A：自瞄与锁敌算法 ]]
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = FOVRadius

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(AimPart) then
            -- 🟢 如果需要过滤队友，可取消注释下一行：
            -- if player.Team == LocalPlayer.Team then continue end

            local targetPart = player.Character[AimPart]
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)

            if onScreen then
                local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

                if distance < shortestDistance then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end
    return closestPlayer
end

-- [[ 5. 功能模块 B：高性能发光 ESP ]]
local function applyESP(player)
    if not ESPEnabled or player == LocalPlayer then return end
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

-- [[ 6. 功能模块 C：本地视觉全解锁（Unlock All） ]]
local function doUnlockAll()
    -- 核心逻辑：遍历游戏可能存放道具数据的客户端缓存、GUI 或本地文件夹
    -- 强行将所有皮肤、枪械、小刀的 “Owned (已拥有)” 状态修改为 true
    local pathsToSearch = {
        LocalPlayer:FindFirstChild("PlayerData"),
        LocalPlayer:FindFirstChild("Inventory"),
        ReplicatedStorage:FindFirstChild("PlayerData") and ReplicatedStorage.PlayerData:FindFirstChild(LocalPlayer.Name),
        LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Menu")
    }

    for _, root in pairs(pathsToSearch) do
        if root then
            -- 深度遍历所有子文件和数值属性
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
    
    Rayfield:Notify({Title = "解锁成功", Content = "本地皮肤与武器已全部解锁！(仅自己可见)", Duration = 4})
end

-- [[ 7. 后台实时渲染/逻辑监听主循环 ]]
RunService.RenderStepped:Connect(function()
    -- FOV 范围更新
    if FOVEnabled then
        FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
        FOVCircle.Radius = FOVRadius
        FOVCircle.Color = FOVColor
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end

    -- 自瞄触发（按住鼠标右键）
    if AimbotEnabled and game:GetService("UserInputService"):IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild(AimPart) then
            local targetPos = target.Character[AimPart].Position
            local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, AimSmoothness)
        end
    end

    -- ESP 实时刷新
    for _, player in pairs(Players:GetPlayers()) do
        if ESPEnabled then applyESP(player) else removeESP(player) end
    end
end)

-- 监听新复活和新加入的玩家应用 ESP
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if ESPEnabled then applyESP(player) end
    end)
end)

-- [[ 8. 绘制作弊功能控制台界面 ]]
local AimTab = Window:CreateTab("自瞄设置", 4483345998)
local EspTab = Window:CreateTab("全图透视", 4483345998)
local UnlockTab = Window:CreateTab("全物品解锁", 4483345998)

-- == 自瞄 UI 控制 ==
AimTab:CreateToggle({
   Name = "启用自瞄 (按住右键锁定)",
   CurrentValue = false,
   Callback = function(Value) AimbotEnabled = Value end,
})

AimTab:CreateDropdown({
   Name = "锁敌部位",
   Options = {"Head", "HumanoidRootPart"},
   CurrentOption = {"Head"},
   MultipleOptions = false,
   Callback = function(Option) AimPart = Option end,
})

AimTab:CreateSlider({
   Name = "自瞄平滑度 (越低越安全)",
   Min = 0.05,
   Max = 1,
   CurrentValue = 0.1,
   Increment = 0.05,
   Callback = function(Value) AimSmoothness = Value end,
})

AimTab:CreateToggle({
   Name = "显示 FOV 圆圈",
   CurrentValue = true,
   Callback = function(Value) FOVEnabled = Value end,
})

AimTab:CreateSlider({
   Name = "FOV 范围半径",
   Min = 30,
   Max = 500,
   CurrentValue = 100,
   Increment = 10,
   Callback = function(Value) FOVRadius = Value end,
})

-- == ESP UI 控制 ==
EspTab:CreateToggle({
   Name = "启用全图高亮 ESP",
   CurrentValue = false,
   Callback = function(Value) 
       ESPEnabled = Value 
       if not Value then
           for _, p in pairs(Players:GetPlayers()) do removeESP(p) end
       end
   end,
})

EspTab:CreateColorPicker({
    Name = "透视填充颜色",
    Color = Color3.fromRGB(255, 0, 0),
    Callback = function(Value) ESPFillColor = Value end
})

EspTab:CreateSlider({
   Name = "不透明度 (越低越淡)",
   Min = 0.1,
   Max = 1,
   CurrentValue = 0.5,
   Increment = 0.1,
   Callback = function(Value) ESPFillTrans = 1 - Value end, -- 反转透明度逻辑方便玩家理解
})

-- == 全解锁 UI 控制 ==
UnlockTab:CreateButton({
   Name = "⚡ 一键解锁所有武器/皮肤/特效 (本地视觉)",
   Callback = function()
       doUnlockAll()
   end,
})
-- 📱 将 RenderStepped 里的自瞄触发条件改成这样：
RunService.RenderStepped:Connect(function()
    -- ... 前面的 FOV 代码保持不变 ...

    -- 删掉原来的 MouseButton2 判断，改成只要开启自瞄（AimbotEnabled）就自动锁敌
    if AimbotEnabled then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild(AimPart) then
            local targetPos = target.Character[AimPart].Position
            local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, AimSmoothness)
        end
    end

    -- ... 后面的 ESP 代码保持不变 ...
end)
-- 📱 将卡密获取按钮（大概在第 30-36 行）改成这样：
KeyTab:CreateButton({
   Name = "点击复制卡密获取链接",
   Callback = function()
       -- 使用 pcall 兼容手机执行器，防止闪退
       pcall(function() setclipboard(KeySettings.KeyLink) end)
       Rayfield:Notify({Title = "提示", Content = "loadstring(game:HttpGet("https://raw.githubusercontent.com/JIMMY150324/Nbamen/refs/heads/main/main.lua"))()
: " .. KeySettings.KeyLink, Duration = 6})
   end,
})
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Ragebot 开关与最大范围（通常暴力自瞄的 FOV 会开得非常大，甚至 360 度全图锁）
local RagebotEnabled = true
local RagebotFOV = 800 

-- 获取合法敌人的函数
local function getRageTarget()
    local closestTarget = nil
    local shortestDistance = RagebotFOV

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            -- 🟢 检查敌人是否还活着
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health <= 0 then continue end
            
            -- 计算屏幕距离
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local mousePos = Vector2.new(LocalPlayer:GetMouse().X, LocalPlayer:GetMouse().Y)
                local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                
                if distance < shortestDistance then
                    closestTarget = player
                    shortestDistance = distance
                end
            end
        end
    end
    return closestTarget
end

-- 🛡️ 篡改元表 (Hook Namecall)：拦截游戏引擎的射线检测 (Raycast / FindPartOnRay)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if RagebotEnabled and not checkcaller() then
        -- 当游戏在寻找子弹击中的目标时（常用方法有 FindPartOnRay, Raycast 等）
        if method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "Raycast" then
            local target = getRageTarget()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                -- 🚀 暴力改写子弹轨迹：将原本的弹道直接瞬移到敌人的头部坐标上！
                -- 这样哪怕你在看天开枪，子弹也会拐弯打中敌人
                return target.Character.Head, target.Character.Head.Position, Vector3.new(0, 1, 0), target.Character.Head.Material
            end
        end
    end

    return oldNamecall(self, ...)
end)
-- 创建暴力专用标签页
local RageTab = Window:CreateTab("暴力功能", 4483345998)

RageTab:CreateToggle({
   Name = "开启全图 Ragebot (静默子弹追踪)",
   CurrentValue = false,
   Callback = function(Value)
       RagebotEnabled = Value
   end,
})

RageTab:CreateSlider({
   Name = "Rage 锁定范围 (FOV)",
   Min = 100,
   Max = 1500,
   CurrentValue = 800,
   Increment = 50,
   Callback = function(Value)
       RagebotFOV = Value
   end,
})
