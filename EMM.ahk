#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

global AppDataFolder := EnvGet("APPDATA") "\Road to Vostok"
global ConfigPath    := AppDataFolder "\mod_config.cfg"
global Color_BG      := "1E1E1E"
global Color_Btn     := "333333"
global Color_Hover    := "444444"
global Color_Text     := "FFFFFF"
global Buttons        := []
global RightPanel     := [] 

if !FileExist(A_ScriptDir "\RTV.exe") {
    MsgBox("Error: RTV.exe not found.`n`nPlease place the manager in the game folder.", "Error", "IconX")
    ExitApp()
}

if !FileExist(A_ScriptDir "\modloader.gd") {
    Result := MsgBox("Mod loader (modloader.gd) not detected.`n`nGo to download page?", "File Not Found", "YesNo Icon?")
    if (Result = "Yes")
        Run("https://modworkshop.net/mod/55623")
    ExitApp()
}

if !DirExist(AppDataFolder)
    DirCreate(AppDataFolder)

MainGui := Gui("+Resize -DPIScale", "External Mod Manager: Road to Vostok v1.1")
MainGui.BackColor := Color_BG
MainGui.SetFont("c" Color_Text " s10", "Segoe UI")

if VerCompare(A_OSVersion, "10.0.17763") >= 0
    DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", MainGui.Hwnd, "Int", 20, "Int*", 1, "Int", 4)

global LV := MainGui.Add("ListView", "x15 y15 w550 h440 +Grid -Multi +Checked Background" Color_Btn " c" Color_Text, ["", "Mod Name", "Version", "Priority"])
LV.OnEvent("DoubleClick", EditPriority)
LV.OnEvent("ItemCheck", (*) => UpdateCounts())
LV.OnEvent("ColClick", LV_SortByCheck) 
DllCall("uxtheme\SetWindowTheme", "Ptr", LV.Hwnd, "Str", "Explorer", "Ptr", 0)

global StatusText := MainGui.Add("Text", "x15 y460 w550", "Total Mods: 0 | Enabled: 0")
xCol := 580 

RightPanel.Push(MainGui.Add("Text", "x" xCol " y18 w180", "Profiles:")) 
global ProfileDDL := MainGui.Add("DropDownList", "x" xCol " y45 w180 Background" Color_Btn " cWhite")
ProfileDDL.OnEvent("Change", (*) => LoadProfileData())
RightPanel.Push(ProfileDDL) 

RightPanel.Push(CreateBtn("+", "x" xCol " y80 w55", CreateProfile)) 
RightPanel.Push(CreateBtn("✎", "x" xCol + 62 " y80 w56", RenameProfile)) 
RightPanel.Push(CreateBtn("✘", "x" xCol + 125 " y80 w55", DeleteProfile)) 

RightPanel.Push(CreateBtn("Save Config", "x" xCol " y120 w180", (*) => SaveProfileData())) 
RightPanel.Push(MainGui.Add("Text", "x" xCol " y170 w180 h2 0x10")) 
RightPanel.Push(MainGui.Add("Text", "x" xCol " y185 w180", "Bulk Actions:")) 
RightPanel.Push(CreateBtn("Toggle All", "x" xCol " y210 w180", ToggleAllMods)) 
RightPanel.Push(CreateBtn("Reset Priority", "x" xCol " y245 w180", ResetAllPriority)) 
RightPanel.Push(CreateBtn("Clear Cache", "x" xCol " y280 w180", ClearCache)) 

global CB_IngameUI := MainGui.Add("Checkbox", "x" xCol " y340 w180 cWhite", "Ingame Mod UI")
global LaunchBtn := CreateBtn("LAUNCH GAME", "x" xCol " y370 w180 h50", LaunchGame)

MainGui.OnEvent("Size", MainGui_Size) 
OnMessage(0x0200, OnMouseMove)
LoadProfiles()
MainGui.Show("w780 h500")

MainGui_Size(GuiObj, WindowMinMax, Width, Height) {
    if (WindowMinMax = -1)
        return
    lvW := Width - 230
    lvH := Height - 60 
    LV.Move(,, lvW, lvH)
    LV.GetPos(&lvX, &lvY, &lvW, &lvH)
    lvBottom := lvY + lvH
    StatusText.Move(15, lvBottom + 5, lvW)
    LV.ModifyCol(2, Max(100, lvW - 220))
    newX := Width - 200
    panelW := 180
    LaunchBtn.Move(newX, lvBottom - 50, panelW, 50)
    CB_IngameUI.Move(newX, lvBottom - 80, panelW)
    for i, ctrl in RightPanel {
        if (i == 3)      
            ctrl.Move(newX)
        else if (i == 4) 
            ctrl.Move(newX + 62)
        else if (i == 5) 
            ctrl.Move(newX + 125)
        else              
            ctrl.Move(newX, , panelW)
    }
}

