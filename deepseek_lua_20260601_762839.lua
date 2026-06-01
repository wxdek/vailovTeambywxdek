local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Главный GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BeautifulESP"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999

-- ЗВУК
local NotifySound = Instance.new("Sound")
NotifySound.SoundId = "rbxassetid://140650479009173"
NotifySound.Volume = 1.0
NotifySound.Parent = ScreenGui

-- Хранилище обводок
local animatedStrokes = {}
RunService.RenderStepped:Connect(function()
    local time = tick()
    for stroke, _ in pairs(animatedStrokes) do
        if stroke and stroke.Parent then
            stroke.Color = Color3.fromHSV(0.78 + math.sin(time * 3) * 0.07, 0.8, 1)
        else
            animatedStrokes[stroke] = nil
        end
    end
end)

-- Уведомления
local activeNotifications = {}
local function ShowNotification(text, duration)
    duration = duration or 5
    local Notif = Instance.new("Frame")
    Notif.Size = UDim2.new(0, 0, 0, 50)
    Notif.Position = UDim2.new(1, 0, 0.05 + (#activeNotifications * 0.08), 0)
    Notif.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Notif.BackgroundTransparency = 0.3
    Notif.BorderSizePixel = 0
    Notif.ZIndex = 1000
    Notif.Parent = ScreenGui
    Instance.new("UICorner", Notif).CornerRadius = UDim.new(0, 12)
    local ns = Instance.new("UIStroke", Notif)
    ns.Color = Color3.fromRGB(200, 50, 255); ns.Thickness = 2; ns.Transparency = 0.3
    ns.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; ns.ZIndex = 1000
    animatedStrokes[ns] = true
    local nt = Instance.new("TextLabel", Notif)
    nt.Size = UDim2.new(1, -20, 1, 0); nt.Position = UDim2.new(0, 10, 0, 0)
    nt.BackgroundTransparency = 1; nt.Text = text; nt.TextColor3 = Color3.new(1, 1, 1)
    nt.Font = Enum.Font.GothamBold; nt.TextSize = 14; nt.TextXAlignment = Enum.TextXAlignment.Left
    nt.TextWrapped = true; nt.ZIndex = 1000
    local ts = game:GetService("TextService"):GetTextSize(text, 14, Enum.Font.GothamBold, Vector2.new(10000, 50))
    local nw = math.min(ts.X + 40, 350)
    table.insert(activeNotifications, Notif)
    NotifySound:Play()
    TweenService:Create(Notif, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, nw, 0, 50),
        Position = UDim2.new(1, -nw - 10, 0.05 + ((#activeNotifications - 1) * 0.08), 0)
    }):Play()
    task.delay(duration, function()
        pcall(function()
            TweenService:Create(Notif, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 50),
                Position = UDim2.new(1, 0, 0.05 + ((#activeNotifications - 1) * 0.08), 0)
            }):Play()
            task.wait(0.5)
            for i, n in pairs(activeNotifications) do if n == Notif then table.remove(activeNotifications, i) break end end
            animatedStrokes[ns] = nil; Notif:Destroy()
        end)
    end)
end
task.delay(0.7, function() ShowNotification("Приятной игры с Vailov!", 7) end)

-- ФУНКЦИЯ ПОКАЗА ПОДСКАЗКИ
local currentTooltip = nil
local currentTooltipClose = nil

local function HideTooltip()
    if currentTooltip then
        TweenService:Create(currentTooltip, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        task.wait(0.15)
        if currentTooltip then currentTooltip:Destroy(); currentTooltip = nil end
        currentTooltipClose = nil
    end
end

local function ShowTooltip(text, position, helpButton)
    if currentTooltip and currentTooltipClose == helpButton then
        HideTooltip()
        return
    end
    HideTooltip()
    local Tooltip = Instance.new("Frame")
    Tooltip.Size = UDim2.new(0, 0, 0, 0)
    Tooltip.Position = position
    Tooltip.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Tooltip.BackgroundTransparency = 0.2
    Tooltip.BorderSizePixel = 0
    Tooltip.ZIndex = 200
    Tooltip.Parent = ScreenGui
    Instance.new("UICorner", Tooltip).CornerRadius = UDim.new(0, 8)
    local TooltipStroke = Instance.new("UIStroke", Tooltip)
    TooltipStroke.Color = Color3.fromRGB(170, 0, 255)
    TooltipStroke.Thickness = 1; TooltipStroke.Transparency = 0.5; TooltipStroke.ZIndex = 200
    local TooltipText = Instance.new("TextLabel", Tooltip)
    TooltipText.Size = UDim2.new(1, -16, 1, -10); TooltipText.Position = UDim2.new(0, 8, 0, 5)
    TooltipText.BackgroundTransparency = 1; TooltipText.Text = text
    TooltipText.TextColor3 = Color3.new(1, 1, 1); TooltipText.Font = Enum.Font.Gotham
    TooltipText.TextSize = 12; TooltipText.TextWrapped = true
    TooltipText.TextXAlignment = Enum.TextXAlignment.Left; TooltipText.ZIndex = 200
    local textSize = game:GetService("TextService"):GetTextSize(text, 12, Enum.Font.Gotham, Vector2.new(200, 1000))
    local tw = math.min(textSize.X + 20, 220); local th = textSize.Y + 15
    TweenService:Create(Tooltip, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, tw, 0, th)
    }):Play()
    currentTooltip = Tooltip; currentTooltipClose = helpButton
end

-- КОНСТАНТЫ
local BASE_W, BASE_H = 280, 480
local DEFAULT_SIZE = UDim2.new(0, BASE_W, 0, BASE_H)
local DEFAULT_POS = UDim2.new(0.5, -BASE_W/2, 0.5, -BASE_H/2)

-- КОНТЕЙНЕР СКРОЛЛА
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, 0, 1, -35)
ScrollFrame.Position = UDim2.new(0, 0, 0, 35)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(170, 0, 255)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 550)
ScrollFrame.VerticalScrollBarInset = Enum.ScrollBarInset.Always
ScrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y

-- ВНУТРЕННИЙ ФРЕЙМ
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, 0)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = ScrollFrame

-- ПАНЕЛЬ
local Panel = Instance.new("Frame")
Panel.Size = DEFAULT_SIZE; Panel.Position = DEFAULT_POS
Panel.BackgroundColor3 = Color3.fromRGB(10, 10, 10); Panel.BackgroundTransparency = 0.15
Panel.BorderSizePixel = 0; Panel.Active = true; Panel.Draggable = true; Panel.Parent = ScreenGui
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 16)
ScrollFrame.Parent = Panel

local PanelStroke = Instance.new("UIStroke", Panel)
PanelStroke.Color = Color3.fromRGB(200, 50, 255); PanelStroke.Thickness = 3
PanelStroke.Transparency = 0.3; PanelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
animatedStrokes[PanelStroke] = true

-- ГРИПЫ
local function Grip(s, p)
    local g = Instance.new("TextButton", Panel)
    g.Size = s; g.Position = p; g.BackgroundTransparency = 1; g.Text = ""; g.Visible = false
    return g
end
local LG = Grip(UDim2.new(0, 30, 1, 0), UDim2.new(0, -15, 0, 0))
local RG = Grip(UDim2.new(0, 30, 1, 0), UDim2.new(1, -15, 0, 0))
local TG = Grip(UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, -15))
local BG = Grip(UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 1, -15))
local TLG = Grip(UDim2.new(0, 30, 0, 30), UDim2.new(0, -15, 0, -15))
local TRG = Grip(UDim2.new(0, 30, 0, 30), UDim2.new(1, -15, 0, -15))
local BLG = Grip(UDim2.new(0, 30, 0, 30), UDim2.new(0, -15, 1, -15))
local BRG = Grip(UDim2.new(0, 30, 0, 30), UDim2.new(1, -15, 1, -15))

-- ЗАГОЛОВОК
local TF = Instance.new("Frame", Panel)
TF.Size = UDim2.new(1, 0, 0, 35); TF.BackgroundColor3 = Color3.fromRGB(70, 70, 70); TF.BorderSizePixel = 0
Instance.new("UICorner", TF).CornerRadius = UDim.new(0, 16)
local BC = Instance.new("Frame", TF)
BC.Size = UDim2.new(1, 0, 0.5, 0); BC.Position = UDim2.new(0, 0, 0.5, 0)
BC.BackgroundColor3 = Color3.fromRGB(70, 70, 70); BC.BorderSizePixel = 0
local TT = Instance.new("TextLabel", TF)
TT.Size = UDim2.new(1, 0, 1, 0); TT.Position = UDim2.new(0, 10, 0, 0); TT.BackgroundTransparency = 1
TT.Text = "✨ vailov team"; TT.TextColor3 = Color3.new(1, 1, 1)
TT.Font = Enum.Font.GothamBold; TT.TextSize = 16; TT.TextXAlignment = Enum.TextXAlignment.Left

