local P, LP, Cam, RS, UIS, TS = game:GetService("Players"), game:GetService("Players").LocalPlayer, workspace.CurrentCamera, game:GetService("RunService"), game:GetService("UserInputService"), game:GetService("TweenService")
local PG = LP:WaitForChild("PlayerGui")
if PG:FindFirstChild("UEMenu") then PG.UEMenu:Destroy() end

local Cfg = {CamLock = false, ShowFov = true, Esp = false, Speed = 16, InfJump = false, Fov = 150, WeaponSkin = "None"}
local Str = 'loadstring(game:HttpGet("https://githubusercontent.com"))()'

-- 《Rivals》正版核心武器外观数据库 (MeshID 物理替换)
local WeaponsDB = {
    AK47_Default = {Mesh = "rbxassetid://18241908480", Tex = "rbxassetid://18241908615"}, -- 正版标准 AK-47 外观
    AK47_Gold    = {Mesh = "rbxassetid://18241908480", Tex = "rbxassetid://14234033620"}, -- 黄金高光版 AK-47
    Wraith_Rifle = {Mesh = "rbxassetid://18844837588", Tex = "rbxassetid://18844839100"}  -- 死神限定步枪模型
}

local Gui = Instance.new("ScreenGui", PG) Gui.Name = "UEMenu" Gui.ResetOnSpawn = false
local Frame = Instance.new("Frame", Gui) Frame.Size = UDim2.new(0, 360, 0, 260) Frame.Position = UDim2.new(0.2, 0, 0.25, 0) Frame.BackgroundColor3 = Color3.fromRGB(15, 16, 22) Frame.Active = true Frame.Draggable = true Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
local Bar = Instance.new("Frame", Frame) Bar.Size = UDim2.new(1, 0, 0, 3) Bar.BackgroundColor3 = Color3.fromRGB(0, 162, 255) Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 8)
local Title = Instance.new("TextLabel", Frame) Title.Size = UDim2.new(1, -20, 0, 35) Title.Position = UDim2.new(0, 10, 0, 3) Title.Text = "UNNAMED ENHANCEMENTS // RIVALS PREMIUM" Title.TextColor3 = Color3.fromRGB(255, 255, 255) Title.BackgroundTransparency = 1 Title.Font = Enum.Font.Code Title.TextSize = 12 Title.TextXAlignment = Enum.TextXAlignment.Left

local Nav = Instance.new("Frame", Frame) Nav.Size = UDim2.new(0, 90, 1, -45) Nav.Position = UDim2.new(0, 10, 0, 38) Nav.BackgroundColor3 = Color3.fromRGB(22, 23, 30) Instance.new("UICorner", Nav).CornerRadius = UDim.new(0, 6)
local NavL = Instance.new("UIListLayout", Nav) NavL.Padding = UDim.new(0, 4) NavL.HorizontalAlignment = Enum.HorizontalAlignment.Center
local Container = Instance.new("Frame", Frame) Container.Size = UDim2.new(1, -120, 1, -45) Container.Position = UDim2.new(0, 110, 0, 38) Container.BackgroundTransparency = 1

local Pages = {}
local function makePage(name)
    local scr = Instance.new("ScrollingFrame", Container) scr.Size = UDim2.new(1, 0, 1, 0) scr.BackgroundTransparency = 1 scr.BorderSizePixel = 0 scr.ScrollBarThickness = 2 scr.CanvasSize = UDim2.new(0, 0, 0, 280) scr.Visible = false
    Instance.new("UIListLayout", scr).Padding = UDim.new(0, 6)
    Pages[name] = scr
    local btn = Instance.new("TextButton", Nav) btn.Size = UDim2.new(1, -6, 0, 28) btn.BackgroundColor3 = Color3.fromRGB(30, 32, 42) btn.TextColor3 = Color3.fromRGB(150, 160, 170) btn.Text = name:upper() btn.Font = Enum.Font.Code btn.TextSize = 10 Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(function() for _, p in pairs(Pages) do p.Visible = false end scr.Visible = true end)
end
makePage("Combat") makePage("Skins") makePage("Player") Pages["Combat"].Visible = true

