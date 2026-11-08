local P, LP, Cam, RS, UIS, TS = game:GetService("Players"), game:GetService("Players").LocalPlayer, workspace.CurrentCamera, game:GetService("RunService"), game:GetService("UserInputService"), game:GetService("TweenService")
local PG = LP:WaitForChild("PlayerGui")
if PG:FindFirstChild("UEMenu") then PG.UEMenu:Destroy() end

local Cfg = {CamLock = false, SmartAim = false, Ragebot = false, ShowFov = true, Esp = false, Speed = 16, InfJump = false, Fov = 160}
local Str = 'loadstring(game:HttpGet("https://githubusercontent.com"))()'

local Gui = Instance.new("ScreenGui", PG) Gui.Name = "UEMenu" Gui.ResetOnSpawn = false
local Frame = Instance.new("Frame", Gui) Frame.Size = UDim2.new(0, 360, 0, 260) Frame.Position = UDim2.new(0.2, 0, 0.25, 0) Frame.BackgroundColor3 = Color3.fromRGB(15, 16, 22) Frame.Active = true Frame.Draggable = true Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
local Bar = Instance.new("Frame", Frame) Bar.Size = UDim2.new(1, 0, 0, 3) Bar.BackgroundColor3 = Color3.fromRGB(0, 162, 255) Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 8)
local Title = Instance.new("TextLabel", Frame) Title.Size = UDim2.new(1, -20, 0, 35) Title.Position = UDim2.new(0, 10, 0, 3) Title.Text = "UNNAMED ENHANCEMENTS // COMPATIBLE" Title.TextColor3 = Color3.fromRGB(255, 255, 255) Title.BackgroundTransparency = 1 Title.Font = Enum.Font.Code Title.TextSize = 13 Title.TextXAlignment = Enum.TextXAlignment.Left

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
makePage("Combat") makePage("Visuals") makePage("Player") Pages["Combat"].Visible = true

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

-- 修复版索敌算法：自动适应全图或 FOV 视距范围
local function getTarget(ignoreFov)
    local target, near = nil, ignoreFov and math.huge or Cfg.Fov
    local pList = P:GetPlayers()
    for i = 1, #pList do
        local p = pList[i]
        if p ~= LP and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 and (p.Team ~= LP.Team or tostring(p.Team) == "Neutral") then
            local pos, vis = Cam:WorldToViewportPoint(p.Character.Head.Position)
            if vis or ignoreFov then
                -- 获取相对于手机屏幕中心点的像素跨度距离
                local scrCenter = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
                local d = (Vector2.new(pos.X, pos.Y) - scrCenter).Magnitude
                if d < near then target = p near = d end
            end
        end
    end
    return target
end

-- 自动开火动作模拟（安全注入版）
local function autoShoot()
    local vu = game:GetService("VirtualUser")
    vu:CaptureController()
    vu:Button1Down(Vector2.new(0,0))
    task.wait(0.02)
    vu:Button1Up(Vector2.new(0,0))
end