-- КНОПКИ ЗАГОЛОВКА
local function Btn(text, pos, parent)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0, 26, 0, 26); b.Position = pos
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 20); b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1); b.Font = Enum.Font.GothamBold
    b.TextSize = 14; b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
    return b
end
local SetBtn = Btn("⚙", UDim2.new(1, -83, 0, 4), Panel)
local MinBtn = Btn("—", UDim2.new(1, -55, 0, 4), Panel)
MinBtn.TextSize = 16
local ClsBtn = Btn("X", UDim2.new(1, -27, 0, 4), Panel)

-- МЕНЮ НАСТРОЕК
local SM = Instance.new("Frame", ScreenGui)
SM.Size = UDim2.new(0, 0, 0, 0); SM.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
SM.BackgroundTransparency = 0.1; SM.BorderSizePixel = 0; SM.Visible = false
SM.Active = true; SM.Draggable = true; SM.ZIndex = 50
Instance.new("UICorner", SM).CornerRadius = UDim.new(0, 16)
local SMS = Instance.new("UIStroke", SM)
SMS.Color = Color3.fromRGB(200, 50, 255); SMS.Thickness = 2; SMS.Transparency = 0.3
SMS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
animatedStrokes[SMS] = true

local STF = Instance.new("Frame", SM)
STF.Size = UDim2.new(1, 0, 0, 35); STF.BackgroundColor3 = Color3.fromRGB(70, 70, 70); STF.BorderSizePixel = 0
Instance.new("UICorner", STF).CornerRadius = UDim.new(0, 16)
local SBC = Instance.new("Frame", STF)
SBC.Size = UDim2.new(1, 0, 0.5, 0); SBC.Position = UDim2.new(0, 0, 0.5, 0)
SBC.BackgroundColor3 = Color3.fromRGB(70, 70, 70); SBC.BorderSizePixel = 0
local STT = Instance.new("TextLabel", STF)
STT.Size = UDim2.new(1, -40, 1, 0); STT.Position = UDim2.new(0, 10, 0, 0)
STT.BackgroundTransparency = 1; STT.Text = "⚙ Настройки"; STT.TextColor3 = Color3.new(1, 1, 1)
STT.Font = Enum.Font.GothamBold; STT.TextSize = 16; STT.TextXAlignment = Enum.TextXAlignment.Left
local SCB = Btn("X", UDim2.new(1, -27, 0, 4), SM)

-- НАСТРОЙКИ
local ResizeBtn = Instance.new("TextButton", SM)
ResizeBtn.Size = UDim2.new(0, 24, 0, 24); ResizeBtn.Position = UDim2.new(0.06, 0, 0.30, 0)
ResizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); ResizeBtn.Text = "X"
ResizeBtn.TextColor3 = Color3.new(1, 1, 1); ResizeBtn.Font = Enum.Font.GothamBold
ResizeBtn.TextSize = 14; ResizeBtn.AutoButtonColor = false
Instance.new("UICorner", ResizeBtn).CornerRadius = UDim.new(0, 6)

local ResizeLabel = Instance.new("TextLabel", SM)
ResizeLabel.Size = UDim2.new(0, 160, 0, 24); ResizeLabel.Position = UDim2.new(0.22, 0, 0.30, 0)
ResizeLabel.BackgroundTransparency = 1; ResizeLabel.Text = "Изменить размер панели"
ResizeLabel.TextColor3 = Color3.new(1, 1, 1); ResizeLabel.Font = Enum.Font.Gotham
ResizeLabel.TextSize = 13; ResizeLabel.TextXAlignment = Enum.TextXAlignment.Left

local ResizeHelp = Instance.new("TextButton", SM)
ResizeHelp.Size = UDim2.new(0, 18, 0, 18); ResizeHelp.Position = UDim2.new(0.92, 0, 0.30, 3)
ResizeHelp.BackgroundColor3 = Color3.fromRGB(100, 100, 100); ResizeHelp.Text = "?"
ResizeHelp.TextColor3 = Color3.new(1, 1, 1); ResizeHelp.Font = Enum.Font.GothamBold
ResizeHelp.TextSize = 12; ResizeHelp.AutoButtonColor = false
Instance.new("UICorner", ResizeHelp).CornerRadius = UDim.new(1, 0)

ResizeHelp.MouseButton1Click:Connect(function()
    local pos = UDim2.new(0, ResizeHelp.AbsolutePosition.X - 100, 0, ResizeHelp.AbsolutePosition.Y + 25)
    ShowTooltip("Включает режим изменения размера панели. Потяните за контур.", pos, ResizeHelp)
end)

-- ГОРЯЧАЯ КЛАВИША
local KeybindBtn = Instance.new("TextButton", SM)
KeybindBtn.Size = UDim2.new(0, 80, 0, 24); KeybindBtn.Position = UDim2.new(0.06, 0, 0.50, 0)
KeybindBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); KeybindBtn.Text = "P"
KeybindBtn.TextColor3 = Color3.new(1, 1, 1); KeybindBtn.Font = Enum.Font.GothamBold
KeybindBtn.TextSize = 13; KeybindBtn.AutoButtonColor = false
Instance.new("UICorner", KeybindBtn).CornerRadius = UDim.new(0, 6)

local KeybindLabel = Instance.new("TextLabel", SM)
KeybindLabel.Size = UDim2.new(0, 130, 0, 24); KeybindLabel.Position = UDim2.new(0.42, 0, 0.50, 0)
KeybindLabel.BackgroundTransparency = 1; KeybindLabel.Text = "Горячая клавиша"
KeybindLabel.TextColor3 = Color3.new(1, 1, 1); KeybindLabel.Font = Enum.Font.Gotham
KeybindLabel.TextSize = 13; KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left

local KeybindHelp = Instance.new("TextButton", SM)
KeybindHelp.Size = UDim2.new(0, 18, 0, 18); KeybindHelp.Position = UDim2.new(0.92, 0, 0.50, 3)
KeybindHelp.BackgroundColor3 = Color3.fromRGB(100, 100, 100); KeybindHelp.Text = "?"
KeybindHelp.TextColor3 = Color3.new(1, 1, 1); KeybindHelp.Font = Enum.Font.GothamBold
KeybindHelp.TextSize = 12; KeybindHelp.AutoButtonColor = false
Instance.new("UICorner", KeybindHelp).CornerRadius = UDim.new(1, 0)

KeybindHelp.MouseButton1Click:Connect(function()
    local pos = UDim2.new(0, KeybindHelp.AbsolutePosition.X - 100, 0, KeybindHelp.AbsolutePosition.Y + 25)
    ShowTooltip("Нажмите на кнопку с буквой, затем нажмите нужную клавишу.", pos, KeybindHelp)
end)

local ResetBtn = Instance.new("TextButton", SM)
ResetBtn.Size = UDim2.new(0, 24, 0, 24); ResetBtn.Position = UDim2.new(0.06, 0, 0.70, 0)
ResetBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); ResetBtn.Text = "X"
ResetBtn.TextColor3 = Color3.new(1, 1, 1); ResetBtn.Font = Enum.Font.GothamBold
ResetBtn.TextSize = 14; ResetBtn.AutoButtonColor = false
Instance.new("UICorner", ResetBtn).CornerRadius = UDim.new(0, 6)

local ResetLabel = Instance.new("TextLabel", SM)
ResetLabel.Size = UDim2.new(0, 160, 0, 24); ResetLabel.Position = UDim2.new(0.22, 0, 0.70, 0)
ResetLabel.BackgroundTransparency = 1; ResetLabel.Text = "Вернуть в исходное состояние"
ResetLabel.TextColor3 = Color3.new(1, 1, 1); ResetLabel.Font = Enum.Font.Gotham
ResetLabel.TextSize = 13; ResetLabel.TextXAlignment = Enum.TextXAlignment.Left

local ResetHelp = Instance.new("TextButton", SM)
ResetHelp.Size = UDim2.new(0, 18, 0, 18); ResetHelp.Position = UDim2.new(0.92, 0, 0.70, 3)
ResetHelp.BackgroundColor3 = Color3.fromRGB(100, 100, 100); ResetHelp.Text = "?"
ResetHelp.TextColor3 = Color3.new(1, 1, 1); ResetHelp.Font = Enum.Font.GothamBold
ResetHelp.TextSize = 12; ResetHelp.AutoButtonColor = false
Instance.new("UICorner", ResetHelp).CornerRadius = UDim.new(1, 0)

ResetHelp.MouseButton1Click:Connect(function()
    local pos = UDim2.new(0, ResetHelp.AbsolutePosition.X - 100, 0, ResetHelp.AbsolutePosition.Y + 25)
    ShowTooltip("Сбрасывает панель до исходного размера и положения.", pos, ResetHelp)
end)