LaunchGame(*) {
    SaveProfileData()
    params := (CB_IngameUI.Value == 0) ? " -- --modloader-restart" : ""
    if (ProcessExist("steam.exe"))
        Run("steam://run/1963610//" params)
    else if (FileExist(A_ScriptDir "\RTV.exe"))
        Run('"' A_ScriptDir '\RTV.exe"' params)
}

SaveProfileData(*) {
    Selected := ProfileDDL.Text
    if (Selected == "")
        return
    IniWrite('"' Selected '"', ConfigPath, "settings", "active_profile")
    IniWrite(CB_IngameUI.Value, ConfigPath, "settings", "ingame_ui")
    try {
        IniDelete(ConfigPath, "profile." Selected ".enabled")
        IniDelete(ConfigPath, "profile." Selected ".priority")
    }
    Loop LV.GetCount() {
        IsChecked := (SendMessage(0x102C, A_Index-1, 0xF000, LV.Hwnd) >> 12 == 2)
        Status := IsChecked ? "true" : "false"
        ModName := LV.GetText(A_Index, 2), ModVer := LV.GetText(A_Index, 3), Pri := LV.GetText(A_Index, 4)
        FullMod := ModName (ModVer ? "@" ModVer : "")
        IniWrite(Status, ConfigPath, "profile." Selected ".enabled", FullMod)
        IniWrite(Pri, ConfigPath, "profile." Selected ".priority", FullMod)
    }
    UpdateCounts()
}

LoadProfiles() {
    ProfileDDL.Delete()
    if (!FileExist(ConfigPath))
        return
    try {
        CB_IngameUI.Value := IniRead(ConfigPath, "settings", "ingame_ui", "1")
        Sections := IniRead(ConfigPath), Profiles := []
        CurrentActive := StrReplace(IniRead(ConfigPath, "settings", "active_profile", ""), '"', "")
        Loop Parse, Sections, "`n", "`r"
            if RegExMatch(A_LoopField, "i)^profile\.(.+)\.enabled$", &Match)
                Profiles.Push(Match[1])
        if (Profiles.Length > 0) {
            ProfileDDL.Add(Profiles)
            ChosenIndex := 1
            for i, name in Profiles
                if (name = CurrentActive) {
                    ChosenIndex := i
                    break
                }
            ProfileDDL.Choose(ChosenIndex), LoadProfileData()
        }
    }
}

LoadProfileData() {
    LV.Delete()
    Selected := ProfileDDL.Text
    if (Selected == "" || !FileExist(ConfigPath))
        return
    try {
        EnabledData := IniRead(ConfigPath, "profile." Selected ".enabled")
        PriorityData := IniRead(ConfigPath, "profile." Selected ".priority")
    } catch {
        UpdateCounts()
        return
    }
    Priorities := Map()
    Loop Parse, PriorityData, "`n", "`r"
        if (Parts := StrSplit(A_LoopField, "=")).Length == 2
            Priorities[Parts[1]] := Parts[2]
    LV.Opt("-Redraw")
    Loop Parse, EnabledData, "`n", "`r" {
        if (Parts := StrSplit(A_LoopField, "=")).Length == 2 {
            FullMod := Parts[1], Status := Parts[2]
            RegExMatch(FullMod, "^(.*)@(.*)$", &Match) ? (ModName := Match[1], ModVer := Match[2]) : (ModName := FullMod, ModVer := "")
            Pri := Priorities.Has(FullMod) ? Priorities[FullMod] : "0"
            LV.Add((Status = "true" ? "Check" : ""), "", ModName, ModVer, Pri)
        }
    }
    LV.ModifyCol(1, 30), LV.ModifyCol(2, 250), LV.ModifyCol(3, 100), LV.ModifyCol(4, 80)
    LV.Opt("+Redraw"), UpdateCounts()
}

LV_SortByCheck(GuiCtrl, ColIndex) {
    if (ColIndex == 1) { 
        static Reverse := false
        Reverse := !Reverse, GuiCtrl.Opt("-Redraw"), Rows := []
        Loop GuiCtrl.GetCount() {
            IsChecked := (SendMessage(0x102C, A_Index-1, 0xF000, GuiCtrl.Hwnd) >> 12 == 2)
            Rows.Push({Checked: IsChecked, Name: GuiCtrl.GetText(A_Index, 2), Ver: GuiCtrl.GetText(A_Index, 3), Pri: GuiCtrl.GetText(A_Index, 4)})
        }
        Loop Rows.Length {
            i := A_Index
            Loop Rows.Length - i {
                j := A_Index
                Condition := Reverse ? (Rows[j].Checked < Rows[j+1].Checked) : (Rows[j].Checked > Rows[j+1].Checked)
                if (Condition)
                    Temp := Rows[j], Rows[j] := Rows[j+1], Rows[j+1] := Temp
            }
        }
        GuiCtrl.Delete()
        for row in Rows
            GuiCtrl.Add((row.Checked ? "Check" : ""), "", row.Name, row.Ver, row.Pri)
        GuiCtrl.ModifyCol(1, 30), GuiCtrl.ModifyCol(2, 250), GuiCtrl.ModifyCol(3, 100), GuiCtrl.ModifyCol(4, 80)
        GuiCtrl.Opt("+Redraw"), UpdateCounts()
    }
}