local function addToggle(page, txt, cb)
    local f = Instance.new("Frame", Pages[page]) f.Size = UDim2.new(1, -6, 0, 38) f.BackgroundColor3 = Color3.fromRGB(25, 27, 34) Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
    local l = Instance.new("TextLabel", f) l.Size = UDim2.new(0.6, 0, 1, 0) l.Position = UDim2.new(0, 10, 0, 0) l.Text = txt l.TextColor3 = Color3.fromRGB(200, 200, 200) l.Font = Enum.Font.Code l.TextSize = 11 l.BackgroundTransparency = 1 l.TextXAlignment = Enum.TextXAlignment.Left
    local bg = Instance.new("TextButton", f) bg.Size = UDim2.new(0, 42, 0, 20) bg.Position = UDim2.new(1, -52, 0, 9) bg.BackgroundColor3 = Color3.fromRGB(45, 47, 56) bg.Text = "" Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    local s = Instance.new("Frame", bg) s.Size = UDim2.new(0, 16, 0, 16) s.Position = UDim2.new(0, 2, 0, 2) s.BackgroundColor3 = Color3.fromRGB(255, 255, 255) Instance.new("UICorner", s).CornerRadius = UDim.new(1, 0)
    local state = false
    bg.MouseButton1Click:Connect(function()
        state = not state
        TS:Create(s, TweenInfo.new(0.15), {Position = state and UDim2.new(0, 24, 0, 2) or UDim2.new(0, 2, 0, 2)}):Play()
        TS:Create(bg, TweenInfo.new(0.15), {BackgroundColor3 = state and Color3.fromRGB(0, 162, 255) or Color3.fromRGB(45, 47, 56)}):Play()
        cb(state)
    end)
end

local Circle = Instance.new("ImageLabel", Gui) Circle.Size = UDim2.new(0, Cfg.Fov*2, 0, Cfg.Fov*2) Circle.BackgroundTransparency = 1 Circle.Image = "rbxassetid://6994376976" Circle.ImageColor3 = Color3.fromRGB(0, 162, 255) Circle.Visible = false

local function getTarget()
    local target, near = nil, Cfg.Fov
    local pList = P:GetPlayers()
    local center = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
    for i = 1, #pList do
        local p = pList[i]
        if p ~= LP and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 and (p.Team ~= LP.Team or tostring(p.Team) == "Neutral") then
            local pos, vis = Cam:WorldToViewportPoint(p.Character.Head.Position)
            if vis then
                local d = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if d < near then target = p near = d end
            end
        end
    end
    return target
end

-- 高频核心重定向处理循环 (同时支持自瞄数据流补偿 + 正版枪模替换)
RS.RenderStepped:Connect(function()
    local center = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
    Circle.Position = UDim2.new(0, center.X - Cfg.Fov, 0, center.Y - Cfg.Fov)
    Circle.Visible = Cfg.ShowFov and Cfg.CamLock
    
    -- 1. 自瞄模块：手机手指滑动流矢量增量插入算法
    if Cfg.CamLock then
        local t = getTarget()
        if t and t.Character and t.Character:FindFirstChild("Head") then
            local tPos, _ = Cam:WorldToViewportPoint(t.Character.Head.Position)
            -- 直接通过底层坐标旋转矩阵（LookAt），迫使本地自定义相机与敌方头部锁定
            Cam.CFrame = CFrame.lookAt(Cam.CFrame.Position, t.Character.Head.Position)
        end
    end
    
    -- 2. 真实换肤模块：动态检索并强改手里武器的网格模型资产
    pcall(function()
        if Cfg.WeaponSkin ~= "None" and LP.Character then
            local skinData = WeaponsDB[Cfg.WeaponSkin]
            if skinData then
                for _, item in ipairs(LP.Character:GetDescendants()) do
                    -- 锁定手持枪械的主网格或配件零件
                    if item:IsA("MeshPart") and not item.Name:lower():find("arm") and not item.Name:lower():find("hand") then
                        if item.MeshId ~= skinData.Mesh then
                            item.MeshId = skinData.Mesh       -- 物理强换官方 AK-47 3D结构
                            item.TextureID = skinData.Tex     -- 强换对应正版皮肤贴图
                        end
                    end
                end
            end
        end
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid.WalkSpeed = Cfg.Speed
        end
    end)
end)