local SDiv = Instance.new("Frame", SM)
SDiv.Size = UDim2.new(1, -20, 0, 1); SDiv.Position = UDim2.new(0, 10, 0, 62)
SDiv.BackgroundColor3 = Color3.fromRGB(100, 100, 100); SDiv.BackgroundTransparency = 0.7; SDiv.BorderSizePixel = 0

-- ========== КОНТЕНТ (ВСЕ ПОЗИЦИИ В ПИКСЕЛЯХ) ==========

local y = 5

-- ЗАГОЛОВОК ESP
local EspTitle = Instance.new("TextLabel", ContentFrame)
EspTitle.Size = UDim2.new(0, 100, 0, 20); EspTitle.Position = UDim2.new(0, 15, 0, y)
EspTitle.BackgroundTransparency = 1; EspTitle.Text = "👁 ESP"
EspTitle.TextColor3 = Color3.fromRGB(170, 0, 255); EspTitle.Font = Enum.Font.GothamBold
EspTitle.TextSize = 14; EspTitle.TextXAlignment = Enum.TextXAlignment.Left

y = 30
-- ЧЕКБОКС ESP
local ESPBtn = Instance.new("TextButton", ContentFrame)
ESPBtn.Size = UDim2.new(0, 24, 0, 24); ESPBtn.Position = UDim2.new(0, 15, 0, y)
ESPBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 255); ESPBtn.Text = "✓"
ESPBtn.TextColor3 = Color3.new(1, 1, 1); ESPBtn.Font = Enum.Font.GothamBold; ESPBtn.TextSize = 14
Instance.new("UICorner", ESPBtn).CornerRadius = UDim.new(0, 6)

local ESPLabel = Instance.new("TextLabel", ContentFrame)
ESPLabel.Size = UDim2.new(0, 140, 0, 24); ESPLabel.Position = UDim2.new(0, 55, 0, y)
ESPLabel.BackgroundTransparency = 1; ESPLabel.Text = "Включить ESP"
ESPLabel.TextColor3 = Color3.new(1, 1, 1); ESPLabel.Font = Enum.Font.Gotham
ESPLabel.TextSize = 13; ESPLabel.TextXAlignment = Enum.TextXAlignment.Left

local ESPHelp = Instance.new("TextButton", ContentFrame)
ESPHelp.Size = UDim2.new(0, 18, 0, 18); ESPHelp.Position = UDim2.new(0, 210, 0, y + 3)
ESPHelp.BackgroundColor3 = Color3.fromRGB(100, 100, 100); ESPHelp.Text = "?"
ESPHelp.TextColor3 = Color3.new(1, 1, 1); ESPHelp.Font = Enum.Font.GothamBold
ESPHelp.TextSize = 12; ESPHelp.AutoButtonColor = false
Instance.new("UICorner", ESPHelp).CornerRadius = UDim.new(1, 0)
ESPHelp.MouseButton1Click:Connect(function()
    local pos = UDim2.new(0, ESPHelp.AbsolutePosition.X - 100, 0, ESPHelp.AbsolutePosition.Y + 25)
    ShowTooltip("Включает или отключает ESP (подсветку игроков).", pos, ESPHelp)
end)

y = 65
-- ЧЕКБОКС ТОЛЬКО ВИДИМЫЕ
local VisBtn = Instance.new("TextButton", ContentFrame)
VisBtn.Size = UDim2.new(0, 24, 0, 24); VisBtn.Position = UDim2.new(0, 15, 0, y)
VisBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 255); VisBtn.Text = "✓"
VisBtn.TextColor3 = Color3.new(1, 1, 1); VisBtn.Font = Enum.Font.GothamBold; VisBtn.TextSize = 14
Instance.new("UICorner", VisBtn).CornerRadius = UDim.new(0, 6)

local VisLabel = Instance.new("TextLabel", ContentFrame)
VisLabel.Size = UDim2.new(0, 140, 0, 24); VisLabel.Position = UDim2.new(0, 55, 0, y)
VisLabel.BackgroundTransparency = 1; VisLabel.Text = "Только видимые"
VisLabel.TextColor3 = Color3.new(1, 1, 1); VisLabel.Font = Enum.Font.Gotham
VisLabel.TextSize = 13; VisLabel.TextXAlignment = Enum.TextXAlignment.Left

local VisHelp = Instance.new("TextButton", ContentFrame)
VisHelp.Size = UDim2.new(0, 18, 0, 18); VisHelp.Position = UDim2.new(0, 210, 0, y + 3)
VisHelp.BackgroundColor3 = Color3.fromRGB(100, 100, 100); VisHelp.Text = "?"
VisHelp.TextColor3 = Color3.new(1, 1, 1); VisHelp.Font = Enum.Font.GothamBold
VisHelp.TextSize = 12; VisHelp.AutoButtonColor = false
Instance.new("UICorner", VisHelp).CornerRadius = UDim.new(1, 0)
VisHelp.MouseButton1Click:Connect(function()
    local pos = UDim2.new(0, VisHelp.AbsolutePosition.X - 100, 0, VisHelp.AbsolutePosition.Y + 25)
    ShowTooltip("Показывает только игроков в зоне прямой видимости.", pos, VisHelp)
end)

y = 100
-- ЧЕКБОКС ГРАДИЕНТНАЯ ПОДСВЕТКА
local GradientESPBtn = Instance.new("TextButton", ContentFrame)
GradientESPBtn.Size = UDim2.new(0, 24, 0, 24); GradientESPBtn.Position = UDim2.new(0, 15, 0, y)
GradientESPBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); GradientESPBtn.Text = "X"
GradientESPBtn.TextColor3 = Color3.new(1, 1, 1); GradientESPBtn.Font = Enum.Font.GothamBold; GradientESPBtn.TextSize = 14
GradientESPBtn.AutoButtonColor = false
Instance.new("UICorner", GradientESPBtn).CornerRadius = UDim.new(0, 6)

local GradientESPLabel = Instance.new("TextLabel", ContentFrame)
GradientESPLabel.Size = UDim2.new(0, 210, 0, 24); GradientESPLabel.Position = UDim2.new(0, 55, 0, y)
GradientESPLabel.BackgroundTransparency = 1; GradientESPLabel.Text = "Сменить подсветку на аним. градиент"
GradientESPLabel.TextColor3 = Color3.new(1, 1, 1); GradientESPLabel.Font = Enum.Font.Gotham
GradientESPLabel.TextSize = 12; GradientESPLabel.TextXAlignment = Enum.TextXAlignment.Left

local GradientESPHelp = Instance.new("TextButton", ContentFrame)
GradientESPHelp.Size = UDim2.new(0, 18, 0, 18); GradientESPHelp.Position = UDim2.new(0, 240, 0, y + 3)
GradientESPHelp.BackgroundColor3 = Color3.fromRGB(100, 100, 100); GradientESPHelp.Text = "?"
GradientESPHelp.TextColor3 = Color3.new(1, 1, 1); GradientESPHelp.Font = Enum.Font.GothamBold
GradientESPHelp.TextSize = 12; GradientESPHelp.AutoButtonColor = false
Instance.new("UICorner", GradientESPHelp).CornerRadius = UDim.new(1, 0)
GradientESPHelp.MouseButton1Click:Connect(function()
    local pos = UDim2.new(0, GradientESPHelp.AbsolutePosition.X - 100, 0, GradientESPHelp.AbsolutePosition.Y + 25)
    ShowTooltip("Меняет обычную фиолетовую подсветку игроков на анимированную градиентную фиолетово-розовую.", pos, GradientESPHelp)
end)

y = 135
-- ЧЕКБОКС ВИДЕТЬ ТЕМЫ
local ShowTeamBtn = Instance.new("TextButton", ContentFrame)
ShowTeamBtn.Size = UDim2.new(0, 24, 0, 24); ShowTeamBtn.Position = UDim2.new(0, 15, 0, y)
ShowTeamBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); ShowTeamBtn.Text = "X"
ShowTeamBtn.TextColor3 = Color3.new(1, 1, 1); ShowTeamBtn.Font = Enum.Font.GothamBold; ShowTeamBtn.TextSize = 14
ShowTeamBtn.AutoButtonColor = false
Instance.new("UICorner", ShowTeamBtn).CornerRadius = UDim.new(0, 6)

local ShowTeamLabel = Instance.new("TextLabel", ContentFrame)
ShowTeamLabel.Size = UDim2.new(0, 140, 0, 24); ShowTeamLabel.Position = UDim2.new(0, 55, 0, y)
ShowTeamLabel.BackgroundTransparency = 1; ShowTeamLabel.Text = "Видеть темы"
ShowTeamLabel.TextColor3 = Color3.new(1, 1, 1); ShowTeamLabel.Font = Enum.Font.Gotham
ShowTeamLabel.TextSize = 13; ShowTeamLabel.TextXAlignment = Enum.TextXAlignment.Left

