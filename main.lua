--[[ RIVALS TRAINER — UE-style UI ]]
local Players   = game:GetService("Players")
local RunService= game:GetService("RunService")
local UIS       = game:GetService("UserInputService")
local Camera    = workspace.CurrentCamera
local LP        = Players.LocalPlayer

-- ============ CONFIG ============
local Cfg = {
    Aimbot       = true,
    Key          = Enum.UserInputType.MouseButton2,
    FOV          = 160,
    Smooth       = 0.22,
    Prediction   = 0.14,   -- 0 = off, 1 = full
    TeamCheck    = true,
    VisibleOnly  = false,
    ESP          = true,
    BoxESP       = true,
    SnapLines    = false,
    MenuOpen     = false,
    MenuKey      = Enum.KeyCode.RightShift,
}
local AimbotOn = false   -- show while key held
local Target   = nil

-- ============ TEAM HELPERS ============
local function sameTeam(p)
    if not Cfg.TeamCheck then return false end
    local a = LP.Team
    local b = p.Team
    return a and b and a == b
end

-- ============ ESP ============
local espFolder = Instance.new("Folder", game.CoreGui)
local dbg = Instance.new("Folder", game.CoreGui)
dbg.Parent = nil

local function clearESP()
    for _, v in ipairs(espFolder:GetChildren()) do v:Destroy() end
end

local function addESP(plr)
    if plr == LP then return end
    if sameTeam(plr) then return end

    local hl = Instance.new("Highlight")
    hl.Name = plr.Name
    hl.FillColor = Color3.fromRGB(255,40,40)
    hl.OutlineColor = Color3.fromRGB(255,255,255)
    hl.FillTransparency = 0.55
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = espFolder

    local bb = Instance.new("BillboardGui")
    bb.Name = plr.Name.."_name"
    bb.Size = UDim2.new(0,140,0,24)
    bb.StudsOffset = Vector3.new(0,2.4,0)
    bb.AlwaysOnTop = true
    bb.Parent = espFolder
    local txt = Instance.new("TextLabel", bb)
    txt.Size = UDim2.new(1,0,1,0); txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.new(1,1,1); txt.TextScaled = true
    txt.Font = Enum.Font.GothamBold
    txt.TextStrokeTransparency = 0
    txt.Text = plr.Name

    local function update()
        if not Cfg.ESP then hl.Enabled = false; bb.Enabled = false; return end
        hl.Enabled = true; bb.Enabled = true
        hl.Adornee = plr.Character
        if plr.Character and plr.Character:FindFirstChild("Head") then
            bb.Adornee = plr.Character.Head
        end
    end
    RunService.RenderStepped:Connect(update)
end

for _, p in ipairs(Players:GetPlayers()) do addESP(p) end
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() task.wait(0.3); clearESP(); for _, x in ipairs(Players:GetPlayers()) do addESP(x) end end)
    addESP(p)
end)

-- ============ FOV CIRCLE ============
local fovGui = Instance.new("ScreenGui", game.CoreGui)
fovGui.Name = "RivalsFOV"; fovGui.IgnoreGuiInset = true
local fovCircle = Instance.new("Frame", fovGui)
fovCircle.BackgroundTransparency = 1
fovCircle.Size = UDim2.fromOffset(Cfg.FOV*2, Cfg.FOV*2)
fovCircle.AnchorPoint = Vector2.new(0.5,0.5)
fovCircle.Position = UDim2.new(0.5,0,0.5,0)
local fovCorner = Instance.new("UICorner", fovCircle)
fovCorner.CornerRadius = UDim.new(1,0)
local fovStroke = Instance.new("UIStroke", fovCircle)
fovStroke.Color = Color3.fromRGB(0,200,255); fovStroke.Thickness = 1.5; fovStroke.Transparency = 0.25

RunService.RenderStepped:Connect(function()
    local mouse = UIS:GetMouseLocation()
    fovCircle.Position = UDim2.fromOffset(mouse.X, mouse.Y)
    local size = Cfg.FOV*2
    fovCircle.Size = UDim2.fromOffset(size,size)
end)

-- ============ AIMBOT ============
local function visible(hrp)
    if not Cfg.VisibleOnly then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LP.Character}
    local ray = workspace:Raycast(Camera.CFrame.Position, hrp.Position - Camera.CFrame.Position, params)
    return ray == nil or ray.Instance:IsDescendantOf(hrp.Parent)
end

