#Requires AutoHotkey v2.0
#SingleInstance Force

; --- 0. Локализация ---
global CurrentLang := (A_Language = "0419") ? "RU" : "EN"

global Lang := Map(
    "RU", Map(
        "Title", "External Mod Manager: Road to Vostok",
        "ErrorPath", "Поместите мод менеджер в папку с игрой",
        "ML_NotFound", "Metro Mod Loader не обнаружен, работа приложения будет прекращена.",
        "ML_HowTo", "Как установить Modloader по кнопке ниже.",
        "ML_BtnInstall", "Инструкция по установке",
        "ML_BtnExit", "Закрыть приложение",
        "ColStatus", "Статус", "ColMod", "Мод", "ColPrio", "Приор.", "ColDate", "Изменен", "ColSize", "Размер",
        "ModOn", "Вкл", "ModOff", "Выкл",
        "Open", "Открыть файл", "ShowInFolder", "Показать в папке", "DeleteMod", "Удалить мод",
        "PrioLabel", "Приоритет (-100...100):",
        "MassActions", "Массовые действия:",
        "BtnToggle", "Вкл/Выкл все", "BtnReset", "Сбросить приор.", "BtnClear", "Очистка кэша",
        "Profiles", "Профили модов:",
        "Export", "Экспорт", "Import", "Импорт",
        "Save", "Сохранить", "Launch", "Запустить игру",
        "Total", "Всего модов: ", "Enabled", " | Включено: ",
        "CacheClean", "Кэш очищен.", "CacheNone", "Временные файлы не найдены.",
        "DelConfirm", "Удалить файл мода навсегда?",
        "Bytes", ["Б", "КБ", "МБ", "ГБ"],
        "TT_Prio", "Выберите мод из списка, затем введите желаемый приоритет (можно скроллить колесиком мыши)",
        "TT_Toggle", "Активировать / Деактивировать ВСЕ моды",
        "TT_Reset", "Установить приоритет на 0 для всех модов",
        "TT_Clear", "Удалить временные файлы (Кэш модов, логи, кэш шейдеров DX, VK)",
        "TT_Export", "Экспорт текущей конфигурации модов",
        "TT_Import", "Импорт конфигурации модов",
        "TT_Save", "Применить изменения конфигурации модов",
        "TT_Launch", "Запуск игры через Steam (если запущен) или напрямую (no-steam)"
    ),
    "EN", Map(
        "Title", "External Mod Manager: Road to Vostok",
        "ErrorPath", "Place the mod manager in the game folder",
        "ML_NotFound", "Metro Mod Loader not found. Application will be closed.",
        "ML_HowTo", "Check the installation guide via the button below.",
        "ML_BtnInstall", "Installation Guide",
        "ML_BtnExit", "Close Application",
        "ColStatus", "Status", "ColMod", "Mod", "ColPrio", "Prio.", "ColDate", "Modified", "ColSize", "Size",
        "ModOn", "On", "ModOff", "Off",
        "Open", "Open file", "ShowInFolder", "Show in folder", "DeleteMod", "Delete mod",
        "PrioLabel", "Priority (-100...100):",
        "MassActions", "Mass actions:",
        "BtnToggle", "Toggle All", "BtnReset", "Reset Prio", "BtnClear", "Clear Cache",
        "Profiles", "Mod Profiles:",
        "Export", "Export", "Import", "Import",
        "Save", "Save", "Launch", "Launch Game",
        "Total", "Total mods: ", "Enabled", " | Enabled: ",
        "CacheClean", "Cache cleared.", "CacheNone", "Temporary files not found.",
        "DelConfirm", "Delete mod file permanently?",
        "Bytes", ["B", "KB", "MB", "GB"],
        "TT_Prio", "Select a mod from the list, then enter the desired priority (mouse wheel scrolling supported)",
        "TT_Toggle", "Enable / Disable ALL mods",
        "TT_Reset", "Set priority to 0 for all mods",
        "TT_Clear", "Delete temporary files (Mod cache, logs, DX/VK shader cache)",
        "TT_Export", "Export current mod configuration",
        "TT_Import", "Import mod configuration",
        "TT_Save", "Apply mod configuration changes",
        "TT_Launch", "Launch via Steam (if running) or directly (no-steam)"
    )
)

L(key) => Lang[CurrentLang][key]

