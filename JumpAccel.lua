-- ══════════════════════════════════════════════════════════════════════
--  JUMP ACCELERATION — standalone
--  Lógica extraída de script_lua_fixed.txt (applyFrontalJump /
--  ActivateFrontalJump, rama EnableJumpAcceleration).
--  GUI: misma pill draggable de HideGuis-7, con toggle + slider (10-400).
-- ══════════════════════════════════════════════════════════════════════

--// SERVICES
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService   = game:GetService("TweenService")
local Debris         = game:GetService("Debris")
local Workspace      = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local pg          = LocalPlayer:WaitForChild("PlayerGui")

-- ── Limpiar instancia previa ──────────────────────────────────────────
local prev = pg:FindFirstChild("_JumpAccelGui")
if prev then prev:Destroy() end

-- ── Config ────────────────────────────────────────────────────────────
local Config = {
    EnableJumpAcceleration = false,
    JumpAccelerationSpeed  = 42,   -- rango 10–400
}

-- ── Variables de estado (igual que en el script original) ─────────────
local camera        = Workspace.CurrentCamera
local currentSpeed  = Config.JumpAccelerationSpeed
local airAccumulator = 0
local lastTick      = tick()
local wasAir        = false
local activeBV      = nil
local lastJumpTime  = tick()
local jumpInterval  = 0.65
local rampLocked    = false

-- ── Lógica de Jump Acceleration ───────────────────────────────────────
-- Extraída de ActivateFrontalJump() — solo la rama EnableJumpAcceleration.
local function activateAccel()
    if not Config.EnableJumpAcceleration then return end
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    lastJumpTime = tick()
end

-- Extraída de applyFrontalJump() — solo la rama EnableJumpAcceleration.
local function applyAccel()
    if not Config.EnableJumpAcceleration then return end

    local deltaTime = tick() - lastTick
    lastTick = tick()
    local baseSpeed = math.clamp(
        tonumber(Config.JumpAccelerationSpeed) or 42,
        10, 400
    )

    local char = LocalPlayer.Character
    if not char then return end
    local root     = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not root or not humanoid then return end

    local isAir      = humanoid.FloorMaterial == Enum.Material.Air
    local state      = humanoid:GetState()
    local isOnGround = (
        state == Enum.HumanoidStateType.Landed or
        state == Enum.HumanoidStateType.Running
    ) and not isAir

    -- Al aterrizar: resetear velocidad y acumulador
    if wasAir and isOnGround then
        currentSpeed    = baseSpeed
        airAccumulator  = 0
        rampLocked      = false
    end
    wasAir = isAir

    local lookDir = camera.CFrame.LookVector
    lookDir = Vector3.new(lookDir.X, 0, lookDir.Z)
    if lookDir.Magnitude ~= 0 then
        lookDir = lookDir.Unit
    end

    if isAir then
        -- En el aire: mantener impulso horizontal sin fuerza Y
        if activeBV then activeBV:Destroy() end
        local bv = Instance.new("BodyVelocity")
        bv.Velocity  = lookDir * currentSpeed
        bv.MaxForce  = Vector3.new(4e5, 0, 4e5)
        bv.P         = 1250
        bv.Parent    = root
        Debris:AddItem(bv, 0.1)
        activeBV = bv
    else
        -- En el suelo: acumular y auto-saltar
        airAccumulator = airAccumulator + deltaTime
        while airAccumulator >= 0.04 do
            airAccumulator = airAccumulator - 0.04
            currentSpeed   = math.min(baseSpeed + 10, currentSpeed + 0.3)
        end

        if activeBV then activeBV:Destroy() end
        local bv = Instance.new("BodyVelocity")
        bv.Velocity  = lookDir * currentSpeed
        bv.MaxForce  = Vector3.new(4e5, 0, 4e5)
        bv.P         = 1250
        bv.Parent    = root
        Debris:AddItem(bv, 0.1)
        activeBV = bv

        currentSpeed = math.max(baseSpeed, currentSpeed - 2.5 * deltaTime)

        if tick() - lastJumpTime >= jumpInterval then
            activateAccel()
        end
    end
end

-- ── Heartbeat ─────────────────────────────────────────────────────────
local heartbeat = RunService.Heartbeat:Connect(function()
    pcall(applyAccel)
end)