local ShowTeamHelp = Instance.new("TextButton", ContentFrame)
ShowTeamHelp.Size = UDim2.new(0, 18, 0, 18); ShowTeamHelp.Position = UDim2.new(0, 210, 0, y + 3)
ShowTeamHelp.BackgroundColor3 = Color3.fromRGB(100, 100, 100); ShowTeamHelp.Text = "?"
ShowTeamHelp.TextColor3 = Color3.new(1, 1, 1); ShowTeamHelp.Font = Enum.Font.GothamBold
ShowTeamHelp.TextSize = 12; ShowTeamHelp.AutoButtonColor = false
Instance.new("UICorner", ShowTeamHelp).CornerRadius = UDim.new(1, 0)
ShowTeamHelp.MouseButton1Click:Connect(function()
    local pos = UDim2.new(0, ShowTeamHelp.AbsolutePosition.X - 100, 0, ShowTeamHelp.AbsolutePosition.Y + 25)
    ShowTooltip("Показывает название команды над ником игрока. Если игрок не в команде, показывает 'Тема отсутствует'.", pos, ShowTeamHelp)
end)

y = 170
-- СЛАЙДЕР ПРОЗРАЧНОСТИ
local TrText = Instance.new("TextLabel", ContentFrame)
TrText.Size = UDim2.new(0, 160, 0, 20); TrText.Position = UDim2.new(0, 15, 0, y)
TrText.BackgroundTransparency = 1; TrText.Text = "Прозрачность обводки"
TrText.TextColor3 = Color3.fromRGB(180, 180, 180); TrText.Font = Enum.Font.Gotham
TrText.TextSize = 12; TrText.TextXAlignment = Enum.TextXAlignment.Left

y = 195
local SBg = Instance.new("Frame", ContentFrame)
SBg.Size = UDim2.new(0, 220, 0, 4); SBg.Position = UDim2.new(0, 15, 0, y)
SBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30); SBg.BorderSizePixel = 0
Instance.new("UICorner", SBg).CornerRadius = UDim.new(1, 0)

local SFill = Instance.new("Frame", SBg)
SFill.Size = UDim2.new(0, 0, 1, 0); SFill.BackgroundColor3 = Color3.fromRGB(170, 0, 255); SFill.BorderSizePixel = 0
Instance.new("UICorner", SFill).CornerRadius = UDim.new(1, 0)

local SKnob = Instance.new("TextButton", SBg)
SKnob.Size = UDim2.new(0, 14, 0, 14); SKnob.Position = UDim2.new(0, -7, 0.5, -7)
SKnob.BackgroundColor3 = Color3.new(1, 1, 1); SKnob.Text = ""
Instance.new("UICorner", SKnob).CornerRadius = UDim.new(1, 0)

local TInput = Instance.new("TextBox", ContentFrame)
TInput.Size = UDim2.new(0, 45, 0, 22); TInput.Position = UDim2.new(0, 195, 0, y - 25)
TInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20); TInput.Text = "0.00"
TInput.TextColor3 = Color3.new(1, 1, 1); TInput.Font = Enum.Font.Gotham
TInput.TextSize = 12; TInput.BorderSizePixel = 0
Instance.new("UICorner", TInput).CornerRadius = UDim.new(0, 6)
local TIS = Instance.new("UIStroke", TInput)
TIS.Color = Color3.fromRGB(170, 0, 255); TIS.Thickness = 1; TIS.Transparency = 0.5

y = 220
-- ЗАГОЛОВОК AIMBOT
local AimTitle = Instance.new("TextLabel", ContentFrame)
AimTitle.Size = UDim2.new(0, 100, 0, 20); AimTitle.Position = UDim2.new(0, 15, 0, y)
AimTitle.BackgroundTransparency = 1; AimTitle.Text = "🎯 AIMBOT"
AimTitle.TextColor3 = Color3.fromRGB(255, 80, 80); AimTitle.Font = Enum.Font.GothamBold
AimTitle.TextSize = 14; AimTitle.TextXAlignment = Enum.TextXAlignment.Left

y = 245
-- ЧЕКБОКС AIMBOT
local AimBtn = Instance.new("TextButton", ContentFrame)
AimBtn.Size = UDim2.new(0, 24, 0, 24); AimBtn.Position = UDim2.new(0, 15, 0, y)
AimBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); AimBtn.Text = "X"
AimBtn.TextColor3 = Color3.new(1, 1, 1); AimBtn.Font = Enum.Font.GothamBold; AimBtn.TextSize = 14
AimBtn.AutoButtonColor = false
Instance.new("UICorner", AimBtn).CornerRadius = UDim.new(0, 6)

local AimLabel = Instance.new("TextLabel", ContentFrame)
AimLabel.Size = UDim2.new(0, 140, 0, 24); AimLabel.Position = UDim2.new(0, 55, 0, y)
AimLabel.BackgroundTransparency = 1; AimLabel.Text = "Включить Aimbot"
AimLabel.TextColor3 = Color3.new(1, 1, 1); AimLabel.Font = Enum.Font.Gotham
AimLabel.TextSize = 13; AimLabel.TextXAlignment = Enum.TextXAlignment.Left

local AimHelp = Instance.new("TextButton", ContentFrame)
AimHelp.Size = UDim2.new(0, 18, 0, 18); AimHelp.Position = UDim2.new(0, 210, 0, y + 3)
AimHelp.BackgroundColor3 = Color3.fromRGB(100, 100, 100); AimHelp.Text = "?"
AimHelp.TextColor3 = Color3.new(1, 1, 1); AimHelp.Font = Enum.Font.GothamBold
AimHelp.TextSize = 12; AimHelp.AutoButtonColor = false
Instance.new("UICorner", AimHelp).CornerRadius = UDim.new(1, 0)
AimHelp.MouseButton1Click:Connect(function()
    local pos = UDim2.new(0, AimHelp.AbsolutePosition.X - 100, 0, AimHelp.AbsolutePosition.Y + 25)
    ShowTooltip("При удержании заданной клавиши наводится на ближайшего игрока в FOV. Не целится сквозь стены.", pos, AimHelp)
end)

y = 280
-- КЛАВИША АКТИВАЦИИ AIMBOT
local AimKeyLabel = Instance.new("TextLabel", ContentFrame)
AimKeyLabel.Size = UDim2.new(0, 180, 0, 20); AimKeyLabel.Position = UDim2.new(0, 15, 0, y)
AimKeyLabel.BackgroundTransparency = 1; AimKeyLabel.Text = "Клавиша активации аимбота"
AimKeyLabel.TextColor3 = Color3.fromRGB(180, 180, 180); AimKeyLabel.Font = Enum.Font.Gotham
AimKeyLabel.TextSize = 12; AimKeyLabel.TextXAlignment = Enum.TextXAlignment.Left

y = 305
local AimKeyBtn = Instance.new("TextButton", ContentFrame)
AimKeyBtn.Size = UDim2.new(0, 80, 0, 24); AimKeyBtn.Position = UDim2.new(0, 15, 0, y)
AimKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); AimKeyBtn.Text = "ЛКМ"
AimKeyBtn.TextColor3 = Color3.new(1, 1, 1); AimKeyBtn.Font = Enum.Font.GothamBold
AimKeyBtn.TextSize = 13; AimKeyBtn.AutoButtonColor = false
Instance.new("UICorner", AimKeyBtn).CornerRadius = UDim.new(0, 6)

local AimKeyHelp = Instance.new("TextButton", ContentFrame)
AimKeyHelp.Size = UDim2.new(0, 18, 0, 18); AimKeyHelp.Position = UDim2.new(0, 105, 0, y + 3)
AimKeyHelp.BackgroundColor3 = Color3.fromRGB(100, 100, 100); AimKeyHelp.Text = "?"
AimKeyHelp.TextColor3 = Color3.new(1, 1, 1); AimKeyHelp.Font = Enum.Font.GothamBold
AimKeyHelp.TextSize = 12; AimKeyHelp.AutoButtonColor = false
Instance.new("UICorner", AimKeyHelp).CornerRadius = UDim.new(1, 0)
AimKeyHelp.MouseButton1Click:Connect(function()
    local pos = UDim2.new(0, AimKeyHelp.AbsolutePosition.X - 100, 0, AimKeyHelp.AbsolutePosition.Y + 25)
    ShowTooltip("Нажмите на кнопку, затем нажмите нужную клавишу для активации AimBot. По умолчанию ЛКМ.", pos, AimKeyHelp)
end)

y = 345
-- ЧЕКБОКС TEAM CHECK
local TeamCheckBtn = Instance.new("TextButton", ContentFrame)
TeamCheckBtn.Size = UDim2.new(0, 24, 0, 24); TeamCheckBtn.Position = UDim2.new(0, 15, 0, y)
TeamCheckBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); TeamCheckBtn.Text = "X"
TeamCheckBtn.TextColor3 = Color3.new(1, 1, 1); TeamCheckBtn.Font = Enum.Font.GothamBold; TeamCheckBtn.TextSize = 14
TeamCheckBtn.AutoButtonColor = false
Instance.new("UICorner", TeamCheckBtn).CornerRadius = UDim.new(0, 6)

