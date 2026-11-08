local P,LP,Cam,RS,UIS,TS=game:GetService("Players"),game:GetService("Players").LocalPlayer,workspace.CurrentCamera,game:GetService("RunService"),game:GetService("UserInputService"),game:GetService("TweenService")
local CG=game:GetService("CoreGui")local Host=CG:FindFirstChild("RobloxGui")and CG.RobloxGui:FindFirstChild("ControlBar")or CG:FindFirstChild("RobloxGui")or LP:WaitForChild("PlayerGui")
if Host:FindFirstChild("UEPremiumPanel") then Host.UEPremiumPanel:Destroy() end

local Cfg,Str={Esp=false,Speed=16,InfJump=false,CamLock=false,NoRecoil=false,Fov=150},'loadstring(game:HttpGet("https://githubusercontent.com"))()'
local Frame=Instance.new("Frame",Host)Frame.Name="UEPremiumPanel"Frame.Size=UDim2.new(0,240,0,190)Frame.Position=UDim2.new(0.05,0,0.25,0)Frame.BackgroundColor3=Color3.fromRGB(13,14,18)Frame.BackgroundTransparency=0.1Frame.Active=trueFrame.Draggable=trueInstance.new("UICorner",Frame).CornerRadius=UDim.new(0,6)
local Bar=Instance.new("Frame",Frame)Bar.Size=UDim2.new(1,0,0,2)Bar.BackgroundColor3=Color3.fromRGB(0,162,255)Instance.new("UICorner",Bar).CornerRadius=UDim.new(0,6)
local Title=Instance.new("TextLabel",Frame)Title.Size=UDim2.new(1,-20,0,30)Title.Position=UDim2.new(0,10,0,2)Title.Text="UNNAMED ENHANCEMENTS // MOBILE"Title.TextColor3=Color3.fromRGB(255,255,255)Title.BackgroundTransparency=1Title.Font=Enum.Font.CodeTitle.TextSize=11Title.TextXAlignment=Enum.TextXAlignment.Left

local Nav=Instance.new("Frame",Frame)Nav.Size=UDim2.new(0,65,1,-35)Nav.Position=UDim2.new(0,6,0,32)Nav.BackgroundColor3=Color3.fromRGB(18,19,23)Instance.new("UICorner",Nav).CornerRadius=UDim.new(0,4)
local NavL=Instance.new("UIListLayout",Nav)NavL.Padding=UDim.new(0,3)NavL.HorizontalAlignment=Enum.HorizontalAlignment.Center local Container=Instance.new("Frame",Frame)Container.Size=UDim2.new(1,-85,1,-35)Container.Position=UDim2.new(0,78,0,32)Container.BackgroundTransparency=1

local Pages={}local function makePage(name)
    local scr=Instance.new("ScrollingFrame",Container)scr.Size=UDim2.new(1,0,1,0)scr.BackgroundTransparency=1scr.BorderSizePixel=0scr.ScrollBarThickness=1scr.CanvasSize=UDim2.new(0,0,0,200)scr.Visible=false Instance.new("UIListLayout",scr).Padding=UDim.new(0,5)Pages[name]=scr
    local btn=Instance.new("TextButton",Nav)btn.Size=UDim2.new(1,-4,0,22)btn.BackgroundColor3=Color3.fromRGB(26,28,34)btn.TextColor3=Color3.fromRGB(140,145,155)btn.Text=name:upper()btn.Font=Enum.Font.Codebtn.TextSize=8Instance.new("UICorner",btn).CornerRadius=UDim.new(0,3) btn.MouseButton1Click:Connect(function()for _,p in pairs(Pages) do p.Visible=false end scr.Visible=true end)
end
makePage("Aim")makePage("Visual")Pages["Aim"].Visible=true

