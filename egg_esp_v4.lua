-- EGG ESP — BillboardGui sobre cada huevo en Workspace.Egg
-- Estilo Yin Yang FloatingToggle (HideGuis)

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local lp           = Players.LocalPlayer
local pg           = lp:WaitForChild("PlayerGui")

-- Limpiar corrida previa
for _, v in ipairs(workspace:GetDescendants()) do
    if v:IsA("BillboardGui") and v.Name == "_EggBill" then v:Destroy() end
end

-- ── Paleta Yin Yang ───────────────────────────────────────────
local BG = Color3.fromRGB(40, 40, 45)

local RARITY_COLOR = {
    Divine    = Color3.fromRGB(255, 100, 180),
    Ethereal  = Color3.fromRGB(180, 100, 255),
    Legendary = Color3.fromRGB(255, 200, 0),
    Mythic    = Color3.fromRGB(0, 150, 255),
    Rare      = Color3.fromRGB(100, 200, 255),
    Common    = Color3.fromRGB(150, 150, 150),
}

local function rarityColor(r)
    return RARITY_COLOR[r] or Color3.fromRGB(210, 210, 210)
end

-- Huevos que NO reciben ESP (ambas variantes de idioma por si acaso)
local IGNORED = {
    ["Brown Egg"]    = true,
    ["White Egg"]    = true,
    ["Huevo marrón"] = true,
    ["Huevo blanco"] = true,
    ["Slime Egg"]    = true,
    ["Stone Egg"]    = true,
    ["Flower Egg"]   = true,
    ["Cracked Egg"]  = true,
    ["Huevo de slime"]  = true,
    ["Huevo de piedra"] = true,
    ["Huevo de flores"] = true,
    ["Huevo agrietado"] = true,
}

-- ── Crear billboard sobre un egg ──────────────────────────────
local function makeBill(egg)
    -- Ignorar huevos comunes que no interesan
    if IGNORED[egg.Name] then return end

    -- El scanner confirmó que los huevos son Models sin atributos de rareza.
    -- Usamos egg.Name como etiqueta (ej: "Galaxy Egg", "White Egg").
    -- El color de borde usa el fallback gris hasta que se confirme
    -- cómo está guardada la rareza real en el juego.
    local label_text = egg.Name
    local accent      = rarityColor(egg.Name)  -- será default gris salvo que coincida

    -- BillboardGui necesita una BasePart como Adornee, no un Model.
    -- Buscamos PrimaryPart primero, luego la primera BasePart que encontremos.
    local adornee = egg.PrimaryPart
        or egg:FindFirstChildWhichIsA("BasePart", true)
    if not adornee then return end  -- sin BasePart no se puede mostrar nada

    local bill = Instance.new("BillboardGui")
    bill.Name         = "_EggBill"
    bill.Size         = UDim2.fromOffset(130, 50)
    bill.StudsOffset  = Vector3.new(0, 4, 0)   -- flota encima del huevo
    bill.AlwaysOnTop  = true
    bill.Adornee      = adornee
    bill.Parent       = egg

    -- Frame con estilo pill de HideGuis
    local frame = Instance.new("Frame")
    frame.Size                  = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3      = BG
    frame.BackgroundTransparency = 0.25
    frame.BorderSizePixel       = 0
    frame.Parent                = bill

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    -- Glassy gradient (igual al HideGuis)
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
    glassy.Parent   = frame

    -- UIStroke con color de rareza
    local stroke = Instance.new("UIStroke")
    stroke.Thickness    = 2
    stroke.Color        = accent
    stroke.Transparency = 0.2
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    stroke.Parent       = frame

    -- Sweep animado en el stroke
    local h, s, v = Color3.toHSV(accent)
    local aLight  = Color3.fromHSV(h, math.max(0, s - 0.3), math.min(1, v + 0.25))
    local aDark   = Color3.fromHSV(h, math.min(1, s + 0.1), math.max(0, v - 0.25))

    local sg = Instance.new("UIGradient")
    sg.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   aDark),
        ColorSequenceKeypoint.new(0.5, aLight),
        ColorSequenceKeypoint.new(1,   aDark),
    })
    sg.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,   0.4),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1,   0.4),
    })
    sg.Offset = Vector2.new(-1.5, 0)
    sg.Parent = stroke

    TweenService:Create(
        sg,
        TweenInfo.new(1.4, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false),
        { Offset = Vector2.new(1.5, 0) }
    ):Play()

    -- Label con nombre + rareza
    local label = Instance.new("TextLabel")
    label.Size                  = UDim2.new(1, -10, 1, -6)
    label.Position              = UDim2.new(0, 5, 0, 3)
    label.BackgroundTransparency = 1
    label.Text                  = label_text
    label.TextColor3            = Color3.fromRGB(240, 240, 240)
    label.Font                  = Enum.Font.GothamBold
    label.TextSize              = 11
    label.TextXAlignment        = Enum.TextXAlignment.Center
    label.TextYAlignment        = Enum.TextYAlignment.Center
    label.TextWrapped           = true
    label.Parent                = frame
end

-- ── Hookear carpeta Egg ────────────────────────────────────────
local function hookFolder(folder)
    for _, egg in ipairs(folder:GetChildren()) do
        pcall(makeBill, egg)
    end
    folder.ChildAdded:Connect(function(egg)
        task.wait(0.05)
        pcall(makeBill, egg)
    end)
end

local eggFolder = workspace:FindFirstChild("RenderedEggs")
if eggFolder then
    hookFolder(eggFolder)
else
    workspace.ChildAdded:Connect(function(child)
        if child.Name == "RenderedEggs" then
            hookFolder(child)
        end
    end)
end