local TeamCheckLabel = Instance.new("TextLabel", ContentFrame)
TeamCheckLabel.Size = UDim2.new(0, 140, 0, 24); TeamCheckLabel.Position = UDim2.new(0, 55, 0, y)
TeamCheckLabel.BackgroundTransparency = 1; TeamCheckLabel.Text = "Team Check"
TeamCheckLabel.TextColor3 = Color3.new(1, 1, 1); TeamCheckLabel.Font = Enum.Font.Gotham
TeamCheckLabel.TextSize = 13; TeamCheckLabel.TextXAlignment = Enum.TextXAlignment.Left

local TeamCheckHelp = Instance.new("TextButton", ContentFrame)
TeamCheckHelp.Size = UDim2.new(0, 18, 0, 18); TeamCheckHelp.Position = UDim2.new(0, 210, 0, y + 3)
TeamCheckHelp.BackgroundColor3 = Color3.fromRGB(100, 100, 100); TeamCheckHelp.Text = "?"
TeamCheckHelp.TextColor3 = Color3.new(1, 1, 1); TeamCheckHelp.Font = Enum.Font.GothamBold
TeamCheckHelp.TextSize = 12; TeamCheckHelp.AutoButtonColor = false
Instance.new("UICorner", TeamCheckHelp).CornerRadius = UDim.new(1, 0)
TeamCheckHelp.MouseButton1Click:Connect(function()
    local pos = UDim2.new(0, TeamCheckHelp.AbsolutePosition.X - 100, 0, TeamCheckHelp.AbsolutePosition.Y + 25)
    ShowTooltip("При включении аимбот не будет целиться в игроков из вашей команды.", pos, TeamCheckHelp)
end)

y = 380
-- ЧЕКБОКС TRIGGER BOT
local TriggerBotBtn = Instance.new("TextButton", ContentFrame)
TriggerBotBtn.Size = UDim2.new(0, 24, 0, 24); TriggerBotBtn.Position = UDim2.new(0, 15, 0, y)
TriggerBotBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); TriggerBotBtn.Text = "X"
TriggerBotBtn.TextColor3 = Color3.new(1, 1, 1); TriggerBotBtn.Font = Enum.Font.GothamBold; TriggerBotBtn.TextSize = 14
TriggerBotBtn.AutoButtonColor = false
Instance.new("UICorner", TriggerBotBtn).CornerRadius = UDim.new(0, 6)

local TriggerBotLabel = Instance.new("TextLabel", ContentFrame)
TriggerBotLabel.Size = UDim2.new(0, 140, 0, 24); TriggerBotLabel.Position = UDim2.new(0, 55, 0, y)
TriggerBotLabel.BackgroundTransparency = 1; TriggerBotLabel.Text = "Триггер бот"
TriggerBotLabel.TextColor3 = Color3.new(1, 1, 1); TriggerBotLabel.Font = Enum.Font.Gotham
TriggerBotLabel.TextSize = 13; TriggerBotLabel.TextXAlignment = Enum.TextXAlignment.Left

local TriggerBotHelp = Instance.new("TextButton", ContentFrame)
TriggerBotHelp.Size = UDim2.new(0, 18, 0, 18); TriggerBotHelp.Position = UDim2.new(0, 210, 0, y + 3)
TriggerBotHelp.BackgroundColor3 = Color3.fromRGB(100, 100, 100); TriggerBotHelp.Text = "?"
TriggerBotHelp.TextColor3 = Color3.new(1, 1, 1); TriggerBotHelp.Font = Enum.Font.GothamBold
TriggerBotHelp.TextSize = 12; TriggerBotHelp.AutoButtonColor = false
Instance.new("UICorner", TriggerBotHelp).CornerRadius = UDim.new(1, 0)
TriggerBotHelp.MouseButton1Click:Connect(function()
    local pos = UDim2.new(0, TriggerBotHelp.AbsolutePosition.X - 100, 0, TriggerBotHelp.AbsolutePosition.Y + 25)
    ShowTooltip("При наведении на игрока автоматически стреляет без задержек. Работает только при включённом AimBot.", pos, TriggerBotHelp)
end)

y = 415
-- ЧЕКБОКС FOV
local FovVisBtn = Instance.new("TextButton", ContentFrame)
FovVisBtn.Size = UDim2.new(0, 24, 0, 24); FovVisBtn.Position = UDim2.new(0, 15, 0, y)
FovVisBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); FovVisBtn.Text = "X"
FovVisBtn.TextColor3 = Color3.new(1, 1, 1); FovVisBtn.Font = Enum.Font.GothamBold; FovVisBtn.TextSize = 14
FovVisBtn.AutoButtonColor = false
Instance.new("UICorner", FovVisBtn).CornerRadius = UDim.new(0, 6)

local FovVisLabel = Instance.new("TextLabel", ContentFrame)
FovVisLabel.Size = UDim2.new(0, 140, 0, 24); FovVisLabel.Position = UDim2.new(0, 55, 0, y)
FovVisLabel.BackgroundTransparency = 1; FovVisLabel.Text = "Видеть FOV"
FovVisLabel.TextColor3 = Color3.new(1, 1, 1); FovVisLabel.Font = Enum.Font.Gotham
FovVisLabel.TextSize = 13; FovVisLabel.TextXAlignment = Enum.TextXAlignment.Left

local FovVisHelp = Instance.new("TextButton", ContentFrame)
FovVisHelp.Size = UDim2.new(0, 18, 0, 18); FovVisHelp.Position = UDim2.new(0, 210, 0, y + 3)
FovVisHelp.BackgroundColor3 = Color3.fromRGB(100, 100, 100); FovVisHelp.Text = "?"
FovVisHelp.TextColor3 = Color3.new(1, 1, 1); FovVisHelp.Font = Enum.Font.GothamBold
FovVisHelp.TextSize = 12; FovVisHelp.AutoButtonColor = false
Instance.new("UICorner", FovVisHelp).CornerRadius = UDim.new(1, 0)
FovVisHelp.MouseButton1Click:Connect(function()
    local pos = UDim2.new(0, FovVisHelp.AbsolutePosition.X - 100, 0, FovVisHelp.AbsolutePosition.Y + 25)
    ShowTooltip("Показывает круг FOV на экране.", pos, FovVisHelp)
end)

y = 450
-- СЛАЙДЕР FOV
local FovText = Instance.new("TextLabel", ContentFrame)
FovText.Size = UDim2.new(0, 120, 0, 20); FovText.Position = UDim2.new(0, 15, 0, y)
FovText.BackgroundTransparency = 1; FovText.Text = "Размер FOV"
FovText.TextColor3 = Color3.fromRGB(180, 180, 180); FovText.Font = Enum.Font.Gotham
FovText.TextSize = 12; FovText.TextXAlignment = Enum.TextXAlignment.Left

y = 475
local FovSliderBg = Instance.new("Frame", ContentFrame)
FovSliderBg.Size = UDim2.new(0, 180, 0, 4); FovSliderBg.Position = UDim2.new(0, 15, 0, y)
FovSliderBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30); FovSliderBg.BorderSizePixel = 0
Instance.new("UICorner", FovSliderBg).CornerRadius = UDim.new(1, 0)

local FovSliderFill = Instance.new("Frame", FovSliderBg)
FovSliderFill.Size = UDim2.new(0.5, 0, 1, 0); FovSliderFill.BackgroundColor3 = Color3.fromRGB(255, 80, 80); FovSliderFill.BorderSizePixel = 0
Instance.new("UICorner", FovSliderFill).CornerRadius = UDim.new(1, 0)

local FovSliderKnob = Instance.new("TextButton", FovSliderBg)
FovSliderKnob.Size = UDim2.new(0, 14, 0, 14); FovSliderKnob.Position = UDim2.new(0.5, -7, 0.5, -7)
FovSliderKnob.BackgroundColor3 = Color3.new(1, 1, 1); FovSliderKnob.Text = ""
Instance.new("UICorner", FovSliderKnob).CornerRadius = UDim.new(1, 0)

local FovInput = Instance.new("TextBox", ContentFrame)
FovInput.Size = UDim2.new(0, 45, 0, 22); FovInput.Position = UDim2.new(0, 195, 0, y - 25)
FovInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20); FovInput.Text = "150"
FovInput.TextColor3 = Color3.new(1, 1, 1); FovInput.Font = Enum.Font.Gotham
FovInput.TextSize = 12; FovInput.BorderSizePixel = 0
Instance.new("UICorner", FovInput).CornerRadius = UDim.new(0, 6)
local FovIS = Instance.new("UIStroke", FovInput)
FovIS.Color = Color3.fromRGB(255, 80, 80); FovIS.Thickness = 1; FovIS.Transparency = 0.5

