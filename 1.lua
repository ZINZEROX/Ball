--[[
    ═══════════════════════════════════════════════════════════════════════════
    Yin yang
    ═══════════════════════════════════════════════════════════════════════════
]]

print("\n" .. string.rep("=", 80))
print("EVADE v5.2 BETA - FRONTAL JUMP + BETA NEW")
print(string.rep("=", 80))

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalizationService = game:GetService("LocalizationService")

if not LocalPlayer then
    error("ERROR: No local player available")
    return
end

--// ═════════════════════════════════════════════════════════════════════════════
--// SAE 24H KEY SYSTEM — el resto de la beta no se inicializa sin validación
--// SAE 24H KEY SYSTEM — the rest of the beta does not initialize without validation
--// ═════════════════════════════════════════════════════════════════════════════

local KEY_PORTAL_URL = "https://yinkeysys-2xyu9dbe.manus.space"
local KEY_VALIDATE_URL = KEY_PORTAL_URL .. "/api/validate?key="
local KEY_CACHE_FILE = "SAE_EvadeBeta_Key.txt"
local KeyHttpService = game:GetService("HttpService")
local KeyTweenService = game:GetService("TweenService")

--// Paleta exclusiva Yin–Yang: blanco, negro y grises, independiente del tema principal.
local KeyVisualTheme = {
    Background = Color3.fromRGB(7, 7, 7),
    Surface = Color3.fromRGB(20, 20, 20),
    Header = Color3.fromRGB(12, 12, 12),
    Text = Color3.fromRGB(248, 248, 248),
    TextDim = Color3.fromRGB(165, 165, 165),
    Accent = Color3.fromRGB(255, 255, 255),
    Borders = {Color3.fromRGB(80, 80, 80), Color3.fromRGB(255, 255, 255), Color3.fromRGB(128, 128, 128), Color3.fromRGB(232, 232, 232)},
}

--// KEY LANGUAGE SYSTEM — detecta el locale del jugador con Roblox LocalizationService.
--// Las traducciones son locales para que la ventana siga funcionando aunque el
--// servicio de traducción no esté disponible. Idiomas no incluidos usan inglés.
local KeyLanguage = "en"
local KeyLanguageTranslations = {
    en = {
        brand_sub = "EVADE BETA • 24H KEY", title = "KEY SYSTEM", subtitle = "Personal 24-hour access",
        check = "CHECK KEY", link = "GET LINK", secure = "Secure server verification", checking = "…  CHECKING",
        revalidating = "REVALIDATING SAVED KEY", contacting = "CONTACTING SERVER", accepted = "KEY ACCEPTED",
        loading = "LOADING BETA", access_granted = "ACCESS GRANTED", invalid_format = "INVALID FORMAT",
        server_unavailable = "SERVER UNAVAILABLE", invalid_response = "INVALID RESPONSE", invalid_expired = "INVALID OR EXPIRED KEY",
        saved_removed = "SAVED KEY REMOVED", link_copied = "LINK COPIED", portal = "PORTAL",
        no_file_support = "YOUR EXECUTOR HAS NO FILE SUPPORT",
    },
    es = {
        brand_sub = "BETA DE EVADE • CLAVE 24H", title = "SISTEMA DE CLAVE", subtitle = "Acceso personal de 24 horas",
        check = "VERIFICAR CLAVE", link = "OBTENER ENLACE", secure = "Verificación segura del servidor", checking = "…  VERIFICANDO",
        revalidating = "REVALIDANDO CLAVE GUARDADA", contacting = "CONTACTANDO AL SERVIDOR", accepted = "CLAVE ACEPTADA",
        loading = "CARGANDO BETA", access_granted = "ACCESO CONCEDIDO", invalid_format = "FORMATO INVÁLIDO",
        server_unavailable = "SERVIDOR NO DISPONIBLE", invalid_response = "RESPUESTA INVÁLIDA", invalid_expired = "CLAVE INVÁLIDA O EXPIRADA",
        saved_removed = "CLAVE GUARDADA ELIMINADA", link_copied = "ENLACE COPIADO", portal = "PORTAL",
        no_file_support = "TU EXECUTOR NO TIENE SOPORTE DE ARCHIVOS",
    },
    pt = {
        brand_sub = "EVADE BETA • CHAVE 24H", title = "SISTEMA DE CHAVE", subtitle = "Acesso pessoal de 24 horas",
        check = "VERIFICAR CHAVE", link = "OBTER LINK", secure = "Verificação segura do servidor", checking = "…  VERIFICANDO",
        revalidating = "REVALIDANDO CHAVE SALVA", contacting = "CONTATANDO O SERVIDOR", accepted = "CHAVE ACEITA",
        loading = "CARREGANDO BETA", access_granted = "ACESSO CONCEDIDO", invalid_format = "FORMATO INVÁLIDO",
        server_unavailable = "SERVIDOR INDISPONÍVEL", invalid_response = "RESPOSTA INVÁLIDA", invalid_expired = "CHAVE INVÁLIDA OU EXPIRADA",
        saved_removed = "CHAVE SALVA REMOVIDA", link_copied = "LINK COPIADO", portal = "PORTAL",
        no_file_support = "SEU EXECUTOR NÃO TEM SUPORTE A ARQUIVOS",
    },
    fr = {
        brand_sub = "EVADE BETA • CLÉ 24H", title = "SYSTÈME DE CLÉ", subtitle = "Accès personnel de 24 heures",
        check = "VÉRIFIER LA CLÉ", link = "OBTENIR LE LIEN", secure = "Vérification sécurisée du serveur", checking = "…  VÉRIFICATION",
        revalidating = "REVALIDATION DE LA CLÉ ENREGISTRÉE", contacting = "CONTACT DU SERVEUR", accepted = "CLÉ ACCEPTÉE",
        loading = "CHARGEMENT DE LA BETA", access_granted = "ACCÈS ACCORDÉ", invalid_format = "FORMAT INVALIDE",
        server_unavailable = "SERVEUR INDISPONIBLE", invalid_response = "RÉPONSE INVALIDE", invalid_expired = "CLÉ INVALIDE OU EXPIRÉE",
        saved_removed = "CLÉ ENREGISTRÉE SUPPRIMÉE", link_copied = "LIEN COPIÉ", portal = "PORTAIL",
        no_file_support = "VOTRE EXECUTOR NE PREND PAS EN CHARGE LES FICHIERS",
    },
    de = {
        brand_sub = "EVADE BETA • 24H SCHLÜSSEL", title = "SCHLÜSSELSYSTEM", subtitle = "Persönlicher 24-Stunden-Zugang",
        check = "SCHLÜSSEL PRÜFEN", link = "LINK ERHALTEN", secure = "Sichere Serverüberprüfung", checking = "…  WIRD GEPRÜFT",
        revalidating = "GESPEICHERTEN SCHLÜSSEL PRÜFEN", contacting = "SERVER WIRD KONTAKTIERT", accepted = "SCHLÜSSEL AKZEPTIERT",
        loading = "BETA WIRD GELADEN", access_granted = "ZUGRIFF GEWÄHRT", invalid_format = "UNGÜLTIGES FORMAT",
        server_unavailable = "SERVER NICHT VERFÜGBAR", invalid_response = "UNGÜLTIGE ANTWORT", invalid_expired = "UNGÜLTIGER ODER ABGELAUFENER SCHLÜSSEL",
        saved_removed = "GESPEICHERTER SCHLÜSSEL ENTFERNT", link_copied = "LINK KOPIERT", portal = "PORTAL",
        no_file_support = "DEIN EXECUTOR UNTERSTÜTZT KEINE DATEIEN",
    },
    it = {
        brand_sub = "EVADE BETA • CHIAVE 24H", title = "SISTEMA CHIAVE", subtitle = "Accesso personale di 24 ore",
        check = "VERIFICA CHIAVE", link = "OTTIENI LINK", secure = "Verifica sicura del server", checking = "…  VERIFICA",
        revalidating = "RIVERIFICA CHIAVE SALVATA", contacting = "CONTATTO CON IL SERVER", accepted = "CHIAVE ACCETTATA",
        loading = "CARICAMENTO BETA", access_granted = "ACCESSO CONSENTITO", invalid_format = "FORMATO NON VALIDO",
        server_unavailable = "SERVER NON DISPONIBILE", invalid_response = "RISPOSTA NON VALIDA", invalid_expired = "CHIAVE NON VALIDA O SCADUTA",
        saved_removed = "CHIAVE SALVATA RIMOSSA", link_copied = "LINK COPIATO", portal = "PORTALE",
        no_file_support = "IL TUO EXECUTOR NON SUPPORTA I FILE",
    },
    ru = {
        brand_sub = "EVADE BETA • КЛЮЧ НА 24 Ч", title = "СИСТЕМА КЛЮЧА", subtitle = "Персональный доступ на 24 часа",
        check = "ПРОВЕРИТЬ КЛЮЧ", link = "ПОЛУЧИТЬ ССЫЛКУ", secure = "Безопасная проверка сервера", checking = "…  ПРОВЕРКА",
        revalidating = "ПОВТОРНАЯ ПРОВЕРКА СОХРАНЁННОГО КЛЮЧА", contacting = "СВЯЗЬ С СЕРВЕРОМ", accepted = "КЛЮЧ ПРИНЯТ",
        loading = "ЗАГРУЗКА БЕТА", access_granted = "ДОСТУП РАЗРЕШЁН", invalid_format = "НЕВЕРНЫЙ ФОРМАТ",
        server_unavailable = "СЕРВЕР НЕДОСТУПЕН", invalid_response = "НЕВЕРНЫЙ ОТВЕТ", invalid_expired = "КЛЮЧ НЕДЕЙСТВИТЕЛЕН ИЛИ ИСТЁК",
        saved_removed = "СОХРАНЁННЫЙ КЛЮЧ УДАЛЁН", link_copied = "ССЫЛКА СКОПИРОВАНА", portal = "ПОРТАЛ",
        no_file_support = "ВАШ EXECUTOR НЕ ПОДДЕРЖИВАЕТ ФАЙЛЫ",
    },
    ja = {
        brand_sub = "EVADE BETA • 24時間キー", title = "キーシステム", subtitle = "24時間の個人アクセス",
        check = "キーを確認", link = "リンクを取得", secure = "安全なサーバー検証", checking = "…  確認中",
        revalidating = "保存されたキーを再確認中", contacting = "サーバーに接続中", accepted = "キーが承認されました",
        loading = "ベータを読み込み中", access_granted = "アクセスが許可されました", invalid_format = "形式が無効です",
        server_unavailable = "サーバーを利用できません", invalid_response = "無効な応答です", invalid_expired = "無効または期限切れのキー",
        saved_removed = "保存されたキーを削除しました", link_copied = "リンクをコピーしました", portal = "ポータル",
        no_file_support = "お使いのExecutorはファイルに対応していません",
    },
    ko = {
        brand_sub = "EVADE BETA • 24시간 키", title = "키 시스템", subtitle = "24시간 개인 액세스",
        check = "키 확인", link = "링크 받기", secure = "안전한 서버 확인", checking = "…  확인 중",
        revalidating = "저장된 키 재확인 중", contacting = "서버에 연결 중", accepted = "키 승인됨",
        loading = "베타 로드 중", access_granted = "접근 허용됨", invalid_format = "잘못된 형식",
        server_unavailable = "서버를 사용할 수 없음", invalid_response = "잘못된 응답", invalid_expired = "유효하지 않거나 만료된 키",
        saved_removed = "저장된 키 삭제됨", link_copied = "링크 복사됨", portal = "포털",
        no_file_support = "사용 중인 Executor는 파일을 지원하지 않습니다",
    },
    zh = {
        brand_sub = "EVADE BETA • 24小时密钥", title = "密钥系统", subtitle = "24小时个人访问",
        check = "验证密钥", link = "获取链接", secure = "安全服务器验证", checking = "…  验证中",
        revalidating = "重新验证已保存的密钥", contacting = "正在连接服务器", accepted = "密钥已通过",
        loading = "正在加载测试版", access_granted = "已获得访问权限", invalid_format = "格式无效",
        server_unavailable = "服务器不可用", invalid_response = "响应无效", invalid_expired = "密钥无效或已过期",
        saved_removed = "已删除保存的密钥", link_copied = "链接已复制", portal = "门户",
        no_file_support = "你的Executor不支持文件",
    },
}

