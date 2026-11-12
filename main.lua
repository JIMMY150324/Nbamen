-- [[ RIVALS MOBILE NETRUNNER v3.0 — Fixed + Expanded ]]
-- Mobile executor (Delta/ArceusX/Fluxus/Hydrogen). Alt account recommended.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local TS = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

------------------------------------------------------------
-- SAFE WRAPPER
------------------------------------------------------------
local function safe(fn, ...)
    local args = {...}
    local ok, err = pcall(fn, table.unpack(args))
    if not ok then warn("[NETRUNNER]", err) end
end

------------------------------------------------------------
-- CONFIG (single source of truth)
------------------------------------------------------------
local Cfg = {
    aim     = { enabled=false, smooth=0.30, fov=140, part="Head", team=true, showFov=true },
    silent  = { enabled=false, fov=220, part="Head", team=true },
    rage    = { enabled=false, fov=420, team=true, autoFire=true },
    trig    = { enabled=false, fov=80, cooldown=0 },
    esp     = { enabled=false, names=true, boxes=true, health=true, dist=true },
    fly     = { enabled=false, speed=60 },
    speed   = { enabled=false, value=32 },
    jump    = { enabled=false, value=90 },
    hunter  = { enabled=false },
    orbit   = { enabled=false, dist=12, speed=1.2 },
}

------------------------------------------------------------
-- HELPERS
------------------------------------------------------------
local function char() return LP.Character end
local function root() local c=char(); return c and c:FindFirstChild("HumanoidRootPart") end
local function hum()  local c=char(); return c and c:FindFirstChildOfClass("Humanoid") end
local function alive(p)
    if p==LP then return false end
    local c=p.Character; if not c then return false end
    local h=c:FindFirstChildOfClass("Humanoid")
    return h and h.Health>0 and h:GetState()~=Enum.HumanoidStateType.Dead
end
local function w2s(pos)
    local sp,on,z = Camera:WorldToViewportPoint(pos)
    return Vector2.new(sp.X,sp.Y), on, z
end
local function nearest(fov, part, team)
    local best,bd = nil, fov
    local mp = UIS:GetMouseLocation()
    for _,p in ipairs(Players:GetPlayers()) do
        if alive(p) and not (team and p.Team==LP.Team) then
            local pt = p.Character:FindFirstChild(part) or p.Character:FindFirstChild("HumanoidRootPart")
            if pt then
                local sp,on,z = w2s(pt.Position)
                if on and z>0 then
                    local d = (sp-mp).Magnitude
                    if d<bd then best,bd = p,d end
                end
            end
        end
    end
    return best
end

------------------------------------------------------------
-- GUI ROOT
------------------------------------------------------------
for _,g in ipairs(LP.PlayerGui:GetChildren()) do
    if g.Name=="RivalsNetrunner3" then g:Destroy() end
end

local gui = Instance.new("ScreenGui")
gui.Name = "RivalsNetrunner3"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = LP:WaitForChild("PlayerGui")

------------------------------------------------------------
-- CROSSHAIR + FOV RING
------------------------------------------------------------
local cross = Instance.new("Frame")
cross.Size = UDim2.new(0,16,0,16)
cross.Position = UDim2.new(0.5,-8,0.5,-8)
cross.BackgroundTransparency = 1
cross.Parent = gui
local cH = Instance.new("Frame"); cH.Size=UDim2.new(1,0,0,2); cH.Position=UDim2.new(0,0,0.5,-1)
cH.BackgroundColor3=Color3.fromRGB(0,255,150); cH.BorderSizePixel=0; cH.Parent=cross
local cV = Instance.new("Frame"); cV.Size=UDim2.new(0,2,1,0); cV.Position=UDim2.new(0.5,-1,0,0)
cV.BackgroundColor3=Color3.fromRGB(0,255,150); cV.BorderSizePixel=0; cV.Parent=cross

local ring = Instance.new("Frame")
ring.AnchorPoint = Vector2.new(0.5,0.5)
ring.Position = UDim2.new(0.5,0,0.5,0)
ring.BackgroundTransparency = 1
ring.BorderSizePixel = 0
ring.Visible = false
ring.Parent = gui
Instance.new("UICorner", ring).CornerRadius = UDim.new(1,0)
local ringStroke = Instance.new("UIStroke", ring)
ringStroke.Color = Color3.fromRGB(0,255,150); ringStroke.Thickness = 1.5

------------------------------------------------------------
-- FLOATING BUTTON
------------------------------------------------------------
local float = Instance.new("TextButton")
float.Size = UDim2.new(0,58,0,58)
float.Position = UDim2.new(1,-70,0,70)
float.BackgroundColor3 = Color3.fromRGB(18,18,24)
float.Text = "⚡"
float.TextSize = 30
float.TextColor3 = Color3.fromRGB(0,255,150)
float.Font = Enum.Font.GothamBold
float.AutoButtonColor = false
float.BorderSizePixel = 0
float.Parent = gui
Instance.new("UICorner", float).CornerRadius = UDim.new(1,0)
local fs = Instance.new("UIStroke", float); fs.Color=Color3.fromRGB(0,255,150); fs.Thickness=2

------------------------------------------------------------
-- DRAGGABLE UTIL
------------------------------------------------------------
local function makeDraggable(obj, handle)
    local dragging, start, startP = false,nil,nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true; start=i.Position; startP=obj.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement) then
            local d=i.Position-start
            obj.Position=UDim2.new(startP.X.Scale, startP.X.Offset+d.X, startP.Y.Scale, startP.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)
end

