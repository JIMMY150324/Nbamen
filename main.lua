local P, LP, Cam, RS, UIS, TS = game:GetService("Players"), game:GetService("Players").LocalPlayer, workspace.CurrentCamera, game:GetService("RunService"), game:GetService("UserInputService"), game:GetService("TweenService")
local PG = LP:WaitForChild("PlayerGui")
if PG:FindFirstChild("UEMenu") then PG.UEMenu:Destroy() end

local Cfg = {Ragebot = false, AutoFire = false, Teleport = false, DoubleTap = false, AntiAim = false, Rapid = false, Esp = false, Speed = 16, InfJump = false, Fly = false, Fov = 200, ShowFov = false}
local Str = 'loadstring(game:HttpGet("https://githubusercontent.com"))()'

local Gui = Instance.new("ScreenGui", PG) Gui.Name = "UEMenu" Gui.ResetOnSpawn = false
local Frame = Instance.new("Frame", Gui) Frame.Size = UDim2.new(0, 380, 0, 260) Frame.Position = UDim2.new(0.2, 0, 0.25, 0) Frame.BackgroundColor3 = Color3.fromRGB(13, 0, 0) Frame.Active = true Frame.Draggable = true Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
local Bar = Instance.new("Frame", Frame) Bar.Size = UDim2.new(1, 0, 0, 3) Bar.BackgroundColor3 = Color3.fromRGB(255, 0, 51) Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 8)
local Title = Instance.new("TextLabel", Frame) Title.Size = UDim2.new(1, -20, 0, 35) Title.Position = UDim2.new(0, 10, 0, 3) Title.Text = "☠️ UNNAMED ENHANCEMENTS // RAGE CONFIG ☠️" Title.TextColor3 = Color3.fromRGB(255, 255, 255) Title.BackgroundTransparency = 1 Title.Font = Enum.Font.Code Title.TextSize = 13 Title.TextXAlignment = Enum.TextXAlignment.Left

local Nav = Instance.new("Frame", Frame) Nav.Size = UDim2.new(0, 95, 1, -45) Nav.Position = UDim2.new(0, 10, 0, 38) Nav.BackgroundColor3 = Color3.fromRGB(25, 5, 5) Instance.new("UICorner", Nav).CornerRadius = UDim.new(0, 6)
local NavL = Instance.new("UIListLayout", Nav) NavL.Padding = UDim.new(0, 4) NavL.HorizontalAlignment = Enum.HorizontalAlignment.Center
local Container = Instance.new("Frame", Frame) Container.Size = UDim2.new(1, -125, 1, -45) Container.Position = UDim2.new(0, 115, 0, 38) Container.BackgroundTransparency = 1

local Pages = {}
local function makePage(name)
    local scr = Instance.new("ScrollingFrame", Container) scr.Size = UDim2.new(1, 0, 1, 0) scr.BackgroundTransparency = 1 scr.BorderSizePixel = 0 scr.ScrollBarThickness = 2 scr.CanvasSize = UDim2.new(0, 0, 0, 350) scr.Visible = false
    Instance.new("UIListLayout", scr).Padding = UDim.new(0, 6)
    Pages[name] = scr
    local btn = Instance.new("TextButton", Nav) btn.Size = UDim2.new(1, -6, 0, 26) btn.BackgroundColor3 = Color3.fromRGB(40, 10, 10) btn.TextColor3 = Color3.fromRGB(200, 150, 150) btn.Text = name:upper() btn.Font = Enum.Font.Code btn.TextSize = 9 Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(function() for _, p in pairs(Pages) do p.Visible = false end scr.Visible = true end)
end
makePage("Ragebot") makePage("Visuals") makePage("Hacks") Pages["Ragebot"].Visible = true