local function getKeyLanguage(localeId)
    local language = string.lower(tostring(localeId or "en")):match("^(%a+)") or "en"
    return KeyLanguageTranslations[language] and language or "en"
end

local function keyText(key)
    local languageTable = KeyLanguageTranslations[KeyLanguage] or KeyLanguageTranslations.en
    return languageTable[key] or KeyLanguageTranslations.en[key] or key
end

function getKeyVisualTheme()
    return KeyVisualTheme
end

function addYinSweep(strokeObject, borderColors, duration)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, borderColors[1]),
        ColorSequenceKeypoint.new(0.34, borderColors[2]),
        ColorSequenceKeypoint.new(0.67, borderColors[3]),
        ColorSequenceKeypoint.new(1, borderColors[4]),
    })
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.36),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 0.36),
    })
    gradient.Offset = Vector2.new(-1.5, 0)
    gradient.Parent = strokeObject

    KeyTweenService:Create(
        gradient,
        TweenInfo.new(duration or 1.8, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false),
        {Offset = Vector2.new(1.5, 0)}
    ):Play()

    KeyTweenService:Create(
        strokeObject,
        TweenInfo.new((duration or 1.8) + 0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {Transparency = 0.02}
    ):Play()
end

function normalizeAccessKey(value)
    return tostring(value or ""):gsub("%s+", ""):upper()
end

function isAccessKeyFormat(value)
    return value:match("^YINYANG%-%w%w%w%-%w%w%w%-%w%w%w%-%w%w%w%-%w%w%w$") ~= nil
end

function hasKeyCacheSupport()
    return type(isfile) == "function" and type(readfile) == "function" and type(writefile) == "function" and type(delfile) == "function"
end

function loadCachedKey()
    if not hasKeyCacheSupport() then
        return nil
    end

    local ok, cached = pcall(function()
        if isfile(KEY_CACHE_FILE) then
            return normalizeAccessKey(readfile(KEY_CACHE_FILE))
        end
    end)

    if ok and isAccessKeyFormat(cached or "") then
        return cached
    end

    return nil
end

function saveCachedKey(key)
    if hasKeyCacheSupport() then
        pcall(writefile, KEY_CACHE_FILE, normalizeAccessKey(key))
    end
end

function clearCachedKey()
    if hasKeyCacheSupport() then
        pcall(function()
            if isfile(KEY_CACHE_FILE) then
                delfile(KEY_CACHE_FILE)
            end
        end)
    end
end

function validateAccessKey(value)
    local key = normalizeAccessKey(value)
    if not isAccessKeyFormat(key) then
        return false, "INVALID FORMAT"
    end

    local requestFunction = (syn and syn.request) or http_request or request or (fluxus and fluxus.request)
    local ok, responseBody = pcall(function()
        if requestFunction then
            local response = requestFunction({
                Url = KEY_VALIDATE_URL .. KeyHttpService:UrlEncode(key),
                Method = "GET",
            })

            if not response or tonumber(response.StatusCode) ~= 200 then
                error("HTTP validation failed")
            end
            return response.Body
        end

        return game:HttpGet(KEY_VALIDATE_URL .. KeyHttpService:UrlEncode(key))
    end)

    if not ok or type(responseBody) ~= "string" then
        return false, "SERVER UNAVAILABLE"
    end

    local decodedOk, data = pcall(function()
        return KeyHttpService:JSONDecode(responseBody)
    end)

    if not decodedOk or type(data) ~= "table" then
        return false, "INVALID RESPONSE"
    end

    if data.valid == true then
        return true, "KEY ACCEPTED"
    end

    return false, "INVALID OR EXPIRED KEY"
end

function createKeySystemUI()
    local visualTheme = getKeyVisualTheme()
    local parent
    pcall(function()
        parent = game:GetService("CoreGui")
    end)
    parent = parent or LocalPlayer:WaitForChild("PlayerGui")

    local existing = parent:FindFirstChild("SAEKeySystem")
    if existing then
        existing:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "SAEKeySystem"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999999
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = parent

    local shade = Instance.new("Frame")
    shade.Name = "Shade"
    shade.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shade.BackgroundTransparency = 0.28
    shade.BorderSizePixel = 0
    shade.Size = UDim2.fromScale(1, 1)
    shade.ZIndex = 1
    shade.Parent = gui

    local shadeGradient = Instance.new("UIGradient")
    shadeGradient.Rotation = 25
    shadeGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(1, visualTheme.Background),
    })
    shadeGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.22),
        NumberSequenceKeypoint.new(1, 0.55),
    })
    shadeGradient.Parent = shade

    local panel = Instance.new("Frame")
    panel.Name = "KeyPanel"
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.BackgroundColor3 = visualTheme.Background
    panel.BorderSizePixel = 0
    panel.Position = UDim2.fromScale(0.5, 0.5)
    panel.Size = UDim2.new(0.88, 0, 0, 300)
    panel.ZIndex = 2
    panel.Parent = shade

    local maxSize = Instance.new("UISizeConstraint")
    maxSize.MaxSize = Vector2.new(460, 300)
    maxSize.MinSize = Vector2.new(300, 270)
    maxSize.Parent = panel

    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 16)
    panelCorner.Parent = panel

    local panelStroke = Instance.new("UIStroke")
    panelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    panelStroke.Color = visualTheme.Accent
    panelStroke.Transparency = 0.14
    panelStroke.Thickness = 1.35
    panelStroke.LineJoinMode = Enum.LineJoinMode.Round
    panelStroke.Parent = panel
    addYinSweep(panelStroke, visualTheme.Borders, 1.55)

    local content = Instance.new("Frame")
    content.BackgroundColor3 = visualTheme.Surface
    content.BorderSizePixel = 0
    content.Position = UDim2.fromOffset(1, 1)
    content.Size = UDim2.new(1, -2, 1, -2)
    content.ZIndex = 2
    content.Parent = panel

    local backgroundImage = Instance.new("ImageLabel")
    backgroundImage.Name = "BackgroundImage"
    backgroundImage.BackgroundTransparency = 1
    backgroundImage.Image = "rbxassetid://139826687551366"
    backgroundImage.ImageTransparency = 0.18
    backgroundImage.ScaleType = Enum.ScaleType.Crop
    backgroundImage.Size = UDim2.fromScale(1, 1)
    backgroundImage.ZIndex = 2
    backgroundImage.Parent = content

    local backgroundImageCorner = Instance.new("UICorner")
    backgroundImageCorner.CornerRadius = UDim.new(0, 15)
    backgroundImageCorner.Parent = backgroundImage

    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 15)
    contentCorner.Parent = content

    local contentStroke = Instance.new("UIStroke")
    contentStroke.Color = visualTheme.Borders[3]
    contentStroke.Transparency = 0.66
    contentStroke.Thickness = 1
    contentStroke.Parent = content
    addYinSweep(contentStroke, visualTheme.Borders, 2.15)

    local top = Instance.new("Frame")
    top.BackgroundColor3 = visualTheme.Header
    top.BorderSizePixel = 0
    top.Size = UDim2.new(1, 0, 0, 56)
    top.ZIndex = 3
    top.Parent = content

    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, 12)
    topCorner.Parent = top

    local topCover = Instance.new("Frame")
    topCover.BackgroundColor3 = visualTheme.Header
    topCover.BorderSizePixel = 0
    topCover.Position = UDim2.new(0, 0, 1, -12)
    topCover.Size = UDim2.new(1, 0, 0, 12)
    topCover.ZIndex = 3
    topCover.Parent = top

    local accentLine = Instance.new("Frame")
    accentLine.BackgroundColor3 = visualTheme.Accent
    accentLine.BorderSizePixel = 0
    accentLine.Position = UDim2.new(0, 18, 1, -1)
    accentLine.Size = UDim2.new(1, -36, 0, 1)
    accentLine.ZIndex = 4
    accentLine.Parent = top

    local accentGradient = Instance.new("UIGradient")
    accentGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, visualTheme.Borders[1]),
        ColorSequenceKeypoint.new(0.5, visualTheme.Borders[2]),
        ColorSequenceKeypoint.new(1, visualTheme.Borders[3]),
    })
    accentGradient.Offset = Vector2.new(-1.4, 0)
    accentGradient.Parent = accentLine
    KeyTweenService:Create(
        accentGradient,
        TweenInfo.new(1.75, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false),
        {Offset = Vector2.new(1.4, 0)}
    ):Play()

    local brand = Instance.new("TextLabel")
    brand.BackgroundTransparency = 1
    brand.Font = Enum.Font.GothamBold
    brand.Text = "YIN YANG KEY"
    brand.TextColor3 = visualTheme.Text
    brand.TextSize = 14
    brand.TextXAlignment = Enum.TextXAlignment.Left
    brand.Position = UDim2.new(0, 54, 0, 8)
    brand.Size = UDim2.new(0.60, 0, 0, 18)
    brand.ZIndex = 4
    brand.Parent = top

    local brandSub = Instance.new("TextLabel")
    brandSub.BackgroundTransparency = 1
    brandSub.Font = Enum.Font.GothamMedium
    brandSub.Text = keyText("brand_sub")
    brandSub.TextColor3 = visualTheme.TextDim
    brandSub.TextSize = 8
    brandSub.TextXAlignment = Enum.TextXAlignment.Left
    brandSub.Position = UDim2.new(0, 54, 0, 28)
    brandSub.Size = UDim2.new(0.60, 0, 0, 13)
    brandSub.ZIndex = 4
    brandSub.Parent = top

    local close = Instance.new("TextButton")
    close.AutoButtonColor = false
    close.BackgroundColor3 = visualTheme.Background
    close.BorderSizePixel = 0
    close.Font = Enum.Font.GothamBold
    close.Text = "×"
    close.TextColor3 = visualTheme.TextDim
    close.TextSize = 20
    close.AnchorPoint = Vector2.new(1, 0.5)
    close.Position = UDim2.new(1, -12, 0.5, 0)
    close.Size = UDim2.fromOffset(30, 30)
    close.ZIndex = 4
    close.Parent = top

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 9)
    closeCorner.Parent = close

    local brandIcon = Instance.new("ImageLabel")
    brandIcon.BackgroundTransparency = 1
    brandIcon.Image = "rbxassetid://113137557066757"
    brandIcon.ImageColor3 = visualTheme.Text
    brandIcon.ImageTransparency = 0.02
    brandIcon.Position = UDim2.new(0, 16, 0, 11)
    brandIcon.Size = UDim2.fromOffset(24, 24)
    brandIcon.ZIndex = 4
    brandIcon.Parent = top

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = keyText("title")
    title.TextColor3 = visualTheme.Text
    title.TextSize = 15
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Position = UDim2.new(0, 57, 0, 65)
    title.Size = UDim2.new(1, -75, 0, 21)
    title.ZIndex = 4
    title.Parent = content

    local subtitle = Instance.new("TextLabel")
    subtitle.BackgroundTransparency = 1
    subtitle.Font = Enum.Font.Gotham
    subtitle.Text = keyText("subtitle")
    subtitle.TextColor3 = visualTheme.TextDim
    subtitle.TextSize = 8
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.TextYAlignment = Enum.TextYAlignment.Center
    subtitle.Position = UDim2.new(0, 57, 0, 91)
    subtitle.Size = UDim2.new(1, -75, 0, 15)
    subtitle.ZIndex = 4
    subtitle.Parent = content

    local sectionIcon = Instance.new("ImageLabel")
    sectionIcon.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
    sectionIcon.BackgroundTransparency = 0
    sectionIcon.Image = "rbxassetid://113137557066757"
    sectionIcon.ImageColor3 = visualTheme.Text
    sectionIcon.ImageTransparency = 0.02
    sectionIcon.Position = UDim2.new(0, 18, 0, 64)
    sectionIcon.Size = UDim2.fromOffset(20, 20)
    sectionIcon.ZIndex = 4
    sectionIcon.Parent = content

    local sectionIconCorner = Instance.new("UICorner")
    sectionIconCorner.CornerRadius = UDim.new(0, 8)
    sectionIconCorner.Parent = sectionIcon

    local input = Instance.new("TextBox")
    input.BackgroundColor3 = visualTheme.Background
    input.BorderSizePixel = 0
    input.ClearTextOnFocus = false
    input.Font = Enum.Font.GothamMedium
    input.PlaceholderColor3 = visualTheme.TextDim
    input.PlaceholderText = "YINYANG-XXX-XXX-XXX-XXX-XXX"
    input.Text = ""
    input.TextColor3 = visualTheme.Text
    input.TextSize = 12
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.Position = UDim2.new(0, 18, 0, 118)
    input.Size = UDim2.new(1, -36, 0, 44)
    input.ZIndex = 4
    input.Parent = content

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = input

    local inputPadding = Instance.new("UIPadding")
    inputPadding.PaddingLeft = UDim.new(0, 50)
    inputPadding.PaddingRight = UDim.new(0, 16)
    inputPadding.Parent = input

    local inputStroke = Instance.new("UIStroke")
    inputStroke.Color = visualTheme.Accent
    inputStroke.Transparency = 0.22
    inputStroke.Parent = input
    inputStroke.Thickness = 1.15
    addYinSweep(inputStroke, visualTheme.Borders, 1.8)

    local keyIcon = Instance.new("ImageLabel")
    keyIcon.BackgroundTransparency = 1
    keyIcon.Image = "rbxassetid://82339297204572"
    keyIcon.ImageColor3 = visualTheme.Text
    keyIcon.ImageTransparency = 0.02
    keyIcon.Position = UDim2.new(0, 34, 0, 131)
    keyIcon.Size = UDim2.fromOffset(18, 18)
    keyIcon.ZIndex = 5
    keyIcon.Parent = content

    local keyDivider = Instance.new("Frame")
    keyDivider.BackgroundColor3 = visualTheme.Borders[3]
    keyDivider.BackgroundTransparency = 0.45
    keyDivider.BorderSizePixel = 0
    keyDivider.Position = UDim2.new(0, 63, 0, 122)
    keyDivider.Size = UDim2.new(0, 1, 0, 36)
    keyDivider.ZIndex = 5
    keyDivider.Parent = content

    function createActionButton(name, text, position, size, accent)
        local button = Instance.new("TextButton")
        button.Name = name
        button.AutoButtonColor = false
        button.BackgroundColor3 = visualTheme.Header
        button.BorderSizePixel = 0
        button.Font = Enum.Font.GothamBold
        button.Text = text
        button.TextColor3 = visualTheme.Text
        button.TextSize = 11
        button.Position = position
        button.Size = size
        button.ZIndex = 4
        button.Parent = content

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = button

        local stroke = Instance.new("UIStroke")
        stroke.Color = accent
        stroke.Transparency = 0.18
        stroke.Thickness = 1
        stroke.Parent = button
        addYinSweep(stroke, visualTheme.Borders, name == "CheckKey" and 1.45 or 2.05)

        return button, stroke
    end

    local checkButton, checkStroke = createActionButton("CheckKey", keyText("check"), UDim2.new(0, 18, 0, 171), UDim2.new(1, -36, 0, 44), visualTheme.Accent)
    local linkButton, linkStroke = createActionButton("GetLink", keyText("link"), UDim2.new(0, 18, 0, 231), UDim2.new(1, -36, 0, 32), visualTheme.Borders[2])
    linkButton.BackgroundTransparency = 0.12
    linkButton.TextColor3 = visualTheme.TextDim
    linkButton.Font = Enum.Font.GothamMedium
    linkButton.TextSize = 9
    linkStroke.Transparency = 0.28

    local checkIcon = Instance.new("ImageLabel")
    checkIcon.BackgroundTransparency = 1
    checkIcon.Image = "rbxassetid://113137557066757"
    checkIcon.ImageColor3 = visualTheme.Text
    checkIcon.Position = UDim2.new(0.5, -96, 0, 184)
    checkIcon.Size = UDim2.fromOffset(18, 18)
    checkIcon.ZIndex = 5
    checkIcon.Parent = content

    local linkIcon = Instance.new("ImageLabel")
    linkIcon.BackgroundTransparency = 1
    linkIcon.Image = "rbxassetid://125248903248905"
    linkIcon.ImageColor3 = visualTheme.TextDim
    linkIcon.ImageTransparency = 0.05
    linkIcon.Position = UDim2.new(0.5, -92, 0, 238)
    linkIcon.Size = UDim2.fromOffset(18, 18)
    linkIcon.ZIndex = 5
    linkIcon.Parent = content

    local status = Instance.new("TextLabel")
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.GothamMedium
    status.Text = keyText("secure")
    status.TextColor3 = visualTheme.TextDim
    status.TextSize = 8
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Position = UDim2.new(0, 47, 0, 270)
    status.Size = UDim2.new(1, -64, 0, 16)
    status.ZIndex = 4
    status.Parent = content

    local alertIcon = Instance.new("ImageLabel")
    alertIcon.BackgroundTransparency = 1
    alertIcon.Image = "rbxassetid://140207627533370"
    alertIcon.ImageColor3 = visualTheme.TextDim
    alertIcon.Position = UDim2.new(0, 21, 0, 268)
    alertIcon.Size = UDim2.fromOffset(14, 14)
    alertIcon.ZIndex = 5
    alertIcon.Parent = content


    local authorized = false
    local closed = false
    local busy = false
    local currentStatusKind = "secure"

    local function renderKeyStatus(kind)
        if kind == "secure" then return keyText("secure") end
        if kind == "revalidating" then return keyText("revalidating") end
        if kind == "contacting" then return keyText("contacting") end
        if kind == "accepted" then return "✓ " .. keyText("accepted") .. " — " .. keyText("loading") end
        if kind == "link_copied" then return keyText("link_copied") .. " — " .. KEY_PORTAL_URL end
        if kind == "portal" then return keyText("portal") .. ": " .. KEY_PORTAL_URL end
        if kind == "no_file_support" then return keyText("no_file_support") end
        if kind == "invalid_format" then return "✕ " .. keyText("invalid_format") end
        if kind == "server_unavailable" then return "✕ " .. keyText("server_unavailable") end
        if kind == "invalid_response" then return "✕ " .. keyText("invalid_response") end
        if kind == "invalid_expired" then return "✕ " .. keyText("invalid_expired") end
        if kind == "invalid_expired_removed" then return "✕ " .. keyText("invalid_expired") .. " — " .. keyText("saved_removed") end
        return keyText("secure")
    end

    local function setKeyStatus(kind, color)
        currentStatusKind = kind
        status.Text = renderKeyStatus(kind)
        status.TextColor3 = color
    end

    local function refreshKeyLanguage()
        brandSub.Text = keyText("brand_sub")
        title.Text = keyText("title")
        subtitle.Text = keyText("subtitle")
        if busy then
            checkButton.Text = keyText("checking")
        elseif authorized then
            checkButton.Text = "✓  " .. keyText("access_granted")
        else
            checkButton.Text = keyText("check")
        end
        linkButton.Text = keyText("link")
        status.Text = renderKeyStatus(currentStatusKind)
    end

    local function setKeyLanguageFromLocale(localeId)
        KeyLanguage = getKeyLanguage(localeId)
        refreshKeyLanguage()
    end

    --// Primero usa el locale del sistema para que el idioma aparezca rápidamente.
    pcall(function()
        local systemLocale = LocalizationService.SystemLocaleId
        if systemLocale and systemLocale ~= "" then
            setKeyLanguageFromLocale(systemLocale)
        end
    end)

    --// Roblox recomienda obtener el Translator del jugador y escuchar cambios
    --// de LocaleId para actualizar el contenido localizado durante la sesión.
    task.spawn(function()
        local ok, translator = pcall(function()
            return LocalizationService:GetTranslatorForPlayerAsync(LocalPlayer)
        end)
        if ok and translator then
            local function updateFromTranslator()
                setKeyLanguageFromLocale(translator.LocaleId)
            end
            updateFromTranslator()
            pcall(function()
                translator:GetPropertyChangedSignal("LocaleId"):Connect(updateFromTranslator)
            end)
        end
    end)

    function tryAccess(value, fromCache)
        if busy or closed then
            return
        end

        busy = true
        input.Text = normalizeAccessKey(value)
        checkButton.Text = keyText("checking")
        setKeyStatus(
            fromCache and "revalidating" or "contacting",
            Color3.fromRGB(210, 210, 210)
        )

        local valid, message = validateAccessKey(input.Text)
        if valid then
            saveCachedKey(input.Text)
            authorized = true
            getgenv().EvadeBetaKeyValidated = true
            setKeyStatus("accepted", Color3.fromRGB(235, 235, 235))
            checkButton.Text = "✓  " .. keyText("access_granted")
            checkButton.BackgroundColor3 = Color3.fromRGB(58, 58, 58)
            task.wait(0.7)
            if gui.Parent then
                gui:Destroy()
            end
        else
            local statusKind =
                message == "INVALID FORMAT" and "invalid_format"
                or message == "SERVER UNAVAILABLE" and "server_unavailable"
                or message == "INVALID RESPONSE" and "invalid_response"
                or message == "INVALID OR EXPIRED KEY" and (fromCache and "invalid_expired_removed" or "invalid_expired")
                or "secure"

            if fromCache and message == "INVALID OR EXPIRED KEY" then
                clearCachedKey()
                input.Text = ""
            end

            setKeyStatus(statusKind, Color3.fromRGB(222, 222, 222))
            checkButton.Text = "✓  " .. keyText("check")
            checkButton.BackgroundColor3 = Color3.fromRGB(43, 43, 43)
            task.wait(0.35)
            if checkButton.Parent then
                checkButton.BackgroundColor3 = visualTheme.Header
            end
        end
        busy = false
    end

    for _, data in ipairs({{checkButton, checkStroke}, {linkButton, linkStroke}}) do
        data[1].MouseEnter:Connect(function()
            if not busy then
                setButtonVisual(data[1], data[2], true)
            end
        end)
        data[1].MouseLeave:Connect(function()
            setButtonVisual(data[1], data[2], false)
        end)
    end

    input.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            tryAccess(input.Text, false)
        end
    end)

    linkButton.Activated:Connect(function()
        if setclipboard then
            pcall(setclipboard, KEY_PORTAL_URL)
            setKeyStatus("link_copied", Color3.fromRGB(230, 230, 230))
        else
            setKeyStatus("portal", Color3.fromRGB(230, 230, 230))
        end
    end)

    close.Activated:Connect(function()
        closed = true
        gui:Destroy()
    end)

    checkButton.Activated:Connect(function()
        tryAccess(input.Text, false)
    end)

    local cachedKey = loadCachedKey()
    if cachedKey then
        input.Text = cachedKey
        task.spawn(function()
            task.wait(0.15)
            tryAccess(cachedKey, true)
        end)
    elseif not hasKeyCacheSupport() then
        setKeyStatus("no_file_support", Color3.fromRGB(210, 210, 210))
    end
    while not authorized and not closed do
        task.wait()
    end

    return authorized