-- ПОЛОСКА
local HBar = Instance.new("Frame", ScreenGui)
HBar.Size = UDim2.new(0, 230, 0, 6); HBar.Position = UDim2.new(0.5, -115, 0.97, 0)
HBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20); HBar.BackgroundTransparency = 0.3
HBar.BorderSizePixel = 0; HBar.Visible = false
Instance.new("UICorner", HBar).CornerRadius = UDim.new(1, 0)
local HBS = Instance.new("UIStroke", HBar)
HBS.Color = Color3.fromRGB(200, 50, 255); HBS.Thickness = 2; HBS.Transparency = 0.3
HBS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
animatedStrokes[HBS] = true
local HBB = Instance.new("TextButton", HBar)
HBB.Size = UDim2.new(1, 0, 1, 0); HBB.BackgroundTransparency = 1; HBB.Text = ""

-- ХОВЕРЫ
local function Hover(b, nc, hc)
    b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = hc}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = nc}):Play() end)
end
Hover(MinBtn, Color3.fromRGB(20, 20, 20), Color3.fromRGB(60, 60, 60))
Hover(ClsBtn, Color3.fromRGB(20, 20, 20), Color3.fromRGB(60, 60, 60))
Hover(SetBtn, Color3.fromRGB(20, 20, 20), Color3.fromRGB(50, 50, 50))
Hover(SCB, Color3.fromRGB(20, 20, 20), Color3.fromRGB(60, 60, 60))
Hover(ResizeHelp, Color3.fromRGB(100, 100, 100), Color3.fromRGB(150, 150, 150))
Hover(ResetHelp, Color3.fromRGB(100, 100, 100), Color3.fromRGB(150, 150, 150))
Hover(ESPHelp, Color3.fromRGB(100, 100, 100), Color3.fromRGB(150, 150, 150))
Hover(VisHelp, Color3.fromRGB(100, 100, 100), Color3.fromRGB(150, 150, 150))
Hover(GradientESPHelp, Color3.fromRGB(100, 100, 100), Color3.fromRGB(150, 150, 150))
Hover(ShowTeamHelp, Color3.fromRGB(100, 100, 100), Color3.fromRGB(150, 150, 150))
Hover(AimHelp, Color3.fromRGB(100, 100, 100), Color3.fromRGB(150, 150, 150))
Hover(AimKeyHelp, Color3.fromRGB(100, 100, 100), Color3.fromRGB(150, 150, 150))
Hover(TeamCheckHelp, Color3.fromRGB(100, 100, 100), Color3.fromRGB(150, 150, 150))
Hover(TriggerBotHelp, Color3.fromRGB(100, 100, 100), Color3.fromRGB(150, 150, 150))
Hover(FovVisHelp, Color3.fromRGB(100, 100, 100), Color3.fromRGB(150, 150, 150))
Hover(KeybindHelp, Color3.fromRGB(100, 100, 100), Color3.fromRGB(150, 150, 150))

-- СОСТОЯНИЯ
local esp = true
local visOnly = false
local showTeam = false
local gradientESP = false
local outTransp = 0.0
local aimEnabled = false
local aimKey = "MouseButton1"
local listeningForAimKey = false
local teamCheck = false
local triggerBot = false
local showFov = false
local fovSize = 150
local minimized = false
local closed = false
local resizeMode = false
local resizing = false
local dragging = false
local dsm = nil; local dsp = nil
local rEdge = nil
local im = nil; local ips = nil; local ipp = nil
local savedSize = DEFAULT_SIZE
local savedPos = DEFAULT_POS
local ESPs = {}
local hotkey = Enum.KeyCode.P
local listeningForKey = false
local isAnimating = false
local aimKeyDown = false

-- FOV КРУГ (Drawing)
local FovCircle = Drawing.new("Circle")
FovCircle.Color = Color3.fromRGB(255, 80, 80)
FovCircle.Thickness = 2
FovCircle.Transparency = 0.5
FovCircle.Visible = false
FovCircle.Filled = false
FovCircle.NumSides = 64
FovCircle.ZIndex = 1000

-- AIMBOT ЛОГИКА
local Camera = workspace.CurrentCamera

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and aimKey == "MouseButton1" then
        aimKeyDown = true
    elseif input.UserInputType == Enum.UserInputType.Keyboard then
        if listeningForKey then
            hotkey = input.KeyCode
            KeybindBtn.Text = input.KeyCode.Name
            listeningForKey = false
            KeybindBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            ShowNotification("Горячая клавиша изменена на " .. input.KeyCode.Name, 3)
        elseif listeningForAimKey then
            aimKey = input.KeyCode.Name
            AimKeyBtn.Text = input.KeyCode.Name
            listeningForAimKey = false
            AimKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            ShowNotification("Клавиша AimBot изменена на " .. input.KeyCode.Name, 3)
        elseif input.KeyCode.Name == aimKey then
            aimKeyDown = true
        elseif input.KeyCode == hotkey then
            if closed or isAnimating then return end
            isAnimating = true
            if Panel.Visible and not minimized then
                savedSize = Panel.Size
                savedPos = Panel.Position
                TweenService:Create(Panel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Size = UDim2.new(0, 0, 0, 0),
                    Position = UDim2.new(0.5, -1, 0.97, -3)
                }):Play()
                task.delay(0.3, function()
                    Panel.Visible = false
                    SM.Visible = false
                    HBar.Visible = true
                    minimized = true
                    HideTooltip()
                    isAnimating = false
                end)
            elseif minimized or (Panel.Visible == false and not closed) then
                Panel.Position = savedPos
                Panel.Size = UDim2.new(0, 0, 0, 0)
                Panel.Visible = true
                HBar.Visible = false
                TweenService:Create(Panel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = savedSize,
                    Position = savedPos
                }):Play()
                task.delay(0.3, function()
                    minimized = false
                    isAnimating = false
                end)
            else
                isAnimating = false
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and aimKey == "MouseButton1" then
        aimKeyDown = false
    elseif input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == aimKey then
        aimKeyDown = false
    end
end)

function MinimizeButton_MouseClick()
    if isAnimating then return end
    isAnimating = true
    savedSize = Panel.Size; savedPos = Panel.Position
    TweenService:Create(Panel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, -1, 0.97, -3)
    }):Play()
    task.delay(0.3, function()
        Panel.Visible = false; SM.Visible = false; HBar.Visible = true; minimized = true
        HideTooltip()
        isAnimating = false
    end)
end

function HomeBarButton_MouseClick()
    if isAnimating then return end
    isAnimating = true
    Panel.Position = savedPos; Panel.Size = UDim2.new(0, 0, 0, 0)
    Panel.Visible = true; HBar.Visible = false
    TweenService:Create(Panel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = savedSize, Position = savedPos
    }):Play()
    task.delay(0.3, function()
        minimized = false
        isAnimating = false
    end)
end

local function IsVisible(targetHead)
    local origin = Camera.CFrame.Position
    local direction = (targetHead.Position - origin).Unit * (targetHead.Position - origin).Magnitude
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    
    local result = workspace:Raycast(origin, direction, raycastParams)
    if result then
        local hitChar = result.Instance:FindFirstAncestorOfClass("Model")
        if hitChar then
            local hitPlayer = Players:GetPlayerFromCharacter(hitChar)
            return hitPlayer ~= nil
        end
    end
    return false
end

local function GetClosestPlayerInFov()
    if not aimEnabled or not aimKeyDown or closed then return nil end
    local closest = nil; local closestDist = fovSize / 2
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local myTeam = LocalPlayer.Team
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            
            if teamCheck and myTeam and player.Team == myTeam then
                continue
            end
            
            local head = player.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                if dist <= fovSize / 2 and (not closest or dist < closestDist) then
                    if IsVisible(head) then
                        closestDist = dist; closest = player
                    end
                end
            end
        end
    end
    return closest
end

-- Анимированный градиент для ESP
local espGradientTime = 0
RunService.RenderStepped:Connect(function(delta)
    if closed then
        FovCircle.Visible = false
        return
    end
    
    if aimEnabled and aimKeyDown then
        local target = GetClosestPlayerInFov()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
    FovCircle.Visible = showFov and not closed
    if showFov and not closed then
        local screenSize = Camera.ViewportSize
        FovCircle.Position = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
        FovCircle.Radius = fovSize / 2
    end
    
    -- Триггер бот
    if triggerBot and aimEnabled and aimKeyDown then
        local target = GetClosestPlayerInFov()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local head = target.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                if dist <= fovSize / 2 then
                    pcall(function()
                        VirtualInputManager:SendMouseButtonEvent(
                            Camera.ViewportSize.X / 2,
                            Camera.ViewportSize.Y / 2,
                            0,
                            true,
                            nil,
                            0
                        )
                        task.wait()
                        VirtualInputManager:SendMouseButtonEvent(
                            Camera.ViewportSize.X / 2,
                            Camera.ViewportSize.Y / 2,
                            0,
                            false,
                            nil,
                            0
                        )
                    end)
                end
            end
        end
    end
    
    -- Обновление градиентной подсветки
    if gradientESP then
        espGradientTime = espGradientTime + delta * 0.6
        for _, data in pairs(ESPs) do
            if data.Highlight then
                local hue = 0.78 + math.sin(espGradientTime * math.pi * 2) * 0.07
                data.Highlight.OutlineColor = Color3.fromHSV(hue, 0.8, 1)
            end
        end
    end
end)