-- ══════════════════════════════════════════════════════════════════════
--  GUI — misma pill de HideGuis-7, expandida con toggle + slider
-- ══════════════════════════════════════════════════════════════════════

-- Paleta idéntica a HideGuis-7
local BG       = Color3.fromRGB(40,  40,  45)
local ACCENT   = Color3.fromRGB(255, 255, 255)
local ON_COLOR = Color3.fromRGB(52,  199, 89)
local OFF_COLOR = BG

-- ── ScreenGui ────────────────────────────────────────────────────────
local gui = Instance.new("ScreenGui")
gui.Name           = "_JumpAccelGui"
gui.ResetOnSpawn   = false
gui.IgnoreGuiInset = true
gui.DisplayOrder   = 9999
gui.Parent         = pg

-- ── Pill principal (más alta que HideGuis para meter toggle + slider) ─
local PILL_W = 160
local PILL_H = 78
local pill = Instance.new("Frame")
pill.Size                  = UDim2.fromOffset(PILL_W, PILL_H)
pill.Position              = UDim2.new(0, 20, 0, 110)
pill.BackgroundColor3      = BG
pill.BackgroundTransparency = 0.30
pill.BorderSizePixel       = 0
pill.ClipsDescendants      = true
pill.ZIndex                = 2
pill.Parent                = gui

local pillCorner = Instance.new("UICorner")
pillCorner.CornerRadius = UDim.new(0, 14)
pillCorner.Parent       = pill

-- UIGradient glassy (idéntico a HideGuis-7)
local glassy = Instance.new("UIGradient")
glassy.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(180, 185, 200)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(240, 243, 250)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(180, 185, 200)),
})
glassy.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0,   0.45),
    NumberSequenceKeypoint.new(0.5, 0.15),
    NumberSequenceKeypoint.new(1,   0.45),
})
glassy.Rotation = 90
glassy.Parent   = pill

-- UIStroke animado (idéntico a HideGuis-7)
local stroke = Instance.new("UIStroke")
stroke.Thickness    = 2.5
stroke.Color        = ACCENT
stroke.Transparency = 0.20
stroke.LineJoinMode = Enum.LineJoinMode.Round
stroke.Parent       = pill

local h, s, v     = Color3.toHSV(ACCENT)
local accentLight  = Color3.fromHSV(h, math.max(0, s - 0.3), math.min(1, v + 0.25))
local accentDark   = Color3.fromHSV(h, math.min(1, s + 0.1), math.max(0, v - 0.25))

local strokeGrad = Instance.new("UIGradient")
strokeGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   accentDark),
    ColorSequenceKeypoint.new(0.5, accentLight),
    ColorSequenceKeypoint.new(1,   accentDark),
})
strokeGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0,   0.4),
    NumberSequenceKeypoint.new(0.5, 0),
    NumberSequenceKeypoint.new(1,   0.4),
})
strokeGrad.Offset = Vector2.new(-1.5, 0)
strokeGrad.Parent = stroke

TweenService:Create(
    strokeGrad,
    TweenInfo.new(1.4, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false),
    { Offset = Vector2.new(1.5, 0) }
):Play()

TweenService:Create(
    stroke,
    TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
    { Transparency = 0.0 }
):Play()

-- ── Título (zona de drag) ─────────────────────────────────────────────
local titleBar = Instance.new("Frame")
titleBar.Size             = UDim2.new(1, 0, 0, 28)
titleBar.Position         = UDim2.fromOffset(0, 0)
titleBar.BackgroundTransparency = 1
titleBar.ZIndex           = 3
titleBar.Parent           = pill