local function getTarget()
    local best, bestD = nil, math.huge
    local mouse = UIS:GetMouseLocation()
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP or sameTeam(p) then continue end
        local char = p.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        if hrp and hum and hum.Health > 0 and visible(hrp) then
            local s = Camera:WorldToViewportPoint(hrp.Position)
            if s.Z > 0 then
                local d = (Vector2.new(s.X, s.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                if d <= Cfg.FOV and d < bestD then best, bestD = hrp, d end
            end
        end
    end
    return best
end

RunService.RenderStepped:Connect(function()
    if not Cfg.Aimbot or not AimbotOn then return end
    Target = getTarget()
    if Target then
        local pos = Target.Position + (Target.AssemblyLinearVelocity * Cfg.Prediction * 0.1)
        local goal = CFrame.new(Camera.CFrame.Position, pos)
        Camera.CFrame = Camera.CFrame:Lerp(goal, Cfg.Smooth)
    end
end)

UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.UserInputType == Cfg.Key then AimbotOn = true end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Cfg.Key then AimbotOn = false; Target = nil end
end)

-- ============ UE-STYLE MENU ============
local function create(class, props, parent)
    local o = Instance.new(class)
    for k,v in pairs(props) do o[k] = v end
    o.Parent = parent
    return o
end

local menu = create("ScreenGui", {Name="RivalsTrainer", IgnoreGuiInset=true}, game.CoreGui)
local main = create("Frame", {
    Size = UDim2.fromOffset(360, 470),
    Position = UDim2.new(0, 40, 0.5, -235),
    BackgroundColor3 = Color3.fromRGB(20,22,28),
    BorderSizePixel = 0,
    Visible = false,
}, menu)
create("UICorner", {CornerRadius=UDim.new(0,8)}, main)
create("UIStroke", {Color=Color3.fromRGB(0,200,255), Thickness=1.4, Transparency=0.3}, main)

-- Title bar
local bar = create("Frame", {Size=UDim2.new(1,0,0,40), BackgroundColor3=Color3.fromRGB(28,32,42), BorderSizePixel=0}, main)
create("UICorner", {CornerRadius=UDim.new(0,8)}, bar)
create("TextLabel", {
    Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
    Text="RIVALS  //  TRAINER", Font=Enum.Font.GothamBold,
    TextSize=16, TextColor3=Color3.fromRGB(0,200,255), TextXAlignment=Enum.TextXAlignment.Left,
}, bar).Position = UDim2.new(0,12,0,0)

-- Dragging
do
    local dragging, dragStart, startPos
    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = i.Position; startPos = main.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

-- Section builder
local function section(name, y)
    create("TextLabel", {
        Size = UDim2.new(1,0,0,22), Position = UDim2.new(0,12,0,y),
        BackgroundTransparency = 1, Text = name, Font=Enum.Font.GothamBold,
        TextSize = 13, TextColor3 = Color3.fromRGB(255,255,255),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, main)
end

local function toggle(label, y, get, set)
    local row = create("Frame", {Size=UDim2.new(1,-24,0,30), Position=UDim2.new(0,12,0,y), BackgroundTransparency=1}, main)
    create("TextLabel", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text=label, Font=Enum.Font.Gotham, TextSize=14, TextColor3=Color3.fromRGB(210,210,210), TextXAlignment=Enum.TextXAlignment.Left}, row)
    local btn = create("TextButton", {Size=UDim2.fromOffset(52,24), Position=UDim2.new(1,-52,0,3), BackgroundColor3=get() and Color3.fromRGB(0,140,255) or Color3.fromRGB(45,48,58), Text="", BorderSizePixel=0}, row)
    create("UICorner", {CornerRadius=UDim.new(1,0)}, btn)
    local dot = create("Frame", {Size=UDim2.fromOffset(18,18), Position=get() and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9), BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0}, btn)
    create("UICorner", {CornerRadius=UDim.new(1,0)}, dot)
    btn.MouseButton1Click:Connect(function()
        set(not get())
        btn.BackgroundColor3 = get() and Color3.fromRGB(0,140,255) or Color3.fromRGB(45,48,58)
        dot.Position = get() and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)
    end)
end