local function UpdSlider(v)
    local cv = math.clamp(v, 0, 1)
    SFill.Size = UDim2.new(cv, 0, 1, 0); SKnob.Position = UDim2.new(cv, -7, 0.5, -7)
    TInput.Text = string.format("%.2f", cv); outTransp = cv
end

local function UpdFovSlider(v)
    local cv = math.clamp(v, 0, 1)
    fovSize = math.floor(50 + cv * 350)
    FovSliderFill.Size = UDim2.new(cv, 0, 1, 0); FovSliderKnob.Position = UDim2.new(cv, -7, 0.5, -7)
    FovInput.Text = tostring(fovSize)
end

local function ResetPanel()
    resizeMode = false
    ResizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); ResizeBtn.Text = "X"
    PanelStroke.Thickness = 3; PanelStroke.Transparency = 0.3; Panel.Draggable = true
    LG.Visible = false; RG.Visible = false; TG.Visible = false; BG.Visible = false
    TLG.Visible = false; TRG.Visible = false; BLG.Visible = false; BRG.Visible = false
    savedSize = DEFAULT_SIZE; savedPos = DEFAULT_POS
    TweenService:Create(Panel, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = DEFAULT_SIZE, Position = DEFAULT_POS
    }):Play()
    ShowNotification("Панель возвращена в исходное состояние!", 4)
end

local function CreateESP(plr)
    if closed then return end
    local chr = plr.Character
    if not chr then return end
    local hum = chr:FindFirstChild("Humanoid")
    if not hum then return end
    
    local hl = Instance.new("Highlight")
    hl.Name = "ESP_" .. plr.Name
    hl.OutlineColor = Color3.fromRGB(170, 0, 255)
    hl.OutlineTransparency = outTransp
    hl.FillColor = plr.Team and plr.Team.TeamColor.Color or Color3.fromRGB(255, 80, 80)
    hl.FillTransparency = 0.85
    hl.Parent = chr

    local head = chr:FindFirstChild("Head")
    if not head then return end
    
    local bb = Instance.new("BillboardGui")
    bb.AlwaysOnTop = true
    bb.Size = UDim2.new(0, 200, 0, 50)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.MaxDistance = 300
    bb.Parent = head

    local tl = Instance.new("TextLabel", bb)
    tl.Size = UDim2.new(1, 0, 1, 0)
    tl.BackgroundTransparency = 1
    tl.TextColor3 = Color3.new(1, 1, 1)
    tl.Font = Enum.Font.GothamBold
    tl.TextScaled = true
    tl.TextStrokeTransparency = 0.5
    tl.TextStrokeColor3 = Color3.fromRGB(170, 0, 255)
    
    local function updateText()
        if not ESPs[plr.Name] then return end
        local teamName = ""
        if showTeam then
            if plr.Team then
                teamName = "[" .. plr.Team.Name .. "]\n"
            else
                teamName = "[Тема отсутствует]\n"
            end
        end
        tl.Text = teamName .. plr.Name .. "\n🤍 " .. math.floor(hum.Health)
    end
    
    updateText()
    
    ESPs[plr.Name] = {Highlight = hl, Billboard = bb, TextLabel = tl, Player = plr, UpdateText = updateText}

    local function updateDistance()
        if not ESPs[plr.Name] then return end
        if not plr.Character or not plr.Character:FindFirstChild("Head") then return end
        local dist = (Camera.CFrame.Position - plr.Character.Head.Position).Magnitude
        local scale = math.clamp(1 - (dist / 300), 0.3, 1)
        bb.Size = UDim2.new(0, 200 * scale, 0, 50 * scale)
    end

    RunService.RenderStepped:Connect(function()
        if closed or not ESPs[plr.Name] then return end
        if plr.Character and plr.Character:FindFirstChild("Humanoid") then
            ESPs[plr.Name].UpdateText()
            updateDistance()
        end
    end)

    local healthConnection
    healthConnection = hum.HealthChanged:Connect(function()
        if not ESPs[plr.Name] then
            healthConnection:Disconnect()
            return
        end
        if hum.Health <= 0 then
            RemoveESP(plr.Name)
        else
            ESPs[plr.Name].UpdateText()
        end
    end)
    
    ESPs[plr.Name].HealthConnection = healthConnection
end

local function RemoveESP(nm)
    if ESPs[nm] then
        if ESPs[nm].HealthConnection then ESPs[nm].HealthConnection:Disconnect() end
        if ESPs[nm].Highlight then ESPs[nm].Highlight:Destroy() end
        if ESPs[nm].Billboard then ESPs[nm].Billboard:Destroy() end
        ESPs[nm] = nil
    end
end

local function RemoveAllESP()
    for n in pairs(ESPs) do
        RemoveESP(n)
    end
end

local function UpdateAllESP()
    for _, d in pairs(ESPs) do
        if d.Highlight then
            d.Highlight.Enabled = esp
            d.Highlight.OutlineTransparency = outTransp
            if not gradientESP then
                d.Highlight.OutlineColor = Color3.fromRGB(170, 0, 255)
            end
        end
        if d.Billboard then
            d.Billboard.Enabled = esp
        end
        if d.UpdateText then
            d.UpdateText()
        end
    end
end

local function OnCharacterAdded(player, char)
    if player == LocalPlayer then
        RemoveAllESP()
        if not closed then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    if p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                        CreateESP(p)
                    end
                end
            end
        end
        return
    end
    
    task.wait(0.5)
    if not closed and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
        RemoveESP(player.Name)
        CreateESP(player)
    end
end

-- СВОРАЧИВАНИЕ
MinBtn.MouseButton1Click:Connect(function() MinimizeButton_MouseClick() end)
HBB.MouseButton1Click:Connect(function() HomeBarButton_MouseClick() end)

-- ЗАКРЫТИЕ
ClsBtn.MouseButton1Click:Connect(function()
    if isAnimating then return end
    isAnimating = true
    closed = true
    TweenService:Create(Panel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, -1, 0.97, -3)
    }):Play()
    task.delay(0.2, function()
        Panel.Visible = false; SM.Visible = false; HBar.Visible = false
        RemoveAllESP()
        HideTooltip()
        isAnimating = false
        ShowNotification("Надеюсь мы ещё увидимся 😣", 6)
    end)
end)

-- НАСТРОЙКИ
SetBtn.MouseButton1Click:Connect(function()
    SM.Visible = not SM.Visible
    if SM.Visible then
        SM.Size = UDim2.new(0, 0, 0, 0)
        local pp = Panel.AbsolutePosition
        SM.Position = UDim2.new(0, pp.X + 10, 0, pp.Y + 10)
        TweenService:Create(SM, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 260, 0, 140)
        }):Play()
    else HideTooltip() end
end)

SCB.MouseButton1Click:Connect(function()
    TweenService:Create(SM, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0)
    }):Play()
    task.delay(0.2, function() SM.Visible = false; HideTooltip() end)
end)

-- РЕСАЙЗ
ResizeBtn.MouseButton1Click:Connect(function()
    resizeMode = not resizeMode
    if resizeMode then
        ResizeBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 255); ResizeBtn.Text = "✓"
        PanelStroke.Thickness = 5; PanelStroke.Transparency = 0.1; Panel.Draggable = false
        LG.Visible = true; RG.Visible = true; TG.Visible = true; BG.Visible = true
        TLG.Visible = true; TRG.Visible = true; BLG.Visible = true; BRG.Visible = true
        ShowNotification("Тяните за края для размера!", 5)
    else
        ResizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); ResizeBtn.Text = "X"
        PanelStroke.Thickness = 3; PanelStroke.Transparency = 0.3; Panel.Draggable = true
        LG.Visible = false; RG.Visible = false; TG.Visible = false; BG.Visible = false
        TLG.Visible = false; TRG.Visible = false; BLG.Visible = false; BRG.Visible = false
    end
end)

-- ГОРЯЧАЯ КЛАВИША
KeybindBtn.MouseButton1Click:Connect(function()
    listeningForKey = true
    KeybindBtn.Text = "..."
    KeybindBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
    ShowNotification("Нажмите любую клавишу...", 3)
end)

-- КЛАВИША AIMBOT
AimKeyBtn.MouseButton1Click:Connect(function()
    listeningForAimKey = true
    AimKeyBtn.Text = "..."
    AimKeyBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
    ShowNotification("Нажмите клавишу для активации AimBot...", 3)
end)