end

if not createKeySystemUI() then
    warn("YIN YANG KEY: closed without a valid key")
    return
end

print("\nSERVICES: Initialized successfully")

--// ═════════════════════════════════════════════════════════════════════════════
--// MAIN CONFIGURATION
--// ═════════════════════════════════════════════════════════════════════════════

local Config = {
    --// SPEED MULTIPLIER (WalkSpeed real, distinto de Teleport Walk)
    EnableSpeedMultiplier = false,
    SpeedMultiplierValue = 1,
    
    --// BASIC MOVEMENT
    TeleportMovementSpeed = 5,
    EnableTeleportWalk = false,
    JumpHeight = 50,
    EnableEnhancedJump = false,
    --// INFINITE SLIDE
    EnableInfiniteSlide = false,
    InfiniteSlideSpeed = 30,
    AutoJump = false,
    -- Velocidad expresada en saltos por segundo; evita saltos por cada Heartbeat.
    AutoJumpSpeed = 1.5,
    AutoCrouch = false,
    -- Velocidad expresada en toggles (agachar/parar) por segundo.
    AutoCrouchSpeed = 1.5,
    EnableJumpAcceleration = false,
    JumpAccelerationSpeed = 42,
    
    --// GRAVITY MODIFICATION
    EnableGravityMod = false,
    GravityScale = 0.5,
    
    --// FRONTAL JUMP
    EnableFrontalJump = false,

    --// RAMP MULTIPLIER (independiente de Frontal Jump)
    EnableRampMultiplier = false,
    
    --// BACK JUMP
    EnableBackJump = false,
    BackJumpSpeed = 42,
    
    --// MAP FEATURES
    EnableFullBright = false,
    EnableAutoTicket = false,
    EnableVoidEscape = false,
    EnableAfkMap     = false,
    EnableAntiAfk    = false,
    EnableWhistleESP = false,
    
    --// EXTRA
    EnableReviveAura = false,
    EnableAutoCarry = false,

    --// EMOTE SPEED
    EnableEmoteSpeed = false,
    EmoteSpeedMultiplier = 1.5,

    --// LAYER JUMPS (Multi-Jump via JumpCap interno de Evade)
    EnableLayerJumps = false,
    LayerJumpsCount = 2,

    --// AUTO TRIMP
    EnableAutoTrimp = false,
    AutoTrimpMultiplier = 2.5,
    AutoTrimpFallSpeed = 0.5,
    --// TRIMP + TELEPORT WALK (combinado)
    EnableTrimpTeleport = false,
}