RS.RenderStepped:Connect(function()
    -- 圈随手指/屏幕中心移动
    local scrCenter = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
    Circle.Position = UDim2.new(0, scrCenter.X - Cfg.Fov, 0, scrCenter.Y - Cfg.Fov)
    Circle.Visible = Cfg.ShowFov and (Cfg.CamLock or Cfg.SmartAim) and not Cfg.Ragebot
    
    -- 判断当前模式激活对应的自瞄 Action
    if Cfg.Ragebot then
        -- 模式 1：全图全自动收割（完全不受手机按键影响，上场直接自动索敌爆头加开火）
        local t = getTarget(true)
        if t and t.Character and t.Character:FindFirstChild("Head") then
            Cam.CFrame = CFrame.new(Cam.CFrame.Position, t.Character.Head.Position)
            task.spawn(autoShoot)
        end
    elseif Cfg.CamLock or Cfg.SmartAim then
        -- 模式 2：修复版手机准心自动吸附锁定
        local t = getTarget(false)
        if t and t.Character and t.Character:FindFirstChild("Head") then
            Cam.CFrame = CFrame.new(Cam.CFrame.Position, t.Character.Head.Position)
            if Cfg.Ragebot then task.spawn(autoShoot) end
        end
    end
    
    pcall(function()
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

-- 绑定组件
addToggle("Combat", "Ragebot (全图秒杀)", function(s) Cfg.Ragebot = s end)
addToggle("Combat", "Aimbot (常开自瞄吸附)", function(s) Cfg.CamLock = s end)
addToggle("Combat", "Smart Aim (微调范围自瞄)", function(s) Cfg.SmartAim = s end)
addToggle("Combat", "Show FOV Circle", function(s) Cfg.ShowFov = s end)

addToggle("Visuals", "Player ESP", function(s) Cfg.Esp = s for _, p in ipairs(P:GetPlayers()) do if p.Character and p.Character:FindFirstChild("UE_Box") then p.Character.UE_Box.Enabled = s end end end)
addToggle("Player", "WalkSpeed (50)", function(s) Cfg.Speed = s and 50 or 16 end)
addToggle("Player", "Infinite Jump", function(s) Cfg.InfJump = s end)

local Txt = Instance.new("TextBox", Nav) Txt.Size = UDim2.new(1, -6, 0, 30) Txt.BackgroundColor3 = Color3.fromRGB(25, 27, 34) Txt.TextColor3 = Color3.fromRGB(130, 140, 150) Txt.Text = Str Txt.ClearTextOnFocus = false Txt.TextEditable = false Txt.Visible = false Txt.Font = Enum.Font.Code Txt.TextSize = 9 Instance.new("UICorner", Txt).CornerRadius = UDim.new(0, 4)
local Cpy = Instance.new("TextButton", Nav) Cpy.Size = UDim2.new(1, -6, 0, 26) Cpy.BackgroundColor3 = Color3.fromRGB(0, 120, 200) Cpy.TextColor3 = Color3.fromRGB(255, 255, 255) Cpy.Text = "COPY LINK" Cpy.Font = Enum.Font.Code Cpy.TextSize = 10 Instance.new("UICorner", Cpy).CornerRadius = UDim.new(0, 4)
Cpy.MouseButton1Click:Connect(function()
    local fn = setclipboard or toclipboard or (Clipboard and Clipboard.set)
    local ok = pcall(function() if fn then fn(Str) end end)
    if ok and fn then Cpy.Text = "COPIED!" Cpy.BackgroundColor3 = Color3.fromRGB(46, 204, 113) task.wait(1) Cpy.Text = "COPY LINK" Cpy.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    else Cpy.Text = "LONG PRESS" Cpy.BackgroundColor3 = Color3.fromRGB(230, 126, 34) Txt.Visible = true Txt:CaptureFocus() end
end)
local Cls = Instance.new("TextButton", Nav) Cls.Size = UDim2.new(1, -6, 0, 26) Cls.BackgroundColor3 = Color3.fromRGB(40, 20, 20) Cls.TextColor3 = Color3.fromRGB(255, 100, 100) Cls.Text = "CLOSE" Cls.Font = Enum.Font.Code Cls.TextSize = 10 Instance.new("UICorner", Cls).CornerRadius = UDim.new(0, 4) Cls.MouseButton1Click:Connect(function() Gui:Destroy() end)
Y LINK" Cpy.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
else Cpy.Text = "LONG PRESS" Cpy.BackgroundColor3 = Color3.fromRGB(230, 126, 34) Txt.Visible = true Txt:CaptureFocus() end
end)
local Cls = Instance.new("TextButton", Nav) Cls.Size = UDim2.new(1, -6, 0, 26) Cls.BackgroundColor3 = Color3.fromRGB(40, 20, 20) Cls.TextColor3 = Color3.fromRGB(255, 100, 100) Cls.Text = "CLOSE" Cls.Font = Enum.Font.Code Cls.TextSize = 10 Instance.new("UICorner", Cls).CornerRadius = UDim.new(0, 4) Cls.MouseButton1Click:Connect(function() Gui:Destroy() endText = "COPY LINK" Cpy.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
else Cpy.Text = "LONG PRESS" Cpy.BackgroundColor3 = Color3.fromRGB(230, 126, 34) Txt.Visible = true Txt:CaptureFocus() end
end)
local Cls = Instance.new("TextButton", Nav) Cls.Size = UDim2.new(1, -6, 0, 26) Cls.BackgroundColor3 = Color3.fromRGB(40, 20, 20) Cls.TextColor3 = Color3.fromRGB(255, 100, 100) Cls.Text = "CLOSE" Cls.Font = Enum.Font.Code Cls.TextSize = 10 Instance.new("UICorner", Cls).CornerRadius = UDim.new(0, 4) Cls.MouseButton1Click:Connect(function() Gui:Destroy() end