ResetBtn.MouseButton1Click:Connect(function() ResetPanel() end)

-- AIMBOT
AimBtn.MouseButton1Click:Connect(function()
    aimEnabled = not aimEnabled
    AimBtn.BackgroundColor3 = aimEnabled and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(60, 60, 60)
    AimBtn.Text = aimEnabled and "✓" or "X"
end)

-- TEAM CHECK
TeamCheckBtn.MouseButton1Click:Connect(function()
    teamCheck = not teamCheck
    TeamCheckBtn.BackgroundColor3 = teamCheck and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(60, 60, 60)
    TeamCheckBtn.Text = teamCheck and "✓" or "X"
end)

-- TRIGGER BOT
TriggerBotBtn.MouseButton1Click:Connect(function()
    triggerBot = not triggerBot
    TriggerBotBtn.BackgroundColor3 = triggerBot and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(60, 60, 60)
    TriggerBotBtn.Text = triggerBot and "✓" or "X"
end)

FovVisBtn.MouseButton1Click:Connect(function()
    showFov = not showFov
    FovVisBtn.BackgroundColor3 = showFov and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(60, 60, 60)
    FovVisBtn.Text = showFov and "✓" or "X"
end)

-- ГРАДИЕНТНАЯ ПОДСВЕТКА
GradientESPBtn.MouseButton1Click:Connect(function()
    gradientESP = not gradientESP
    GradientESPBtn.BackgroundColor3 = gradientESP and Color3.fromRGB(170, 0, 255) or Color3.fromRGB(60, 60, 60)
    GradientESPBtn.Text = gradientESP and "✓" or "X"
    if not gradientESP then
        for _, data in pairs(ESPs) do
            if data.Highlight then
                data.Highlight.OutlineColor = Color3.fromRGB(170, 0, 255)
            end
        end
    end
end)

-- ВИДЕТЬ ТЕМЫ
ShowTeamBtn.MouseButton1Click:Connect(function()
    showTeam = not showTeam
    ShowTeamBtn.BackgroundColor3 = showTeam and Color3.fromRGB(170, 0, 255) or Color3.fromRGB(60, 60, 60)
    ShowTeamBtn.Text = showTeam and "✓" or "X"
    UpdateAllESP()
end)

-- ГРИПЫ
local function CG(g, nm)
    g.InputBegan:Connect(function(inp)
        if not resizeMode then return end
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true; rEdge = nm
            im = UserInputService:GetMouseLocation()
            ips = Panel.AbsoluteSize; ipp = Panel.AbsolutePosition
        end
    end)
end
CG(LG, "Left"); CG(RG, "Right"); CG(TG, "Top"); CG(BG, "Bottom")
CG(TLG, "TopLeft"); CG(TRG, "TopRight"); CG(BLG, "BottomLeft"); CG(BRG, "BottomRight")

Panel.InputBegan:Connect(function(inp)
    if not resizeMode then return end
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        local mp = UserInputService:GetMouseLocation()
        local pp = Panel.AbsolutePosition; local ps = Panel.AbsoluteSize; local t = 35
        local oe = false
        if math.abs(mp.X - (pp.X + ps.X)) <= t and mp.Y >= pp.Y - t and mp.Y <= pp.Y + ps.Y + t then oe = true end
        if math.abs(mp.X - pp.X) <= t and mp.Y >= pp.Y - t and mp.Y <= pp.Y + ps.Y + t then oe = true end
        if math.abs(mp.Y - (pp.Y + ps.Y)) <= t and mp.X >= pp.X - t and mp.X <= pp.X + ps.X + t then oe = true end
        if math.abs(mp.Y - pp.Y) <= t and mp.X >= pp.X - t and mp.X <= pp.X + ps.X + t then oe = true end
        if not oe and not resizing then dragging = true; dsm = mp; dsp = pp end
    end
end)

UserInputService.InputChanged:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseMovement then
        local mp = UserInputService:GetMouseLocation()
        if resizing then
            local dl = mp - im; local ar = ips.X / ips.Y
            local w, h = ips.X, ips.Y; local x, y = ipp.X, ipp.Y
            if rEdge == "Right" then w = math.max(220, ips.X + dl.X); h = w / ar
            elseif rEdge == "Left" then w = math.max(220, ips.X - dl.X); h = w / ar; x = ipp.X + (ips.X - w)
            elseif rEdge == "Bottom" then h = math.max(150, ips.Y + dl.Y); w = h * ar
            elseif rEdge == "Top" then h = math.max(150, ips.Y - dl.Y); w = h * ar; y = ipp.Y + (ips.Y - h)
            elseif rEdge == "BottomRight" then local d = math.max(dl.X, dl.Y); w = math.max(220, ips.X + d); h = w / ar
            elseif rEdge == "TopLeft" then local d = math.max(-dl.X, -dl.Y); w = math.max(220, ips.X - d); h = w / ar; x = ipp.X + (ips.X - w); y = ipp.Y + (ips.Y - h)
            elseif rEdge == "TopRight" then local d = math.max(dl.X, -dl.Y); w = math.max(220, ips.X + d); h = w / ar; y = ipp.Y + (ips.Y - h)
            elseif rEdge == "BottomLeft" then local d = math.max(-dl.X, dl.Y); w = math.max(220, ips.X - d); h = w / ar; x = ipp.X + (ips.X - w)
            end
            h = math.max(150, h); w = math.max(220, w)
            local sc = workspace.CurrentCamera.ViewportSize
            x = math.clamp(x, 0, sc.X - w); y = math.clamp(y, 0, sc.Y - h)
            Panel.Size = UDim2.new(0, w, 0, h); Panel.Position = UDim2.new(0, x, 0, y)
            savedSize = Panel.Size; savedPos = Panel.Position
        elseif dragging then
            local dl = mp - dsm
            local x, y = dsp.X + dl.X, dsp.Y + dl.Y
            local sz = Panel.AbsoluteSize; local sc = workspace.CurrentCamera.ViewportSize
            x = math.clamp(x, 0, sc.X - sz.X); y = math.clamp(y, 0, sc.Y - sz.Y)
            Panel.Position = UDim2.new(0, x, 0, y); savedPos = Panel.Position
        end
    end
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false; dragging = false; rEdge = nil end
end)

-- КНОПКИ ESP
ESPBtn.MouseButton1Click:Connect(function()
    esp = not esp
    ESPBtn.BackgroundColor3 = esp and Color3.fromRGB(170, 0, 255) or Color3.fromRGB(60, 60, 60)
    ESPBtn.Text = esp and "✓" or "X"; UpdateAllESP()
end)
VisBtn.MouseButton1Click:Connect(function()
    visOnly = not visOnly
    VisBtn.BackgroundColor3 = visOnly and Color3.fromRGB(170, 0, 255) or Color3.fromRGB(60, 60, 60)
    VisBtn.Text = visOnly and "✓" or "X"
end)

-- СЛАЙДЕР ПРОЗРАЧНОСТИ
local ds = false
SKnob.MouseButton1Down:Connect(function() ds = true end)
UserInputService.InputChanged:Connect(function(inp)
    if ds and inp.UserInputType == Enum.UserInputType.MouseMovement then
        UpdSlider((UserInputService:GetMouseLocation().X - SBg.AbsolutePosition.X) / SBg.AbsoluteSize.X); UpdateAllESP()
    end
end)
UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then ds = false end end)
TInput.FocusLost:Connect(function() local n = tonumber(TInput.Text); if n then UpdSlider(n); UpdateAllESP() end end)

-- СЛАЙДЕР FOV
local fds = false
FovSliderKnob.MouseButton1Down:Connect(function() fds = true end)
UserInputService.InputChanged:Connect(function(inp)
    if fds and inp.UserInputType == Enum.UserInputType.MouseMovement then
        UpdFovSlider((UserInputService:GetMouseLocation().X - FovSliderBg.AbsolutePosition.X) / FovSliderBg.AbsoluteSize.X)
    end
end)
UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then fds = false end end)
FovInput.FocusLost:Connect(function()
    local n = tonumber(FovInput.Text)
    if n then UpdFovSlider(math.clamp((n - 50) / 350, 0, 1)) end
end)

-- ЗАПУСК
Panel.Size = UDim2.new(0, 0, 0, 0); Panel.Position = UDim2.new(0.5, 0, 0.5, 0)
TweenService:Create(Panel, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    Size = savedSize, Position = savedPos
}):Play()

for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        if p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            CreateESP(p)
        end
    end
end

Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then
        if p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            CreateESP(p)
        end
    end
end)

for _, p in pairs(Players:GetPlayers()) do
    p.CharacterAdded:Connect(function(char)
        OnCharacterAdded(p, char)
    end)
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(char)
        OnCharacterAdded(p, char)
    end)
end)

Players.PlayerRemoving:Connect(function(p) RemoveESP(p.Name) end)