--// Frontal Jump Variables
local camera = Workspace.CurrentCamera
getgenv().FrontalJumpSpeed = 42
getgenv().RampMultiplier = 1.55
getgenv().RampMultiplierValue = 1.55 -- Ramp Multiplier independiente (no comparte valor con Frontal Jump)
local maxExtraSpeed = 80
local currentSpeed = getgenv().FrontalJumpSpeed
local airAccumulator = 0
local lastTick = tick()
local wasAir = false
local activeBV = nil
local lastJumpTime = tick()
local jumpInterval = 0.65
-- Próximo instante permitido para Auto Jump; se conserva fuera del Heartbeat.
local autoJumpNextTime = 0
local autoCrouchNextTime = 0
local rampLocked = false
--// Jump Acceleration comparte estado y motor con Frontal Jump.

--// Back Jump Variables
getgenv().BackJumpSpeed = 42
getgenv().BackRampMultiplier = 0
local backCurrentSpeed = getgenv().BackJumpSpeed
local backAirAccumulator = 0
local backLastTick = tick()
local backWasAir = false
local backActiveBV = nil
local backLastJumpTime = tick()
local backJumpInterval = 0.65
local backRampLocked = false


--// FullBright Variables
local Lighting = game:GetService("Lighting")

local fullBrightState = {
    Enabled = false,
    Connection = nil,
    Original = nil,
}