; --- 1. Инициализация и Проверка Modloader ---
global AppDataFolder := A_AppData "\Road to Vostok"
global ModLoaderFile := AppDataFolder "\modloader.gd"

if !FileExist(ModLoaderFile) {
    MLGui := Gui("+AlwaysOnTop -MinimizeBox", "Modloader Required")
    MLGui.BackColor := "1A1A1A"
    MLGui.SetFont("s11 cWhite", "Segoe UI")
    MLGui.Add("Text", "Center w350", L("ML_NotFound") "`n`n" L("ML_HowTo"))
    BtnInst := MLGui.Add("Button", "w350 h40", L("ML_BtnInstall"))
    BtnInst.OnEvent("Click", (*) => Run("https://modworkshop.net/mod/55623"))
    BtnExit := MLGui.Add("Button", "w350 h40", L("ML_BtnExit"))
    BtnExit.OnEvent("Click", (*) => ExitApp())
    MLGui.Show()
    WinWaitClose(MLGui)
    ExitApp()
}

if !FileExist(A_ScriptDir "\RTV.exe") && !DirExist(A_ScriptDir "\mods") {
    MsgBox(L("ErrorPath"), "Error", "Iconx")
    ExitApp()
}

global ConfigPath    := AppDataFolder "\mod_config.cfg"
global SMMFolder      := AppDataFolder "\SMM"
global ModsFolder     := A_ScriptDir "\mods" 
global Buttons        := []
global Tooltips       := Map() 
global PendingToolTipText := ""

global Color_BG      := "1A1A1A"
global Color_Btn     := "333333"
global Color_Hover    := "444444"
global Color_Text     := "FFFFFF"

for folder in [SMMFolder, ModsFolder] {
    if !DirExist(folder) {
        DirCreate(folder)
    }
}

; --- 2. Интерфейс ---
MainGui := Gui("+ReSize", L("Title"))
MainGui.BackColor := "0x" Color_BG

if VerCompare(A_OSVersion, "10.0.17763") >= 0 {
    DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", MainGui.Hwnd, "Int", 20, "Int*", 1, "Int", 4)
}

MainGui.SetFont("s18 w600 c" Color_Text, "Segoe UI Variable Display")
HeaderTitle := MainGui.Add("Text", "x20 y20", "External Mod Manager: RTV")

MainGui.SetFont("s12 w600")
LangBtn := MainGui.Add("Text", "x410 y25 w60 h30 Background" Color_Btn " cWhite +0x201 +ReadOnly", "🌐 " CurrentLang)
LangBtn.OnEvent("Click", ToggleLanguage)
LangBtn.DefineProp("IsHovered", {Value: false})
Buttons.Push(LangBtn)

MainGui.SetFont("s10 w400 c" Color_Text, "Segoe UI")
; Добавлена 6-я колонка (скрытая) для точного размера в байтах для сортировки
LV := MainGui.Add("ListView", "x20 y80 w460 h380 Background" Color_Btn " c" Color_Text " +Grid -Multi Checked +ReadOnly", [L("ColStatus"), L("ColMod"), L("ColPrio"), L("ColDate"), L("ColSize"), "SizeBytes"])
LV.OnEvent("ItemCheck", (thisLV, item, checked) => (thisLV.Modify(item, , checked ? L("ModOn") : L("ModOff")), UpdateCounts()))
LV.OnEvent("ItemSelect", (thisLV, item, selected) => selected && (val := thisLV.GetText(item, 3), IsNumber(val) ? PrioUpDown.Value := val : 0))
LV.OnEvent("ContextMenu", (thisLV, item, *) => item && (thisLV.Modify(item, "Select Focus"), ModMenu.Show()))
; Перехват клика по заголовку для кастомной сортировки
LV.OnEvent("ColClick", LV_ColClick)

ModMenu := Menu()
UpdateMenu()

PrioLabel    := MainGui.Add("Text", "x500 y80", L("PrioLabel"))
PrioEdit     := MainGui.Add("Edit", "x500 y105 w60 h28 Background" Color_Btn " +Number")
PrioUpDown   := MainGui.Add("UpDown", "Range-100-100", 0)
PrioEdit.OnEvent("Change", OnPrioChange)

ActionLabel   := MainGui.Add("Text", "x500 y150", L("MassActions"))
ToggleAllBtn  := CreateBtn(L("BtnToggle"), "x500 y175 w150", ToggleAllMods)
ResetPrioBtn  := CreateBtn(L("BtnReset"), "x500 y215 w150", ResetAllPriority)
ClearCacheBtn := CreateBtn(L("BtnClear"), "x500 y255 w150", ClearCache)