local titleLabel = Instance.new("TextLabel")
titleLabel.Size               = UDim2.new(1, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text               = "JUMP ACCEL"
titleLabel.TextColor3         = Color3.fromRGB(240, 240, 240)
titleLabel.Font               = Enum.Font.GothamBlack
titleLabel.TextSize           = 13
titleLabel.TextXAlignment     = Enum.TextXAlignment.Center
titleLabel.ZIndex             = 4
titleLabel.Parent             = titleBar

-- Botón de drag encima del título
local dragBtn = Instance.new("TextButton")
dragBtn.Size                 = UDim2.new(1, 0, 1, 0)
dragBtn.BackgroundTransparency = 1
dragBtn.Text                 = ""
dragBtn.ZIndex               = 5
dragBtn.Parent               = titleBar

-- ── Toggle row ───────────────────────────────────────────────────────
local toggleRow = Instance.new("Frame")
toggleRow.Size             = UDim2.new(1, -16, 0, 22)
toggleRow.Position         = UDim2.fromOffset(8, 30)
toggleRow.BackgroundTransparency = 1
toggleRow.ZIndex           = 3
toggleRow.Parent           = pill

local toggleLabel = Instance.new("TextLabel")
toggleLabel.Size               = UDim2.new(1, -44, 1, 0)
toggleLabel.BackgroundTransparency = 1
toggleLabel.Text               = "Activar"
toggleLabel.TextColor3         = Color3.fromRGB(210, 210, 210)
toggleLabel.Font               = Enum.Font.Gotham
toggleLabel.TextSize           = 11
toggleLabel.TextXAlignment     = Enum.TextXAlignment.Left
toggleLabel.ZIndex             = 4
toggleLabel.Parent             = toggleRow

-- Pill del toggle (pequeña, a la derecha)
local togglePill = Instance.new("Frame")
togglePill.Size              = UDim2.fromOffset(36, 18)
togglePill.Position          = UDim2.new(1, -36, 0.5, -9)
togglePill.BackgroundColor3  = OFF_COLOR
togglePill.BorderSizePixel   = 0
togglePill.ZIndex            = 4
togglePill.Parent            = toggleRow

local tpCorner = Instance.new("UICorner")
tpCorner.CornerRadius = UDim.new(1, 0)
tpCorner.Parent       = togglePill

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Thickness    = 1.2
toggleStroke.Color        = ACCENT
toggleStroke.Transparency = 0.5
toggleStroke.Parent       = togglePill

-- Knob del toggle
local knob = Instance.new("Frame")
knob.Size             = UDim2.fromOffset(12, 12)
knob.Position         = UDim2.fromOffset(3, 3)
knob.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
knob.BorderSizePixel  = 0
knob.ZIndex           = 5
knob.Parent           = togglePill

local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1, 0)
knobCorner.Parent       = knob

-- Botón clickeable encima del toggle
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size                 = UDim2.fromOffset(44, 22)
toggleBtn.Position             = UDim2.new(1, -44, 0.5, -11)
toggleBtn.BackgroundTransparency = 1
toggleBtn.Text                 = ""
toggleBtn.ZIndex               = 6
toggleBtn.Parent               = toggleRow

-- ── Slider row ───────────────────────────────────────────────────────
local sliderRow = Instance.new("Frame")
sliderRow.Size             = UDim2.new(1, -16, 0, 20)
sliderRow.Position         = UDim2.fromOffset(8, 54)
sliderRow.BackgroundTransparency = 1
sliderRow.ZIndex           = 3
sliderRow.Parent           = pill

-- Track del slider
local track = Instance.new("Frame")
track.Size             = UDim2.new(1, -36, 0, 4)
track.Position         = UDim2.new(0, 0, 0.5, -2)
track.BackgroundColor3 = Color3.fromRGB(80, 80, 85)
track.BorderSizePixel  = 0
track.ZIndex           = 4
track.Parent           = sliderRow

local trackCorner = Instance.new("UICorner")
trackCorner.CornerRadius = UDim.new(1, 0)
trackCorner.Parent       = track

-- Fill del slider
local fill = Instance.new("Frame")
fill.Size             = UDim2.new(0, 0, 1, 0)  -- se actualiza al mover
fill.BackgroundColor3 = ON_COLOR
fill.BorderSizePixel  = 0
fill.ZIndex           = 5
fill.Parent           = track

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent       = fill

-- Knob del slider
local sKnob = Instance.new("Frame")
sKnob.Size             = UDim2.fromOffset(12, 12)
sKnob.Position         = UDim2.new(0, -6, 0.5, -6)
sKnob.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
sKnob.BorderSizePixel  = 0
sKnob.ZIndex           = 6
sKnob.Parent           = track

local sKnobCorner = Instance.new("UICorner")
sKnobCorner.CornerRadius = UDim.new(1, 0)
sKnobCorner.Parent       = sKnob