local fullBrightHooks = {
    SaveSettings = nil,
}

function captureFullBrightState()
    if fullBrightState.Original then
        return
    end

    local ok, snapshot = pcall(function()
        return {
            Brightness = Lighting.Brightness,
            Ambient = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            ColorShift_Bottom = Lighting.ColorShift_Bottom,
            ColorShift_Top = Lighting.ColorShift_Top,
            GlobalShadows = Lighting.GlobalShadows,
            ClockTime = Lighting.ClockTime,
            ExposureCompensation = Lighting.ExposureCompensation,
            FogColor = Lighting.FogColor,
            FogEnd = Lighting.FogEnd,
            FogStart = Lighting.FogStart,
            EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
            EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
        }
    end)

    if ok and snapshot then
        fullBrightState.Original = snapshot
    end
end

function disconnectFullBrightConnection()
    if fullBrightState.Connection then
        pcall(function()
            fullBrightState.Connection:Disconnect()
        end)
        fullBrightState.Connection = nil
    end
end

function restoreFullBrightState()
    local original = fullBrightState.Original
    if not original then
        return
    end

    pcall(function()
        Lighting.Brightness = original.Brightness
        Lighting.Ambient = original.Ambient
        Lighting.OutdoorAmbient = original.OutdoorAmbient
        Lighting.ColorShift_Bottom = original.ColorShift_Bottom
        Lighting.ColorShift_Top = original.ColorShift_Top
        Lighting.GlobalShadows = original.GlobalShadows
        Lighting.ClockTime = original.ClockTime
        Lighting.ExposureCompensation = original.ExposureCompensation
        Lighting.FogColor = original.FogColor
        Lighting.FogEnd = original.FogEnd
        Lighting.FogStart = original.FogStart
        Lighting.EnvironmentDiffuseScale = original.EnvironmentDiffuseScale
        Lighting.EnvironmentSpecularScale = original.EnvironmentSpecularScale
    end)