local function addUESwitch(page,txt,cb)
    local f=Instance.new("Frame",Pages[page])f.Size=UDim2.new(1,-4,0,32)f.BackgroundColor3=Color3.fromRGB(20,21,27)Instance.new("UICorner",f).CornerRadius=UDim.new(0,4)
    local l=Instance.new("TextLabel",f)l.Size=UDim2.new(0.6,0,1,0)l.Position=UDim2.new(0,6,0,0)l.Text=txtl.TextColor3=Color3.fromRGB(180,185,195)l.Font=Enum.Font.Codel.TextSize=10l.BackgroundTransparency=1l.TextXAlignment=Enum.TextXAlignment.Left
    local bg=Instance.new("TextButton",f)bg.Size=UDim2.new(0,32,0,14)bg.Position=UDim2.new(1,-40,0,9)bg.BackgroundColor3=Color3.fromRGB(40,42,50)bg.Text=""Instance.new("UICorner",bg).CornerRadius=UDim.new(1,0)
    local s=Instance.new("Frame",bg)s.Size=UDim2.new(0,10,0,10)s.Position=UDim2.new(0,2,0,2)s.BackgroundColor3=Color3.fromRGB(255,255,255)Instance.new("UICorner",s).CornerRadius=UDim.new(1,0)
    local state=false bg.MouseButton1Click:Connect(function() state=not state TS:Create(s,TweenInfo.new(0.12),{Position=state and UDim2.new(0,20,0,2) or UDim2.new(0,2,0,2)}):Play() TS:Create(bg,TweenInfo.new(0.12),{BackgroundColor3=state and Color3.fromRGB(0,162,255) or Color3.fromRGB(40,42,50)}):Play() cb(state) end)
end

RS.RenderStepped:Connect(function() pcall(function()
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.WalkSpeed = Cfg.Speed local w=LP.Character:FindFirstChildOfClass("Tool")if Cfg.NoRecoil and w and w:FindFirstChild("Configuration") and w.Configuration:FindFirstChild("Recoil") then w.Configuration.Recoil.Value=0 end end
    if Cfg.CamLock then local target,near=nil,Cfg.Fov local center=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y/2)for _,p in ipairs(P:GetPlayers()) do if p~=LP and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health>0 and (p.Team~=LP.Team or tostring(p.Team)=="Neutral") then local pos,vis=Cam:WorldToViewportPoint(p.Character.Head.Position)if vis then local d=(Vector2.new(pos.X,pos.Y)-center).Magnitude if d<near then target=p near=d end end end end if target then Cam.CFrame=CFrame.lookAt(Cam.CFrame.Position,target.Character.Head.Position) end end
end) end)
UIS.JumpRequest:Connect(function()if Cfg.InfJump and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping) end end)
task.spawn(function() while task.wait(1) do for _,p in ipairs(P:GetPlayers()) do if p~=LP and p.Character then pcall(function() local b=p.Character:FindFirstChild("UE_Box") if not b then b=Instance.new("Highlight",p.Character)b.Name="UE_Box"b.FillColor=Color3.fromRGB(0,162,255)b.FillTransparency=0.5 b.OutlineColor=Color3.fromRGB(255,255,255) end b.Enabled=Cfg.Esp end) end end end end)

addUESwitch("Aim", "Silent Aim", function(s) Cfg.CamLock = s end)
addUESwitch("Aim", "No Recoil", function(s) Cfg.NoRecoil = s end)
addUESwitch("Visual", "Player ESP", function(s) Cfg.Esp = s end)
addUESwitch("Visual", "WalkSpeed", function(s) Cfg.Speed = s and 50 or 16 end)
addUESwitch("Visual", "Inf Jump", function(s) Cfg.InfJump = s end)

local Cpy=Instance.new("TextButton",Nav)Cpy.Size=UDim2.new(1,-4,0,20)Cpy.BackgroundColor3=Color3.fromRGB(0,120,200)Cpy.TextColor3=Color3.fromRGB(255,255,255)Cpy.Text="COPY"Cpy.Font=Enum.Font.Code Cpy.TextSize=8 Instance.new("UICorner",Cpy).CornerRadius=UDim.new(0,3)
Cpy.MouseButton1Click:Connect(function() local fn=setclipboard or toclipboard or (Clipboard and Clipboard.set)pcall(function() if fn then fn(Str) Cpy.Text="DONE" task.wait(1) Cpy.Text="COPY" end end) end)
local Cls=Instance.new("TextButton",Nav)Cls.Size=UDim2.new(1,-4,0,20)Cls.BackgroundColor3=Color3.fromRGB(40,20,20)Cls.TextColor3=Color3.fromRGB(255,100,100)Cls.Text="CLOSE"Cls.Font=Enum.Font.Code Cls.TextSize=8 Instance.new("UICorner",Cls).CornerRadius=UDim.new(0,3)Cls.MouseButton1Click:Connect(function() Frame:Destroy() end)