-- Label del valor
local valLabel = Instance.new("TextLabel")
valLabel.Size               = UDim2.fromOffset(32, 20)
valLabel.Position           = UDim2.new(1, 4, 0, 0)
valLabel.BackgroundTransparency = 1
valLabel.Text               = tostring(Config.JumpAccelerationSpeed)
valLabel.TextColor3         = Color3.fromRGB(210, 210, 210)
valLabel.Font               = Enum.Font.Gotham
valLabel.TextSize            = 10
valLabel.TextXAlignment      = Enum.TextXAlignment.Left
valLabel.ZIndex              = 4
valLabel.Parent              = sliderRow

-- ── Lógica del slider ────────────────────────────────────────────────
local SLIDER_MIN = 10
local SLIDER_MAX = 400

local function sliderSetValue(v)
    v = math.clamp(math.round(v), SLIDER_MIN, SLIDER_MAX)
    Config.JumpAccelerationSpeed = v
    currentSpeed = v
    valLabel.Text = tostring(v)
    local pct = (v - SLIDER_MIN) / (SLIDER_MAX - SLIDER_MIN)
    fill.Size      = UDim2.new(pct, 0, 1, 0)
    sKnob.Position = UDim2.new(pct, -6, 0.5, -6)
end

-- Inicializar fill con valor por defecto
sliderSetValue(Config.JumpAccelerationSpeed)

local sliderDragging = false

track.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch
    or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderDragging = true
        local trackAbs = track.AbsoluteSize.X
        local trackPos = track.AbsolutePosition.X
        local pct = math.clamp((inp.Position.X - trackPos) / trackAbs, 0, 1)
        sliderSetValue(SLIDER_MIN + pct * (SLIDER_MAX - SLIDER_MIN))
    end
end)

UserInputService.InputChanged:Connect(function(inp)
    if not sliderDragging then return end
    if inp.UserInputType == Enum.UserInputType.Touch
    or inp.UserInputType == Enum.UserInputType.MouseMovement then
        local trackAbs = track.AbsoluteSize.X
        local trackPos = track.AbsolutePosition.X
        local pct = math.clamp((inp.Position.X - trackPos) / trackAbs, 0, 1)
        sliderSetValue(SLIDER_MIN + pct * (SLIDER_MAX - SLIDER_MIN))
    end
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch
    or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderDragging = false
    end
end)

-- ── Lógica del toggle ────────────────────────────────────────────────
local function setToggle(state)
    Config.EnableJumpAcceleration = state
    if state then
        TweenService:Create(togglePill, TweenInfo.new(0.15), { BackgroundColor3 = ON_COLOR }):Play()
        TweenService:Create(knob,       TweenInfo.new(0.15), { Position = UDim2.fromOffset(21, 3) }):Play()
        -- resetear estado interno al activar
        currentSpeed   = Config.JumpAccelerationSpeed
        airAccumulator = 0
        wasAir         = false
        rampLocked     = false
    else
        TweenService:Create(togglePill, TweenInfo.new(0.15), { BackgroundColor3 = OFF_COLOR }):Play()
        TweenService:Create(knob,       TweenInfo.new(0.15), { Position = UDim2.fromOffset(3, 3) }):Play()
        if activeBV then activeBV:Destroy(); activeBV = nil end
    end
end

toggleBtn.MouseButton1Click:Connect(function()
    setToggle(not Config.EnableJumpAcceleration)
end)

-- ── Drag de la pill (idéntico a HideGuis-7) ──────────────────────────
local dragging   = false
local moved      = false
local dragOrigin = Vector2.zero
local pillOrigin = UDim2.new()
local THRESHOLD  = 6

dragBtn.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch
    or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging   = true
        moved      = false
        dragOrigin = inp.Position
        pillOrigin = pill.Position
    end
end)

UserInputService.InputChanged:Connect(function(inp)
    if sliderDragging then return end   -- prioridad al slider
    if not dragging then return end
    if inp.UserInputType == Enum.UserInputType.Touch
    or inp.UserInputType == Enum.UserInputType.MouseMovement then
        local d = inp.Position - dragOrigin
        if not moved and (math.abs(d.X) > THRESHOLD or math.abs(d.Y) > THRESHOLD) then
            moved = true
        end
        if moved then
            pill.Position = UDim2.new(
                pillOrigin.X.Scale, pillOrigin.X.Offset + d.X,
                pillOrigin.Y.Scale, pillOrigin.Y.Offset + d.Y
            )
        end
    end
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch
    or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
        moved    = false
    end
end)