end

function applyFullBright()
    pcall(function()
        if Lighting.GlobalShadows ~= false then
            Lighting.GlobalShadows = false
        end

        if Lighting.Brightness ~= 1 then
            Lighting.Brightness = 1
        end

        local white = Color3.new(1, 1, 1)
        if Lighting.Ambient ~= white then
            Lighting.Ambient = white
        end
        if Lighting.OutdoorAmbient ~= white then
            Lighting.OutdoorAmbient = white
        end
        if Lighting.ColorShift_Bottom ~= white then
            Lighting.ColorShift_Bottom = white
        end
        if Lighting.ColorShift_Top ~= white then
            Lighting.ColorShift_Top = white
        end

        if Lighting.ClockTime ~= 12 then
            Lighting.ClockTime = 12
        end

        if Lighting.ExposureCompensation ~= 0 then
            Lighting.ExposureCompensation = 0
        end

        if Lighting.FogColor ~= white then
            Lighting.FogColor = white
        end

        if Lighting.FogEnd ~= 1e10 then
            Lighting.FogEnd = 1e10
        end

        if Lighting.FogStart ~= 0 then
            Lighting.FogStart = 0
        end

        if Lighting.EnvironmentDiffuseScale ~= 1 then
            Lighting.EnvironmentDiffuseScale = 1
        end

        if Lighting.EnvironmentSpecularScale ~= 1 then
            Lighting.EnvironmentSpecularScale = 1
        end
    end)
end

function setFullBrightEnabled(state)
    local enabled = state and true or false

    fullBrightState.Enabled = enabled
    Config.EnableFullBright = enabled

    if enabled then
        captureFullBrightState()
        applyFullBright()

        if not fullBrightState.Connection then
            fullBrightState.Connection = RunService.Heartbeat:Connect(function()
                if not fullBrightState.Enabled then
                    return
                end

                applyFullBright()
            end)
        end
    else
        disconnectFullBrightConnection()
        restoreFullBrightState()
    end

    if fullBrightHooks.SaveSettings then
        pcall(function()
            fullBrightHooks.SaveSettings()
        end)
    end
end

--// Variables to save options state

local savedOptions = {
    EnableTeleportWalk = false,
    EnableEnhancedJump = false,
    EnableGravityMod = false,
}

--// ═════════════════════════════════════════════════════════════════════════════
--// SETTINGS SAVE/LOAD SYSTEM
--// ═════════════════════════════════════════════════════════════════════════════

local HttpService = game:GetService("HttpService")
local SettingsFile = "EVADE_V52_Settings.json"

function SaveSettings()
    pcall(function()
        local data = {
            EnableTeleportWalk = Config.EnableTeleportWalk,
            TeleportMovementSpeed = Config.TeleportMovementSpeed,
            EnableEnhancedJump = Config.EnableEnhancedJump,
            JumpHeight = Config.JumpHeight,
            EnableInfiniteSlide = Config.EnableInfiniteSlide,
            InfiniteSlideSpeed = Config.InfiniteSlideSpeed,
            AutoJump = Config.AutoJump,
            AutoJumpSpeed = Config.AutoJumpSpeed,
            AutoCrouch = Config.AutoCrouch,
            AutoCrouchSpeed = Config.AutoCrouchSpeed,
            EnableJumpAcceleration = Config.EnableJumpAcceleration,
            JumpAccelerationSpeed = Config.JumpAccelerationSpeed,
            EnableGravityMod = Config.EnableGravityMod,
            GravityScale = Config.GravityScale,
            EnableFrontalJump = Config.EnableFrontalJump,
            FrontalJumpSpeed = getgenv().FrontalJumpSpeed,
            RampMultiplier = getgenv().RampMultiplier,
            EnableRampMultiplier = Config.EnableRampMultiplier,
            RampMultiplierValue = getgenv().RampMultiplierValue,
            EnableFullBright = Config.EnableFullBright,
            EnableAutoTicket = Config.EnableAutoTicket,
            EnableVoidEscape = Config.EnableVoidEscape,
            EnableAfkMap     = Config.EnableAfkMap,
            EnableAntiAfk    = Config.EnableAntiAfk,
            EnableWhistleESP = Config.EnableWhistleESP,
            EnableReviveAura = Config.EnableReviveAura,
            EnableAutoCarry = Config.EnableAutoCarry,
            EnableAutoTrimp = Config.EnableAutoTrimp,
            AutoTrimpMultiplier = Config.AutoTrimpMultiplier,
            AutoTrimpFallSpeed = Config.AutoTrimpFallSpeed,
            EnableTrimpTeleport = Config.EnableTrimpTeleport,
            EnableSpeedMultiplier = Config.EnableSpeedMultiplier,
            SpeedMultiplierValue = Config.SpeedMultiplierValue,
            EnableEmoteSpeed = Config.EnableEmoteSpeed,
            EmoteSpeedMultiplier = Config.EmoteSpeedMultiplier,
            EnableLayerJumps = Config.EnableLayerJumps,
            LayerJumpsCount = Config.LayerJumpsCount,
            EnableBackJump = Config.EnableBackJump,
            BackJumpSpeed = getgenv().BackJumpSpeed,
            BackRampMultiplier = getgenv().BackRampMultiplier,
        }
        writefile(SettingsFile, HttpService:JSONEncode(data))
    end)
end