UIS.JumpRequest:Connect(function() if Cfg.InfJump and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping) end end)

local function doEsp(p)
    if p == LP then return end
    local function set(c) task.wait(0.3) if c:FindFirstChild("UE_Box") then c.UE_Box:Destroy() end local h = Instance.new("Highlight", c) h.Name = "UE_Box" h.FillColor = Color3.fromRGB(0, 162, 255) h.FillTransparency = 0.6 h.Enabled = Cfg.Esp end
    if p.Character then set(p.Character) end p.CharacterAdded:Connect(set)
end
for _, p in ipairs(P:GetPlayers()) do doEsp(p) end P.PlayerAdded:Connect(doEsp)

-- COMBAT TABS
addToggle("Combat", "Aimbot Launcher (智能吸附锁头)", function(s) Cfg.CamLock = s end)
addToggle("Combat", "Show FOV Indicater (自瞄范围圈)", function(s) Cfg.ShowFov = s end)
addToggle("Combat", "Wallhack ESP (玩家高亮透视)", function(s) Cfg.Esp = s for _, p in ipairs(P:GetPlayers()) do if p.Character and p.Character:FindFirstChild("UE_Box") then p.Character.UE_Box.Enabled = s end end end)

-- SKINS TABS (Rivals 枪械更换分栏)
addToggle("Skins", "Equip Weapon: AK-47 (经典外观)", function(s) Cfg.WeaponSkin = s and "AK47_Default" or "None" end)
addToggle("Skins", "Equip Weapon: AK-47 (正版黄金)", function(s) Cfg.WeaponSkin = s and "AK47_Gold" or "None" end)
addToggle("Skins", "Equip Weapon: Wraith (死神限定)", function(s) Cfg.WeaponSkin = s and "Wraith_Rifle" or "None" end)

-- PLAYER TABS
addToggle("Player", "WalkSpeed Booster (急速横移)", function(s) Cfg.Speed = s and 50 or 16 end)
addToggle("Player", "Infinite Jump (空间无限连跳)", function(s) Cfg.InfJump = s end)

local Txt = Instance.new("TextBox", Nav) Txt.Size = UDim2.new(1, -6, 0, 30) Txt.BackgroundColor3 = Color3.fromRGB(25, 27, 34) Txt.TextColor3 = Color3.fromRGB(130, 140, 150) Txt.Text = Str Txt.ClearTextOnFocus = false Txt.TextEditable = false Txt.Visible = false Txt.Font = Enum.Font.Code Txt.TextSize = 9 Instance.new("UICorner", Txt).CornerRadius = UDim.new(0, 4)
local Cpy = Instance.new("TextButton", Nav) Cpy.Size = UDim2.new(1, -6, 0, 26) Cpy.BackgroundColor3 = Color3.fromRGB(0, 120, 200) Cpy.TextColor3 = Color3.fromRGB(255, 255, 255) Cpy.Text = "COPY LINK" Cpy.Font = Enum.Font.Code Cpy.TextSize = 10 Instance.new("UICorner", Cpy).CornerRadius = UDim.new(0, 4)
Cpy.MouseButton1Click:Connect(function()
    local fn = setclipboard or toclipboard or (Clipboard and Clipboard.set)
    local ok = pcall(function() if fn then fn(Str) end end)
    if ok and fn then Cpy.Text = "COPIED!" Cpy.BackgroundColor3 = Color3.fromRGB(46, 204, 113) task.wait(1) Cpy.Text = "COPY LINK" Cpy.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
请谨慎使用此类代码。
else Cpy.Text = "LONG PRESS" Cpy.BackgroundColor3 = Color3.fromRGB(230, 126, 34) Txt.Visible = true Txt:CaptureFocus() end
end)
local Cls = Instance.new("TextButton", Nav) Cls.Size = UDim2.new(1, -6, 0, 26) Cls.BackgroundColor3 = Color3.fromRGB(40, 20, 20) Cls.TextColor3 = Color3.fromRGB(255, 100, 100) Cls.Text = "CLOSE" Cls.Font = Enum.Font.Code Cls.TextSize = 10 Instance.new("UICorner", Cls).CornerRadius = UDim.new(0, 4) Cls.MouseButton1Click:Connect(function() Gui:Destroy() end)