ProfileLabel  := MainGui.Add("Text", "x500 y310", L("Profiles"))
ExportBtn     := CreateBtn(L("Export"), "x500 y335 w70", ExportProfile)
ImportBtn     := CreateBtn(L("Import"), "x579 y335 w71", ImportProfile)

SaveBtn        := CreateBtn(L("Save"), "x500 y385 w150", SaveConfig)
LaunchBtn      := CreateBtn(L("Launch"), "x500 y425 w150", LaunchGame)

MainGui.SetFont("s10 w600")
StatusText     := MainGui.Add("Text", "x25 y465 w450", "...")

UpdateTooltips()
MainGui.OnEvent("Size", MainGui_Size)
MainGui.OnEvent("Close", (*) => ExitApp())

OnMessage(0x0200, OnMouseMove) 
OnMessage(0x020A, WM_MOUSEWHEEL)

LoadConfig()
MainGui.Show("w750 h515")

; --- 3. Функции ---

; Функция для правильной сортировки при клике на колонку "Размер"
LV_ColClick(thisLV, colIndex) {
    if (colIndex = 5) { ; Индекс колонки "Размер"
        static rev := false
        rev := !rev
        thisLV.ModifyCol(6, "Sort" (rev ? "Desc" : "") " Integer") ; Сортируем по скрытой 6-й колонке
        return 
    }
}

UpdateTooltips() {
    global Tooltips
    Tooltips := Map(
        PrioEdit.Hwnd, L("TT_Prio"),
        PrioUpDown.Hwnd, L("TT_Prio"),
        ToggleAllBtn.Hwnd, L("TT_Toggle"),
        ResetPrioBtn.Hwnd, L("TT_Reset"),
        ClearCacheBtn.Hwnd, L("TT_Clear"),
        ExportBtn.Hwnd, L("TT_Export"),
        ImportBtn.Hwnd, L("TT_Import"),
        SaveBtn.Hwnd, L("TT_Save"),
        LaunchBtn.Hwnd, L("TT_Launch")
    )
}