makeDraggable(float, float)

------------------------------------------------------------
-- MAIN PANEL
------------------------------------------------------------
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0,340,0,520)
panel.Position = UDim2.new(0.5,-170,0.5,-260)
panel.BackgroundColor3 = Color3.fromRGB(14,14,20)
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui
Instance.new("UICorner",panel).CornerRadius = UDim.new(0,14)
local pStroke = Instance.new("UIStroke",panel); pStroke.Color=Color3.fromRGB(0,255,150); pStroke.Thickness=1.5

local title = Instance.new("Frame")
title.Size = UDim2.new(1,0,0,46)
title.BackgroundColor3 = Color3.fromRGB(20,20,28)
title.BorderSizePixel = 0
title.Parent = panel
Instance.new("UICorner",title).CornerRadius = UDim.new(0,14)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1,-50,1,0)
titleLabel.Position = UDim2.new(0,14,0,0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚡ NETRUNNER v3.0"
titleLabel.TextColor3 = Color3.fromRGB(0,255,150)
titleLabel.TextSize = 17
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = title

local close = Instance.new("TextButton")
close.Size = UDim2.new(0,32,0,32)
close.Position = UDim2.new(1,-42,0,7)
close.BackgroundColor3 = Color3.fromRGB(40,40,50)
close.Text = "✕"
close.TextSize = 16
close.TextColor3 = Color3.fromRGB(255,120,120)
close.Font = Enum.Font.GothamBold
close.BorderSizePixel = 0
close.Parent = title
Instance.new("UICorner",close).CornerRadius = UDim.new(1,0)
close.MouseButton1Click:Connect(function() panel.Visible=false end)

makeDraggable(panel, title)

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1,-16,1,-58)
scroll.Position = UDim2.new(0,8,0,54)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Color3.fromRGB(0,255,150)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = panel

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0,7)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = scroll

float.MouseButton1Click:Connect(function() panel.Visible = not panel.Visible end)

------------------------------------------------------------
-- UI BUILDERS
------------------------------------------------------------
local function sectionHeader(text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,0,0,24)
    l.BackgroundTransparency = 1
    l.Text = "── "..text.." ──"
    l.TextColor3 = Color3.fromRGB(0,255,150)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = scroll
end

local function actionButton(text, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,0,40)
    b.BackgroundColor3 = Color3.fromRGB(28,28,38)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(230,230,230)
    b.TextSize = 14
    b.Font = Enum.Font.GothamMedium
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = scroll
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,8)
    local s = Instance.new("UIStroke",b); s.Color=Color3.fromRGB(46,46,60); s.Thickness=1
    b.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
            b.BackgroundColor3 = Color3.fromRGB(0,255,150)
            b.TextColor3 = Color3.fromRGB(10,10,15)
            task.delay(0.12, function()
                b.BackgroundColor3 = Color3.fromRGB(28,28,38)
                b.TextColor3 = Color3.fromRGB(230,230,230)
            end)
            safe(cb)
        end
    end)
    return b
end

local function toggleButton(text, getter, setter)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,0,40)
    b.BackgroundColor3 = Color3.fromRGB(28,28,38)
    b.Text = "⬜ "..text
    b.TextColor3 = Color3.fromRGB(230,230,230)
    b.TextSize = 14
    b.Font = Enum.Font.GothamMedium
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = scroll
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,8)
    local s = Instance.new("UIStroke",b); s.Color=Color3.fromRGB(46,46,60); s.Thickness=1

    local function refresh()
        if getter() then
            b.Text = "🟩 "..text
            b.BackgroundColor3 = Color3.fromRGB(0,60,40)
            b.TextColor3 = Color3.fromRGB(0,255,150)
            s.Color = Color3.fromRGB(0,255,150)
        else
            b.Text = "⬜ "..text
            b.BackgroundColor3 = Color3.fromRGB(28,28,38)
            b.TextColor3 = Color3.fromRGB(230,230,230)
            s.Color = Color3.fromRGB(46,46,60)
        end
    end
    b.MouseButton1Click:Connect(function()
        setter(not getter()); refresh()
    end)
    return b
end

local function slider(text, min, max, def, cb)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1,0,0,52)
    holder.BackgroundColor3 = Color3.fromRGB(24,24,32)
    holder.BorderSizePixel = 0
    holder.Parent = scroll
    Instance.new("UICorner",holder).CornerRadius = UDim.new(0,8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-16,0,22)
    lbl.Position = UDim2.new(0,8,0,4)
    lbl.BackgroundTransparency = 1
    lbl.Text = text..": "..def
    lbl.TextColor3 = Color3.fromRGB(200,200,200)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = holder

    local bar = Instance.new("TextButton")
    bar.Size = UDim2.new(1,-16,0,12)
    bar.Position = UDim2.new(0,8,0,30)
    bar.BackgroundColor3 = Color3.fromRGB(45,45,60)
    bar.Text = ""
    bar.BorderSizePixel = 0
    bar.AutoButtonColor = false
    bar.Parent = holder
    Instance.new("UICorner",bar).CornerRadius = UDim.new(1,0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((def-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(0,255,150)
    fill.BorderSizePixel = 0
    fill.Parent = bar
    Instance.new("UICorner",fill).CornerRadius = UDim.new(1,0)

    local dragging = false
    local function setV(x)
        local rel = math.clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(rel,0,1,0)
        local v = math.floor(min + (max-min)*rel + 0.5)
        lbl.Text = text..": "..v
        safe(cb, v)
    end
    bar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging = true; setV(i.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement) then
            setV(i.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