CreateProfile(*) {
    res := CustomInput("New Profile", "Enter profile name:")
    if (res.Status = "Cancel" || res.Value = "")
        return
    ProfileDDL.Add([res.Value]), ProfileDDL.Choose(res.Value), SaveProfileData()
}

RenameProfile(*) {
    oldProf := ProfileDDL.Text
    if (oldProf = "")
        return
    res := CustomInput("Rename", "New name:", oldProf)
    if (res.Status = "Cancel" || res.Value = "" || res.Value = oldProf)
        return
    try {
        enData := IniRead(ConfigPath, "profile." oldProf ".enabled"), prData := IniRead(ConfigPath, "profile." oldProf ".priority")
        IniWrite(enData, ConfigPath, "profile." res.Value ".enabled"), IniWrite(prData, ConfigPath, "profile." res.Value ".priority")
        IniDelete(ConfigPath, "profile." oldProf ".enabled"), IniDelete(ConfigPath, "profile." oldProf ".priority")
        LoadProfiles(), ProfileDDL.Choose(res.Value)
    }
}

DeleteProfile(*) {
    current := ProfileDDL.Text
    if (current = "" || MsgBox("Delete profile?", "Confirm", "YesNo") = "No")
        return
    IniDelete(ConfigPath, "profile." current ".enabled"), IniDelete(ConfigPath, "profile." current ".priority"), LoadProfiles()
}

EditPriority(GuiCtrl, RowNum) {
    if (!RowNum)
        return
    ModName := GuiCtrl.GetText(RowNum, 2), Pri := GuiCtrl.GetText(RowNum, 4)
    res := CustomInput("Priority", "Priority for " ModName, Pri)
    if (res.Status = "OK")
        GuiCtrl.Modify(RowNum, "Col4", res.Value)
}

CustomInput(Title, Prompt, DefaultValue := "") {
    InputGui := Gui("+ToolWindow +Owner" MainGui.Hwnd, Title)
    InputGui.BackColor := Color_BG
    InputGui.SetFont("cWhite s10", "Segoe UI")
    InputGui.Add("Text", "w250", Prompt)
    EditCtrl := InputGui.Add("Edit", "w250 Background333333 cWhite", DefaultValue)
    Result := {Value: "", Status: "Cancel"}
    BtnOk := InputGui.Add("Button", "w120 Default", "OK")
    BtnOk.OnEvent("Click", (*) => (Result.Value := EditCtrl.Value, Result.Status := "OK", InputGui.Destroy()))
    BtnCn := InputGui.Add("Button", "x+10 w120", "Cancel")
    BtnCn.OnEvent("Click", (*) => (InputGui.Destroy()))
    InputGui.Show("Center"), WinWaitClose(InputGui)
    return Result
}

CreateBtn(txt, pos, cb) {
    actualPos := InStr(pos, " h") ? pos : pos " h28"
    b := MainGui.Add("Text", actualPos " Background" Color_Btn " cWhite +0x201 +ReadOnly", txt)
    b.OnEvent("Click", cb), b.DefineProp("IsHovered", {Value: false}), Buttons.Push(b)
    return b
}

OnMouseMove(wParam, lParam, msg, hwnd) {
    for b in Buttons {
        if (b.Hwnd == hwnd) {
            if !b.IsHovered
                b.Opt("Background" Color_Hover), b.Redraw(), b.IsHovered := true
        } else if (b.IsHovered)
            b.Opt("Background" Color_Btn), b.Redraw(), b.IsHovered := false
    }
}

ToggleAllMods(*) {
    static allChecked := false
    allChecked := !allChecked, LV.Opt("-Redraw")
    Loop LV.GetCount()
        LV.Modify(A_Index, (allChecked ? "Check" : "-Check"))
    LV.Opt("+Redraw"), UpdateCounts()
}

ResetAllPriority(*) {
    LV.Opt("-Redraw")
    Loop LV.GetCount()
        LV.Modify(A_Index, "Col4", "0")
    LV.Opt("+Redraw")
}

ClearCache(*) {
    targetFolders := ["logs", "vmz_mount_cache", "shader_cache", "vulkan", "modloader_hooks"]
    targetFiles := ["modloader_filescope.log", "mod_pass_state.cfg"]
    for folder in targetFolders {
        p := AppDataFolder "\" folder
        if (DirExist(p))
            try DirDelete(p, 1)
    }
    for file in targetFiles {
        p := AppDataFolder "\" file
        if (FileExist(p))
            try FileDelete(p)
    }
    MsgBox("Cache cleared.")
}

UpdateCounts() {
    total := LV.GetCount(), enabled := 0
    loop total
        if (SendMessage(0x102C, A_Index-1, 0xF000, LV.Hwnd) >> 12 == 2)
            enabled++
    StatusText.Value := "Total Mods: " total " | Enabled: " enabled
}