local function addToggle(page, txt, cb)
    local f = Instance.new("Frame", Pages[page]) f.Size = UDim2.new(1, -6, 0, 38) f.BackgroundColor3 = Color3.fromRGB(35, 12, 12) Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
    local l = Instance.new("TextLabel", f) l.Size = UDim2.new(0.6, 0, 1, 0) l.Position = UDim2.new(0, 10, 0, 0) l.Text = txt l.TextColor3 = Color3.fromRGB(230, 180, 180) l.Font = Enum.Font.Code l.TextSize = 11 l.BackgroundTransparency = 1 l.TextXAlignment = Enum.TextXAlignment.Left
    local bg = Instance.new("TextButton", f) bg.Size = UDim2.new(0, 42, 0, 20) bg.Position = UDim2.new(1, -52, 0, 9) bg.BackgroundColor3 = Color3.fromRGB(60, 20, 20) bg.Text = "" Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    local s = Instance.new("Frame", bg) s.Size = UDim2.new(0, 16, 0, 16) s.Position = UDim2.new(0, 2, 0, 2) s.BackgroundColor3 = Color3.fromRGB(255, 255, 255) Instance.new("UICorner", s).CornerRadius = UDim.new(1, 0)
    local state = false
    bg.MouseButton1Click:Connect(function()
        state = not state
        TS:Create(s, TweenInfo.new(0.15), {Position = state and UDim2.new(0, 24, 0, 2) or UDim2.new(0, 2, 0, 2)}):Play()
        TS:Create(bg, TweenInfo.new(0.15), {BackgroundColor3 = state and Color3.fromRGB(255, 0, 51) or Color3.fromRGB(60, 20, 20)}):Play()
        cb(state)
    end)
end

local function getEnemy()
    local target, near = nil, math.huge
    local pList = P:GetPlayers()
    for i = 1, #pList do
        local p = pList[i]
        if p ~= LP and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 and (p.Team ~= LP.Team or tostring(p.Team) == "Neutral") then
            local pos, vis = Cam:WorldToViewportPoint(p.Character.Head.Position)
            local m = UIS:GetMouseLocation()
            local d = (Vector2.new(pos.X, pos.Y) - m).Magnitude
            if d < near then target = p near = d end
        end
    end
    return target
end

local function shoot()
    local vu = game:GetService("VirtualUser")
    vu:CaptureController()
    vu:ClickButton1(Vector2.new(0,0))
end

RS.RenderStepped:Connect(function()
    if not Cfg.Ragebot then return end
    local t = getEnemy()
    if t and t.Character and t.Character:FindFirstChild("Head") and t.Character:FindFirstChild("HumanoidRootPart") then
        local head = t.Character.Head
        
        -- ACTION 1: 暴力强锁视角
        Cam.CFrame = CFrame.new(Cam.CFrame.Position, head.Position)
        
        -- ACTION 2: 全图瞬移追杀 (Teleport Kill)
        if Cfg.Teleport and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            LP.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3) -- 瞬间移动到敌人背后3格
        end
        
        -- ACTION 3: 极速自开火模拟
        if Cfg.AutoFire then
            task.spawn(shoot)
            if Cfg.DoubleTap then task.spawn(shoot) end -- ACTION 4: Double Tap (双发连弹)
        end
    end
end)

RS.Heartbeat:Connect(function()
    pcall(function()
        if LP.Character and LP.Character:FindFirstChild("Humanoid") and LP.Character:FindFirstChild("HumanoidRootPart") then
            local root, hum = LP.Character.HumanoidRootPart, LP.Character.Humanoid
            hum.WalkSpeed = Cfg.Speed
            
            -- ACTION 5: Anti-Aim 反自瞄机制 (身法头部疯狂抽搐，让其他外挂玩家无法锁你的头)
            if Cfg.AntiAim then
                root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(math.random(1, 360)), 0)
            end
            
            if Cfg.Fly then
                root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
                if UIS:IsKeyDown(Enum.KeyCode.Space) then root.Velocity = Vector3.new(root.Velocity.X, 40, root.Velocity.Z) end
            end
            
            -- ACTION 6: 武器超频覆写 (无后坐力 + 无散射 + 极限无限高射速)
            local w = LP.Character:FindFirstChildOfClass("Tool")
            if w and w:FindFirstChild("Configuration") then
                local c = w.Configuration
                if Cfg.NoRecoil and c:FindFirstChild("Recoil") then c.Recoil.Value = 0 end
                if Cfg.NoSpread and c:FindFirstChild("Spread") then c.Spread.Value = 0 end
                if Cfg.Rapid and c:FindFirstChild("FireRate") then c.FireRate.Value = 0.01 end -- 射速超频
            end
        end
    end)
end)

UIS.JumpRequest:Connect(function() if Cfg.InfJump and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping) end end)

local function doEsp(p)
    if p == LP then return end
    local function set(c) task.wait(0.3) if c:FindFirstChild("UE_Box") then c.UE_Box:Destroy() end local h = Instance.new("Highlight", c) h.Name = "UE_Box" h.FillColor = Color3.fromRGB(255, 0, 51) h.FillTransparency = 0.5 h.Enabled = Cfg.Esp end
    if p.Character then set(p.Character) end p.CharacterAdded:Connect(set)
end
for _, p in ipairs(P:GetPlayers()) do doEsp(p) end P.PlayerAdded:Connect(doEsp)

