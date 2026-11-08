local P, LP, Cam, RS, UIS, TS = game:GetService("Players"), game:GetService("Players").LocalPlayer, workspace.CurrentCamera, game:GetService("RunService"), game:GetService("UserInputService"), game:GetService("TweenService")
local PG = LP:WaitForChild("PlayerGui")
if PG:FindFirstChild("UEMenu") then PG.UEMenu:Destroy() end

local Cfg = {Esp = false, Speed = 16, InfJump = false, Tracer = false}
local Str = 'loadstring(game:HttpGet("https://githubusercontent.com"))()'

local Gui = Instance.new("ScreenGui", PG) Gui.Name = "UEMenu" Gui.ResetOnSpawn = false
local Frame = Instance.new("Frame", Gui) Frame.Size = UDim2.new(0, 360, 0, 260) Frame.Position = UDim2.new(0.2, 0, 0.25, 0) Frame.BackgroundColor3 = Color3.fromRGB(15, 16, 22) Frame.Active = true Frame.Draggable = true Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
local Bar = Instance.new("Frame", Frame) Bar.Size = UDim2.new(1, 0, 0, 3) Bar.BackgroundColor3 = Color3.fromRGB(0, 162, 255) Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 8)
local Title = Instance.new("TextLabel", Frame) Title.Size = UDim2.new(1, -20, 0, 35) Title.Position = UDim2.new(0, 10, 0, 3) Title.Text = "UNNAMED ENHANCEMENTS // SAFE PANEL" Title.TextColor3 = Color3.fromRGB(255, 255, 255) Title.BackgroundTransparency = 1 Title.Font = Enum.Font.Code Title.TextSize = 13 Title.TextXAlignment = Enum.TextXAlignment.Left

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
makePage("Visuals") makePage("Player") Pages["Visuals"].Visible = true

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

-- 高频位置与运动参数维护系统
RS.RenderStepped:Connect(function()
    pcall(function()
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid.WalkSpeed = Cfg.Speed
        end
    end)
end)

UIS.JumpRequest:Connect(function() 
    if Cfg.InfJump and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then 
        LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping) 
    end 
end)

-- 全局高光透视渲染函数
local function doEsp(p)
    if p == LP then return end
    local function set(c) 
        task.wait(0.3) 
        if c:FindFirstChild("UE_Box") then c.UE_Box:Destroy() end 
        local h = Instance.new("Highlight", c) 
        h.Name = "UE_Box" 
        h.FillColor = Color3.fromRGB(0, 162, 255) 
        h.FillTransparency = 0.5 
        h.OutlineColor = Color3.fromRGB(255, 255, 255)
        h.Enabled = Cfg.Esp 
        h.Parent = c 
    end
    if p.Character then set(p.Character) end 
    p.CharacterAdded:Connect(set)
end
for _, p in ipairs(P:GetPlayers()) do doEsp(p) end 
P.PlayerAdded:Connect(doEsp)

-- 绑定安全分栏组件
addToggle("Visuals", "Player ESP (全局透视)", function(s) 
    Cfg.Esp = s 
    for _, p in ipairs(P:GetPlayers()) do 
        if p.Character and p.Character:FindFirstChild("UE_Box") then 
            p.Character.UE_Box.Enabled = s 
        end 
    end 
end)

addToggle("Player", "WalkSpeed Boost (移动速度)", function(s) Cfg.Speed = s and 45 or 16 end)
addToggle("Player", "Infinite Jump (无线连跳)", function(s) Cfg.InfJump = s end)

local Txt = Instance.new("TextBox", Nav) Txt.Size = UDim2.new(1, -6, 0, 30) Txt.BackgroundColor3 = Color3.fromRGB(25, 27, 34) Txt.TextColor3 = Color3.fromRGB(130, 140, 150) Txt.Text = Str Txt.ClearTextOnFocus = false Txt.TextEditable = false Txt.Visible = false Txt.Font = Enum.Font.Code Txt.TextSize = 9 Instance.new("UICorner", Txt).CornerRadius = UDim.new(0, 4)
local Cpy = Instance.new("TextButton", Nav) Cpy.Size = UDim2.new(1, -6, 0, 26) Cpy.BackgroundColor3 = Color3.fromRGB(0, 120, 200) Cpy.TextColor3 = Color3.fromRGB(255, 255, 255) Cpy.Text = "COPY LINK" Cpy.Font = Enum.Font.Code Cpy.TextSize = 10 Instance.new("UICorner", Cpy).CornerRadius = UDim.new(0, 4)
Cpy.MouseButton1Click:Connect(function()
    local fn = setclipboard or toclipboard or (Clipboard and Clipboard.set)
    local ok = pcall(function() if fn then fn(Str) end end)
    if ok and fn then Cpy.Text = "COPIED!" Cpy.BackgroundColor3 = Color3.fromRGB(46, 204, 113) task.wait(1) Cpy.Text = "COPY LINK" Cpy.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    else Cpy.Text = "LONG PRESS" Cpy.BackgroundColor3 = Color3.fromRGB(230, 126, 34) Txt.Visible = true Txt:CaptureFocus() end
end)
local Cls = Instance.new("TextButton", Nav) Cls.Size = UDim2.new(1, -6, 0, 26) Cls.BackgroundColor3 = Color3.fromRGB(40, 20, 20) Cls.TextColor3 = Color3.fromRGB(255, 100, 100) Cls.Text = "CLOSE" Cls.Font = Enum.Font.Code Cls.TextSize = 10 Instance.new("UICorner", Cls).CornerRadius = UDim.new(0, 4) Cls.MouseButton1Click:Connect(function() Gui:Destroy() end)
ls.TextSize = 10 Instance.new("UICorner", Cls).CornerRadius = UDim.new(0, 4) Cls.MouseButton1Click:Connect(function() Gui:Destroy() endText = "COPY LINK" Cpy.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
else Cpy.Text = "LONG PRESS" Cpy.BackgroundColor3 = Color3.fromRGB(230, 126, 34) Txt.Visible = true Txt:CaptureFocus() end
end)
local Cls = Instance.new("TextButton", Nav) Cls.Size = UDim2.new(1, -6, 0, 26) Cls.BackgroundColor3 = Color3.fromRGB(40, 20, 20) Cls.TextColor3 = Color3.fromRGB(255, 100, 100) Cls.Text = "CLOSE" Cls.Font = Enum.Font.Code Cls.TextSize = 10 Instance.new("UICorner", Cls).CornerRadius = UDim.new(0, 4) Cls.MouseButton1Click:Connect(function() Gui:Destroy() end