function LoadSettings()
    local ok, result = pcall(function()
        if isfile and isfile(SettingsFile) then
            local content = readfile(SettingsFile)
            if content and content ~= "" then
                return HttpService:JSONDecode(content)
            end
        end
        return nil
    end)

    if ok and result then
        if result.EnableTeleportWalk ~= nil then Config.EnableTeleportWalk = result.EnableTeleportWalk end
        if result.TeleportMovementSpeed ~= nil then Config.TeleportMovementSpeed = result.TeleportMovementSpeed end
        if result.EnableEnhancedJump ~= nil then Config.EnableEnhancedJump = result.EnableEnhancedJump end
        if result.JumpHeight ~= nil then Config.JumpHeight = result.JumpHeight end
        if result.EnableInfiniteSlide ~= nil then Config.EnableInfiniteSlide = result.EnableInfiniteSlide end
        if result.InfiniteSlideSpeed ~= nil then Config.InfiniteSlideSpeed = math.clamp(result.InfiniteSlideSpeed, 15, 150) end
        if result.AutoJump ~= nil then Config.AutoJump = result.AutoJump end
        if result.AutoJumpSpeed ~= nil then Config.AutoJumpSpeed = math.clamp(tonumber(result.AutoJumpSpeed) or 1.5, 0.5, 8) end
        if result.AutoCrouch ~= nil then Config.AutoCrouch = result.AutoCrouch end
        if result.AutoCrouchSpeed ~= nil then Config.AutoCrouchSpeed = math.clamp(tonumber(result.AutoCrouchSpeed) or 1.5, 0.5, 24) end
        if result.EnableJumpAcceleration ~= nil then Config.EnableJumpAcceleration = result.EnableJumpAcceleration end
        if result.JumpAccelerationSpeed ~= nil then Config.JumpAccelerationSpeed = math.clamp(tonumber(result.JumpAccelerationSpeed) or 42, 30, 110) end
        if result.EnableGravityMod ~= nil then Config.EnableGravityMod = result.EnableGravityMod end
        if result.GravityScale ~= nil then Config.GravityScale = result.GravityScale end
        if result.EnableFrontalJump ~= nil then Config.EnableFrontalJump = result.EnableFrontalJump end
        if result.FrontalJumpSpeed ~= nil then getgenv().FrontalJumpSpeed = result.FrontalJumpSpeed end
        if result.RampMultiplier ~= nil then getgenv().RampMultiplier = result.RampMultiplier end
        if result.EnableRampMultiplier ~= nil then Config.EnableRampMultiplier = result.EnableRampMultiplier end
        if result.RampMultiplierValue ~= nil then getgenv().RampMultiplierValue = result.RampMultiplierValue end
        if result.EnableFullBright ~= nil then Config.EnableFullBright = result.EnableFullBright end
        if result.EnableAutoTicket ~= nil then Config.EnableAutoTicket = result.EnableAutoTicket end
        if result.EnableVoidEscape ~= nil then Config.EnableVoidEscape = result.EnableVoidEscape end
        if result.EnableAfkMap     ~= nil then Config.EnableAfkMap     = result.EnableAfkMap     end
        if result.EnableAntiAfk    ~= nil then Config.EnableAntiAfk    = result.EnableAntiAfk    end
        if result.EnableWhistleESP ~= nil then Config.EnableWhistleESP = result.EnableWhistleESP end
        if result.EnableReviveAura ~= nil then Config.EnableReviveAura = result.EnableReviveAura end
        if result.EnableAutoCarry ~= nil then Config.EnableAutoCarry = result.EnableAutoCarry end
        if result.EnableAutoTrimp ~= nil then Config.EnableAutoTrimp = result.EnableAutoTrimp end
        if result.AutoTrimpMultiplier ~= nil then Config.AutoTrimpMultiplier = result.AutoTrimpMultiplier end
        if result.AutoTrimpFallSpeed ~= nil then Config.AutoTrimpFallSpeed = result.AutoTrimpFallSpeed end
        if result.EnableTrimpTeleport ~= nil then Config.EnableTrimpTeleport = result.EnableTrimpTeleport end
        if result.EnableSpeedMultiplier ~= nil then Config.EnableSpeedMultiplier = result.EnableSpeedMultiplier end
        if result.SpeedMultiplierValue ~= nil then Config.SpeedMultiplierValue = result.SpeedMultiplierValue end
        if result.EnableEmoteSpeed ~= nil then Config.EnableEmoteSpeed = result.EnableEmoteSpeed end
        if result.EmoteSpeedMultiplier ~= nil then Config.EmoteSpeedMultiplier = result.EmoteSpeedMultiplier end
        if result.EnableLayerJumps ~= nil then Config.EnableLayerJumps = result.EnableLayerJumps end
        if result.LayerJumpsCount ~= nil then Config.LayerJumpsCount = result.LayerJumpsCount end
        if result.EnableBackJump ~= nil then Config.EnableBackJump = result.EnableBackJump end
        if result.BackJumpSpeed ~= nil then getgenv().BackJumpSpeed = result.BackJumpSpeed end
        if result.BackRampMultiplier ~= nil then getgenv().BackRampMultiplier = result.BackRampMultiplier end
        print("SETTINGS: Previous configuration loaded successfully")
    else
        print("SETTINGS: No saved configuration found, using defaults")
    end
end

LoadSettings()

fullBrightHooks.SaveSettings = SaveSettings

--// Resync currentSpeed with the loaded FrontalJumpSpeed value
currentSpeed = Config.EnableJumpAcceleration and Config.JumpAccelerationSpeed or getgenv().FrontalJumpSpeed
--// Resync backCurrentSpeed with the loaded BackJumpSpeed value
backCurrentSpeed = getgenv().BackJumpSpeed

print("CONFIGURATION: Initialized")

--// ═════════════════════════════════════════════════════════════════════════════
--// LOAD YIN YANG v33 FINAL
--// ═════════════════════════════════════════════════════════════════════════════

print("\nLoading Yin Yang v28 Final from GitHub...")

local success = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ZINZEROX/Zin/refs/heads/main/Zin"))()
end)

if not success or not _G.YinYang then
    error("ERROR: Failed to load Yin Yang v28 Final")
    return
end

print("LIBRARY: Yin Yang v28 Final loaded successfully")
task.wait(0.5)

print("SYSTEM: Initialization completed")

--// ═════════════════════════════════════════════════════════════════════════════
--// CREATE UI
--// ═════════════════════════════════════════════════════════════════════════════

print("\nCreating EVADE v5.2 Beta interface...")

--// Read the theme saved by the Yin Yang library itself (Yin_Yang_Config.txt)
--// The library saves the theme correctly on change, but its own CreateWindow
--// never re-applies it on load - so we read the same file here and pass it in.
function GetSavedTheme()
    local theme = "Dark"
    pcall(function()
        if isfile and isfile("Yin_Yang_Config.txt") then
            local content = readfile("Yin_Yang_Config.txt")
            if content and content ~= "" then
                local value = content:match("theme:([^|]+)")
                if value then
                    theme = value
                end
            end
        end
    end)
    return theme
end

local UI = _G.YinYang:CreateWindow("Yin Yang", GetSavedTheme())

--// ═════════════════════════════════════════════════════════════════════════════
--// INVERSE RAINBOW EFFECT FOR TITLE
--// ═════════════════════════════════════════════════════════════════════════════