-- RAGEBOT PAGE (主攻暴力动作模块)
addToggle("Ragebot", "Ragebot Master (总开关)", function(s) Cfg.Ragebot = s end)
addToggle("Ragebot", "Auto Fire (自动瞬间开火)", function(s) Cfg.AutoFire = s end)
addToggle("Ragebot", "Double Tap (双发双倍伤害)", function(s) Cfg.DoubleTap = s end)
addToggle("Ragebot", "Teleport Kill (瞬移全图追杀)", function(s) Cfg.Teleport = s end)
addToggle("Ragebot", "Anti-Aim (反头部追踪假身)", function(s) Cfg.AntiAim = s end)

-- VISUALS PAGE
addToggle("Visuals", "Rage Red Chams ESP", function(s) Cfg.Esp = s for _, p in ipairs(P:GetPlayers()) do if p.Character and p.Character:FindFirstChild("UE_Box") then p.Character.UE_Box.Enabled = s end end end)

-- HACKS PAGE (移动与武器超频)
addToggle("Hacks", "Rapid Fire (无限超频射速)", function(s) Cfg.Rapid = s end)
addToggle("Hacks", "No Recoil & Spread (稳定弹道)", function(s) Cfg.NoRecoil = s Cfg.NoSpread = s end)
addToggle("Hacks", "Speed Hack (60)", function(s) Cfg.Speed = s and 60 or 16 end)
addToggle("Hacks", "Fly / Anti-Gravity", function(s) Cfg.Fly = s end)
addToggle("Hacks", "Infinite Jump", function(s) Cfg.InfJump = s end)

local Txt = Instance.new("TextBox", Nav) Txt.Size = UDim2.new(1, -6, 0, 30) Txt.BackgroundColor3 = Color3.fromRGB(25, 27, 34) Txt.TextColor3 = Color3.fromRGB(130, 140, 150) Txt.Text = Str Txt.ClearTextOnFocus = false Txt.TextEditable = false Txt.Visible = false Txt.Font = Enum.Font.Code Txt.TextSize = 9 Instance.new("UICorner", Txt).CornerRadius = UDim.new(0, 4)
local Cpy = Instance.new("TextButton", Nav) Cpy.Size = UDim2.new(1, -6, 0, 26) Cpy.BackgroundColor3 = Color3.fromRGB(0, 120, 200) Cpy.TextColor3 = Color3.fromRGB(255, 255, 255) Cpy.Text = "COPY LINK" Cpy.Font = Enum.Font.Code Cpy.TextSize = 10 Instance.new("UICorner", Cpy).CornerRadius = UDim.new(0, 4)
Cpy.MouseButton1Click:Connect(function()
    local fn = setclipboard or toclipboard or (Clipboard and Clipboard.set)
    local ok = pcall(function() if fn then fn(Str) end end)
if ok and fn then Cpy.Text = "COPIED!" Cpy.BackgroundColor3 = Color3.fromRGB(46, 204, 113) task.wait(1) Cpy.Text = "COPY LINK" Cpy.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
else Cpy.Text = "LONG PRESS" Cpy.BackgroundColor3 = Color3.fromRGB(230, 126, 34) Txt.Visible = true Txt:CaptureFocus() end
end)
local Cls = Instance.new("TextButton", Nav) Cls.Size = UDim2.new(1, -6, 0, 26) Cls.BackgroundColor3 = Color3.fromRGB(40, 20, 20) Cls.TextColor3 = Color3.fromRGB(255, 100, 100) Cls.Text = "CLOSE" Cls.Font = Enum.Font.Code Cls.TextSize = 10 Instance.new("UICorner", Cls).CornerRadius = UDim.new(0, 4) Cls.MouseButton1Click:Connect(function() Gui:Destroy() endText = "COPY LINK" Cpy.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
else Cpy.Text = "LONG PRESS" Cpy.BackgroundColor3 = Color3.fromRGB(230, 126, 34) Txt.Visible = true Txt:CaptureFocus() end
end)
local Cls = Instance.new("TextButton", Nav) Cls.Size = UDim2.new(1, -6, 0, 26) Cls.BackgroundColor3 = Color3.fromRGB(40, 20, 20) Cls.TextColor3 = Color3.fromRGB(255, 100, 100) Cls.Text = "CLOSE" Cls.Font = Enum.Font.Code Cls.TextSize = 10 Instance.new("UICorner", Cls).CornerRadius = UDim.new(0, 4) Cls.MouseButton1Click:Connect(function() Gui:Destroy() end