UpdateMenu() {
    ModMenu.Delete()
    ModMenu.Add(L("Open"), (*) => (row := LV.GetNext(), row && (p := ModsFolder "\" LV.GetText(row, 2), FileExist(p) && Run('"' p '"'))))
    ModMenu.Add(L("ShowInFolder"), (*) => (row := LV.GetNext(), row && (p := ModsFolder "\" LV.GetText(row, 2), FileExist(p) && Run('explorer.exe /select,"' p '"'))))
    ModMenu.Add()
    ModMenu.Add(L("DeleteMod"), Menu_DeleteMod)
}

ToggleLanguage(*) {
    global CurrentLang := (CurrentLang = "RU") ? "EN" : "RU"
    LangBtn.Text := "🌐 " CurrentLang
    MainGui.Title := L("Title")
    PrioLabel.Text := L("PrioLabel")
    ActionLabel.Text := L("MassActions")
    ToggleAllBtn.Text := L("BtnToggle")
    ResetPrioBtn.Text := L("BtnReset")
    ClearCacheBtn.Text := L("BtnClear")
    ProfileLabel.Text := L("Profiles")
    ExportBtn.Text := L("Export")
    ImportBtn.Text := L("Import")
    SaveBtn.Text := L("Save")
    LaunchBtn.Text := L("Launch")
    
    LV.ModifyCol(1, , L("ColStatus")), LV.ModifyCol(2, , L("ColMod")), LV.ModifyCol(3, , L("ColPrio")), LV.ModifyCol(4, , L("ColDate")), LV.ModifyCol(5, , L("ColSize"))
    
    LV.Opt("-Redraw")
    Loop LV.GetCount() {
        isChecked := (LV.GetNext(A_Index - 1, "Checked") = A_Index)
        LV.Modify(A_Index, "Col1", isChecked ? L("ModOn") : L("ModOff"))
    }
    LV.Opt("+Redraw")
    
    UpdateMenu()
    UpdateTooltips()
    UpdateCounts()
}

OnPrioChange(*) {
    static isProcessing := false
    if (isProcessing || !(row := LV.GetNext())) {
        return
    }
    isProcessing := true
    val := Clamp(Number(PrioEdit.Value || 0), -100, 100)
    if (PrioEdit.Value != val) {
        PrioEdit.Value := val
    }
    LV.Modify(row, "Col3", String(val))
    isProcessing := false
}

Clamp(val, min, max) => (val < min ? min : (val > max ? max : val))

WM_MOUSEWHEEL(wParam, lParam, msg, hwnd) {
    if (hwnd = PrioEdit.Hwnd || hwnd = PrioUpDown.Hwnd) {
        step := (wParam >> 16 > 0x7FFF) ? -1 : 1
        PrioUpDown.Value := Clamp(PrioUpDown.Value + step, -100, 100)
        OnPrioChange()
        return 0
    }
}

LoadConfig(customPath := "") {
    path := customPath ? customPath : ConfigPath
    LV.Delete()
    FileOrder := [], FileContent := Map()

    if FileExist(path) {
        content := FileRead(path, "UTF-8"), section := ""
        loop parse, content, "`n", "`r" {
            line := Trim(A_LoopField)
            if (line = "" || SubStr(line, 1, 1) = ";") {
                continue 
            }
            if (SubStr(line, 1, 1) = "[") {
                section := InStr(line, "enabled") ? "enabled" : (InStr(line, "priority") ? "priority" : "")
                continue 
            }
            if (section && InStr(line, "=")) {
                parts := StrSplit(line, "=",, 2)
                name := Trim(parts[1], ' "'), val := Trim(parts[2])
                if !FileContent.Has(name) {
                    FileContent[name] := {enabled: "false", priority: "0"}
                    FileOrder.Push(name)
                }
                FileContent[name].%section% := val
            }
        }
    }

    loop files, ModsFolder "\*.*" {
        if !FileContent.Has(A_LoopFileName) {
            FileContent[A_LoopFileName] := {enabled: "false", priority: "0"}
            FileOrder.Push(A_LoopFileName)
        }
    }

    LV.Opt("-Redraw")
    for name in FileOrder {
        fPath := ModsFolder "\" name
        if FileExist(fPath) {
            info := FileContent[name]
            rawSize := FileGetSize(fPath)
            szStr := FormatBytes(rawSize)
            dtStr := FormatTime(FileGetTime(fPath, "M"), "dd.MM.yyyy HH:mm")
            ; Добавляем rawSize в 6-ю колонку
            LV.Add((info.enabled = "true" ? "Check" : ""), (info.enabled = "true" ? L("ModOn") : L("ModOff")), name, info.priority, dtStr, szStr, rawSize)
        }
    }
    Loop 5 {
        LV.ModifyCol(A_Index, "AutoHdr")
    }
    LV.ModifyCol(6, 0) ; Скрываем колонку с байтами
    LV.Opt("+Redraw")
    UpdateCounts()
}

FormatBytes(n) {
    u := L("Bytes"), i := 1, n := Float(n)
    while (n >= 1024 && i < u.Length) {
        n /= 1024
        i++
    }
    return Round(n, 1) " " u[i]
}

UpdateCounts() {
    total := LV.GetCount(), enabled := 0
    loop total {
        if (LV.GetNext(A_Index - 1, "Checked") = A_Index) {
            enabled++
        }
    }
    StatusText.Value := L("Total") total L("Enabled") enabled
}

ToggleAllMods(*) {
    static allChecked := false
    allChecked := !allChecked
    st := allChecked ? "Check" : "-Check"
    txt := allChecked ? L("ModOn") : L("ModOff")
    LV.Opt("-Redraw")
    loop LV.GetCount() {
        LV.Modify(A_Index, st, txt)
    }
    LV.Opt("+Redraw")
    UpdateCounts()
}

ResetAllPriority(*) {
    LV.Opt("-Redraw")
    loop LV.GetCount() {
        LV.Modify(A_Index, "Col3", "0") 
    }
    LV.Opt("+Redraw")
    PrioUpDown.Value := 0
}

ClearCache(*) {
    targets := ["logs", "vmz_mount_cache", "shader_cache", "vulkan"], count := 0
    for folder in targets {
        p := AppDataFolder "\" folder
        if DirExist(p) {
            try {
                DirDelete(p, 1)
                count++
            }
        }
    }
    if FileExist(f := AppDataFolder "\modloader_conflicts.txt") {
        FileDelete(f)
        count++
    }
    MsgBox(count > 0 ? L("CacheClean") : L("CacheNone"), "Info", "Iconi T2")
}

GenerateCurrentConfig() {
    t1 := "[enabled]`r`n", t2 := "`r`n[priority]`r`n"
    loop LV.GetCount() {
        name := LV.GetText(A_Index, 2), prio := LV.GetText(A_Index, 3)
        isChecked := (LV.GetNext(A_Index - 1, "Checked") = A_Index)
        enabledVal := isChecked ? "true" : "false"
        lineKey := (InStr(name, " ") ? '"' name '"' : name) "="
        t1 .= lineKey enabledVal "`r`n", t2 .= lineKey prio "`r`n"
    }
    return t1 t2
}

SaveConfig(*) {
    try {
        if !DirExist(AppDataFolder) {
            DirCreate(AppDataFolder)
        }
        if FileExist(ConfigPath) {
            FileDelete(ConfigPath)
        }
        FileAppend(GenerateCurrentConfig(), ConfigPath, "UTF-8-RAW")
        return true
    } catch Error as e {
        MsgBox("Error: " e.Message)
        return false
    }
}

LaunchGame(*) {
    if !SaveConfig() {
        return
    }
    if ProcessExist("steam.exe") {
        Run("steam://rungameid/1963610")
    } else if FileExist(A_ScriptDir "\RTV.exe") {
        Run('"' A_ScriptDir '\RTV.exe"')
    }
}

ExportProfile(*) {
    if (f := FileSelect("S16", SMMFolder "\profile.cfg", L("Export"), "Config (*.cfg)")) {
        FileOpen(f, "w", "UTF-8-RAW").Write(GenerateCurrentConfig())
    }
}

ImportProfile(*) {
    if (f := FileSelect(3, SMMFolder, L("Import"), "Config (*.cfg)")) {
        LoadConfig(f)
    }
}

Menu_DeleteMod(*) {
    if !(row := LV.GetNext()) {
        return
    }
    modName := LV.GetText(row, 2)
    if MsgBox(L("DelConfirm") "`n`n" modName, "Confirm", "YesNo Icon!") = "Yes" {
        try {
            FileDelete(ModsFolder "\" modName)
            LV.Delete(row)
            UpdateCounts()
        }
    }
}

MainGui_Size(thisGui, minMax, width, height) {
    if (minMax == -1) {
        return
    }
    panelX := width - 180, newLVW := width - 220, newLVH := height - 135
    LV.Move(,, newLVW, newLVH)
    for ctrl in [PrioLabel, PrioEdit, ActionLabel, ToggleAllBtn, ResetPrioBtn, ClearCacheBtn, ProfileLabel, ExportBtn] {
        ctrl.Move(panelX)
    }
    PrioUpDown.Move(panelX + 60), ImportBtn.Move(panelX + 79)
    SaveBtn.Move(panelX, height - 130), LaunchBtn.Move(panelX, height - 90)
    StatusText.Move(25, height - 35, newLVW)
    LangBtn.Move(width - 85) 
    LV.ModifyCol(1, 65), LV.ModifyCol(3, 60), LV.ModifyCol(4, 120), LV.ModifyCol(5, 70), LV.ModifyCol(6, 0)
    LV.ModifyCol(2, Max(100, newLVW - 325)) 
}

CreateBtn(txt, pos, cb) {
    b := MainGui.Add("Text", pos " h35 Background" Color_Btn " cWhite +0x201 +ReadOnly", txt)
    b.OnEvent("Click", cb)
    b.DefineProp("IsHovered", {Value: false}) 
    Buttons.Push(b)
    return b
}

OnMouseMove(wParam, lParam, msg, hwnd) {
    static LastHwnd := 0
    if (hwnd = LastHwnd) {
        return
    }
    LastHwnd := hwnd

    SetTimer(ShowDelayedToolTip, 0)
    ToolTip() 

    for b in Buttons {
        if (b.Hwnd == hwnd) {
            if !b.IsHovered {
                b.Opt("Background" Color_Hover), b.Redraw(), b.IsHovered := true
            }
        } else if (b.IsHovered) {
            b.Opt("Background" Color_Btn), b.Redraw(), b.IsHovered := false
        }
    }

    if Tooltips.Has(hwnd) {
        global PendingToolTipText := Tooltips[hwnd]
        SetTimer(ShowDelayedToolTip, -800)
    }
}

ShowDelayedToolTip() {
    ToolTip(PendingToolTipText)
}