local function slider(label, y, min, max, get, set)
    local row = create("Frame", {Size=UDim2.new(1,-24,0,42), Position=UDim2.new(0,12,0,y), BackgroundTransparency=1}, main)
    local txt = create("TextLabel", {Size=UDim2.new(1,0,0,16), BackgroundTransparency=1, Text=label.."  ["..tostring(get()).."]", Font=Enum.Font.Gotham, TextSize=13, TextColor3=Color3.fromRGB(200,200,200), TextXAlignment=Enum.TextXAlignment.Left}, row)
    local track = create("Frame", {Size=UDim2.new(1,0,0,6), Position=UDim2.new(0,0,0,24), BackgroundColor3=Color3.fromRGB(45,48,58), BorderSizePixel=0}, row)
    create("UICorner", {CornerRadius=UDim.new(1,0)}, track)
    local fill = create("Frame", {Size=UDim2.new((get()-min)/(max-min),0,1,0), BackgroundColor3=Color3.fromRGB(0,140,255), BorderSizePixel=0}, track)
    create("UICorner", {CornerRadius=UDim.new(1,0)}, fill)
    track.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        local conn
        conn = UIS.InputChanged:Connect(function(m)
            if m.UserInputType ~= Enum.UserInputType.MouseMovement then return end
            local rel = math.clamp((m.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max-min)*rel + 0.5)
            set(val); fill.Size = UDim2.new(rel,0,1,0)
            txt.Text = label.."  ["..tostring(val).."]"
        end)
        UIS.InputEnded:Connect(function(e)
            if e.UserInputType == Enum.UserInputType.MouseButton1 then conn:Disconnect() end
        end)
    end)
end

section("COMBAT", 46)
toggle("Aimbot", 68, function() return Cfg.Aimbot end, function(v) Cfg.Aimbot = v end)
toggle("Team Check", 100, function() return Cfg.TeamCheck end, function(v) Cfg.TeamCheck = v; clearESP(); for _,p in ipairs(Players:GetPlayers()) do addESP(p) end end)
toggle("Visible Only", 132, function() return Cfg.VisibleOnly end, function(v) Cfg.VisibleOnly = v end)
slider("FOV", 164, 40, 400, function() return Cfg.FOV end, function(v) Cfg.FOV = v end)
slider("Smoothness %", 210, 0, 100, function() return math.floor(Cfg.Smooth*100) end, function(v) Cfg.Smooth = v/100 end)
slider("Prediction %", 256, 0, 100, function() return math.floor(Cfg.Prediction*100) end, function(v) Cfg.Prediction = v/100 end)

section("VISUALS", 302)
toggle("ESP", 324, function() return Cfg.ESP end, function(v) Cfg.ESP = v end)

create("TextLabel", {Size=UDim2.new(1,-24,0,20), Position=UDim2.new(0,12,0,358), BackgroundTransparency=1, Text="Keybind: RMB   |   Menu: RightShift", Font=Enum.Font.Gotham, TextSize=12, TextColor3=Color3.fromRGB(120,120,120), TextXAlignment=Enum.TextXAlignment.Left}, main)

-- Open/close
UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Cfg.MenuKey then
        Cfg.MenuOpen = not Cfg.MenuOpen
        main.Visible = Cfg.MenuOpen
    end
end)
-- 清理旧的
if game.CoreGui:FindFirstChild("SimpleMenu") then game.CoreGui.SimpleMenu:Destroy() end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 创建最基础的屏幕 UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleMenu"
ScreenGui.Parent = game.CoreGui -- 挂载到 CoreGui 提高兼容性

-- 主底板
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 250)
MainFrame.Position = UDim2.new(0.1, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- 标题
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "功能菜单 (可拖动)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Title.Parent = MainFrame

-- 速度修改按钮
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(0, 180, 0, 40)
SpeedBtn.Position = UDim2.new(0, 10, 0, 60)
SpeedBtn.Text = "急速奔跑: 关"
SpeedBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBtn.Parent = MainFrame

local speedOn = false
SpeedBtn.MouseButton1Click:Connect(function()
    speedOn = not speedOn
    SpeedBtn.Text = speedOn and "急速奔跑: 开" or "急速奔跑: 关"
    SpeedBtn.BackgroundColor3 = speedOn and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(80, 80, 80)
    
    task.spawn(function()
        while speedOn and task.wait() do
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.WalkSpeed = speedOn and 60 or 16
                end
            end)
        end
    end)
end)

-- 无限跳跃按钮
local JumpBtn = Instance.new("TextButton")
JumpBtn.Size = UDim2.new(0, 180, 0, 40)
JumpBtn.Position = UDim2.new(0, 10, 0, 120)
JumpBtn.Text = "无限跳跃: 关"
JumpBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
JumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpBtn.Parent = MainFrame

local jumpOn = false
JumpBtn.MouseButton1Click:Connect(function()
    jumpOn = not jumpOn
    JumpBtn.Text = jumpOn and "无限跳跃: 开" or "无限跳跃: 关"
    JumpBtn.BackgroundColor3 = jumpOn and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(80, 80, 80)
end)

game:GetService("UserInputService").JumpRequest:Connect(function()
    if jumpOn and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)