function setupRainbowInversedTitle()
    local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    task.wait(0.8)
    
    if PlayerGui:FindFirstChild("Yin") then
        local ScreenGui = PlayerGui.Yin
        local TitleLabel = ScreenGui:FindFirstChild("TitleLabel")
        
        if TitleLabel then
            print("Creating inverse rainbow effect with two TextLabels...")
            
            --// Get position and size of the original title
            local origText = TitleLabel.Text
            local origSize = TitleLabel.Size
            local origPos = TitleLabel.Position
            local origFont = TitleLabel.Font
            local origTextSize = TitleLabel.TextSize
            
            --// Make original title invisible
            TitleLabel.TextTransparency = 1
            
            --// Create TextLabel for "EVADE" (White → Black)
            local EvadeLabel = Instance.new("TextLabel")
            EvadeLabel.Name = "EvadeLabel"
            EvadeLabel.Text = "EVADE"
            EvadeLabel.Font = origFont
            EvadeLabel.TextSize = origTextSize
            EvadeLabel.BackgroundTransparency = 1
            EvadeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            EvadeLabel.Size = UDim2.new(0.6, 0, 1, 0)
            EvadeLabel.Position = UDim2.new(0, 0, 0, 0)
            EvadeLabel.TextXAlignment = Enum.TextXAlignment.Left
            EvadeLabel.ZIndex = TitleLabel.ZIndex + 1
            EvadeLabel.Parent = TitleLabel.Parent
            
            --// Create TextLabel for "Beta" (Black → White)
            local BetaLabel = Instance.new("TextLabel")
            BetaLabel.Name = "BetaLabel"
            BetaLabel.Text = "v5.2 Beta"
            BetaLabel.Font = origFont
            BetaLabel.TextSize = origTextSize
            BetaLabel.BackgroundTransparency = 1
            BetaLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
            BetaLabel.Size = UDim2.new(0.4, 0, 1, 0)
            BetaLabel.Position = UDim2.new(0.6, 0, 0, 0)
            BetaLabel.TextXAlignment = Enum.TextXAlignment.Left
            BetaLabel.ZIndex = TitleLabel.ZIndex + 1
            BetaLabel.Parent = TitleLabel.Parent
            
            print("✅ Labels created: EvadeLabel + BetaLabel")
            
            --// Animate INVERSE colors
            local cycleCount = 0
            local rainbow = RunService.RenderStepped:Connect(function()
                if not EvadeLabel or not EvadeLabel.Parent or not BetaLabel or not BetaLabel.Parent then
                    rainbow:Disconnect()
                    return
                end
                
                cycleCount = cycleCount + 1
                local progress = (cycleCount % 120) / 120
                
                if progress < 0.5 then
                    local t = progress * 2
                    
                    local evadeBrightness = 1 - t
                    EvadeLabel.TextColor3 = Color3.fromRGB(
                        math.floor(255 * evadeBrightness),
                        math.floor(255 * evadeBrightness),
                        math.floor(255 * evadeBrightness)
                    )
                    
                    local betaBrightness = t
                    BetaLabel.TextColor3 = Color3.fromRGB(
                        math.floor(255 * betaBrightness),
                        math.floor(255 * betaBrightness),
                        math.floor(255 * betaBrightness)
                    )
                else
                    local t = (progress - 0.5) * 2
                    
                    local evadeBrightness = t
                    EvadeLabel.TextColor3 = Color3.fromRGB(
                        math.floor(255 * evadeBrightness),
                        math.floor(255 * evadeBrightness),
                        math.floor(255 * evadeBrightness)
                    )
                    
                    local betaBrightness = 1 - t
                    BetaLabel.TextColor3 = Color3.fromRGB(
                        math.floor(255 * betaBrightness),
                        math.floor(255 * betaBrightness),
                        math.floor(255 * betaBrightness)
                    )
                end
            end)
            
            print("✅ Inverse rainbow effect activated")
        end
    end
end

task.delay(1, setupRainbowInversedTitle)

--// ════════════════════════════════════════════════════════════════════════════
--// ═════════════════════════════════════════════════════════════════════════════
--// SCRIPT UI LANGUAGE — detección automática del idioma del jugador
--// Usa LocalizationService/GetTranslatorForPlayerAsync, sin configuración manual.
--// Español e inglés usan los textos fuente del script; otros locales intentan
--// traducirse mediante el Translator disponible y usan inglés como fallback.
--// ═════════════════════════════════════════════════════════════════════════════
local ScriptLanguage = "en"
local ScriptTranslator = nil
local ScriptTranslationCache = {}

local function getScriptLanguage(localeId)
    local language = string.lower(tostring(localeId or "en")):match("^(%a+)") or "en"
    return language
end

local function scriptText(spanishText, englishText)
    spanishText = tostring(spanishText or "")
    englishText = tostring(englishText or spanishText)

    if ScriptLanguage == "es" then
        return spanishText
    end
    if ScriptLanguage == "en" then
        return englishText
    end

    local cacheKey = ScriptLanguage .. "\0" .. englishText
    if ScriptTranslationCache[cacheKey] ~= nil then
        return ScriptTranslationCache[cacheKey]
    end

    local translated = nil
    if ScriptTranslator then
        pcall(function()
            translated = ScriptTranslator:Translate(game, englishText)
        end)
    end

    if translated and translated ~= "" and translated ~= englishText then
        ScriptTranslationCache[cacheKey] = translated
        return translated
    end

    ScriptTranslationCache[cacheKey] = englishText
    return englishText
end

local function refreshScriptLanguage()
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    local screenGui = playerGui and playerGui:FindFirstChild("Yin")
    if not screenGui then
        return
    end

    for _, object in ipairs(screenGui:GetDescendants()) do
        if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
            local spanishText = object:GetAttribute("TextSpanish")
            local englishText = object:GetAttribute("TextEnglish")
            if spanishText ~= nil and englishText ~= nil then
                object.Text = scriptText(spanishText, englishText)
            end

            local placeholderSpanish = object:GetAttribute("PlaceholderSpanish")
            local placeholderEnglish = object:GetAttribute("PlaceholderEnglish")
            if placeholderSpanish ~= nil and placeholderEnglish ~= nil then
                object.PlaceholderText = scriptText(placeholderSpanish, placeholderEnglish)
            end
        end
    end
end

local function setScriptLanguageFromLocale(localeId)
    ScriptLanguage = getScriptLanguage(localeId)
    ScriptTranslationCache = {}
    refreshScriptLanguage()
end

--// Primero aplica el locale del sistema para que la UI tenga el idioma correcto
--// desde el inicio.
pcall(function()
    local systemLocale = LocalizationService.SystemLocaleId
    if systemLocale and systemLocale ~= "" then
        setScriptLanguageFromLocale(systemLocale)
    end
end)

--// Después usa el Translator del jugador y escucha cambios de LocaleId.
task.spawn(function()
    local ok, translator = pcall(function()
        return LocalizationService:GetTranslatorForPlayerAsync(LocalPlayer)
    end)

    if ok and translator then
        ScriptTranslator = translator

        local function updateScriptLanguage()
            setScriptLanguageFromLocale(translator.LocaleId)
        end

        updateScriptLanguage()
        pcall(function()
            translator:GetPropertyChangedSignal("LocaleId"):Connect(updateScriptLanguage)
        end)
    end
end)

--// CREATE TABS
--// ════════════════════════════════════════════════════════════════════════════

local TabMove = UI:CreateTab("Move", "rbxassetid://127654592832194")

--// ⚠️ NO ELIMINAR — Crea la pestaña Spotify en esta UI
--// Descarga el catálogo desde GitHub y renderiza las canciones automáticamente
UI:CreateSpotifyTab()

print("TABS: Created (Move with Auto Parry)")

--// ═════════════════════════════════════════════════════════════════════════════
--// TAB: MOVE — SPAM WITH TOGGLE
--// ═════════════════════════════════════════════════════════════════════════════

local AP_spamConnection = nil

-- Services
local APLocalPlayer = Players.LocalPlayer
local APButton = APLocalPlayer.PlayerGui.Hotbar.Block
local APmb1up = APButton.MouseButton1Up
local APgfs = type(firesignal) == "function" and firesignal or type(getconnections) == "function" and getconnections
local APuseFiresignal = APgfs == firesignal

if not APgfs then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Error",
        Text = "Your executor is not supported",
        Duration = 5,
    })
end

local function APfireMB1Up()
    if APuseFiresignal then
        APgfs(APmb1up)
    else
        for _, c in APgfs(APmb1up) do c:Fire() end
    end
end

-- UI Toggle para Spam
TabMove:CreateFloatingToggle("Spam", "Spam", false, function(state)
    if state then
        AP_spamConnection = RunService.Heartbeat:Connect(function()
            APfireMB1Up()
        end)
    else
        if AP_spamConnection then
            AP_spamConnection:Disconnect()
            AP_spamConnection = nil
        end
    end
end)

--// Normaliza todo el texto creado por las pestañas con el idioma detectado.
refreshScriptLanguage()

return UI
