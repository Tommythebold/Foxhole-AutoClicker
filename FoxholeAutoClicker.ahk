#Requires AutoHotkey v2.0
#SingleInstance Force

;@Ahk2Exe-SetMainIcon AutoClicker2Icon.ico
;@Ahk2Exe-SetName Foxhole Autoclicker
;@Ahk2Exe-SetDescription Foxhole Autoclicker 2.0
;@Ahk2Exe-SetProductName Foxhole Autoclicker
;@Ahk2Exe-SetVersion 2.0.1
;@Ahk2Exe-SetProductVersion 2.0.1

global AppVersion := "2.0.1"
global NormalWindowTitle := "Foxhole Autoclicker " AppVersion
global UpdateWindowTitle := NormalWindowTitle " - Update Available"
global GitHubLatestReleaseApi := "https://api.github.com/repos/Tommythebold/Foxhole-AutoClicker/releases/latest"

global TargetWindow := "ahk_class UnrealWindow"

global AutoWalkActive := false
global AutoReverseActive := false
global AutoClickActive := false
global ClickHoldActive := false
global RightHoldActive := false
global VSpamActive := false
global TrainSlowActive := false
global TrainSlowInterval := 300
global TrainSlowDefaultInterval := 300
global AutoClickInterval := 50
global AutoClickDefaultInterval := 50
global AutoClickPaused := false
global TrainSlowHoldDuration := 200

global TooltipsEnabled := true

global UiTooltipsEnabled := true

global LaunchMinimized := false

global ClickX := 0
global ClickY := 0

global DefaultClickX := 0
global DefaultClickY := 0

global RuntimeAssetDir := A_IsCompiled ? A_Temp "\FoxholeAutoclicker-" DllCall("GetCurrentProcessId", "UInt") : A_ScriptDir

if A_IsCompiled
{
    if !DirExist(RuntimeAssetDir)
        DirCreate(RuntimeAssetDir)

    trayIconPath := RuntimeAssetDir "\AutoClicker2Icon.ico"
    FileInstall "AutoClicker2Icon.ico", trayIconPath, 1
    TraySetIcon(trayIconPath)
}
else
{

    localIconPath := A_ScriptDir "\AutoClicker2Icon.ico"
    if FileExist(localIconPath)
        TraySetIcon(localIconPath)
}

global BannerDefinitions := [
    {fileName: "Airborne.png", displayName: "Airborne"},
    {fileName: "Entrenched.png", displayName: "Entrenched"},
    {fileName: "Naval.png", displayName: "Naval"},
    {fileName: "Inferno.png", displayName: "Inferno"},
    {fileName: "TrenchWarfare.png", displayName: "Trench Warfare"},
    {fileName: "WarMachine.png", displayName: "War Machine"},
    {fileName: "WinterArmy.png", displayName: "Winter Army"}
]
global AvailableBanners := []
global BannerAssetDir := ""
global BannerPicture := ""
global BannerDropDown := ""
global BannerDynamicControls := []
global CurrentBannerFile := ""
global BannerVisible := false
global BannerShift := 0
global BannerControlBaseY := Map()
global BannerGuiHeightHidden := 0
global BannerGuiHeightVisible := 0
global BannerLayoutChanging := false
global BannerSelection := "Random Cycle"
global TopMessageControl := ""
global TopMessageIndex := 1
global TopMessages := [
    "Rebind keys below. Hover over elements for info.",
    "Disable Epic Overlay/Launcher, blocks AutoHotKey.",
    "Contact Tommythebold on Discord for support.",
    'View the project on <a href="https://github.com/Tommythebold/Foxhole-AutoClicker">Github</a>.'
]

global ActionNames := ["AutoClick", "AutoWalk", "AutoReverse", "ClickHold", "RightHold", "VSpam", "TrainSlow"]
global DefaultKeys := Map(
    "AutoClick", "F2",
    "AutoWalk", "F3",
    "AutoReverse", "F4",
    "ClickHold", "F5",
    "RightHold", "F6",
    "VSpam", "F7",
    "TrainSlow", "F9"
)
global ActionLabels := Map(
    "AutoClick", "Auto-Clicker",
    "AutoWalk", "Forward",
    "AutoReverse", "Reverse",
    "ClickHold", "Hold Left Click",
    "RightHold", "Hold Right Click",
    "VSpam", "Spam V Key",
    "TrainSlow", "Train Slow"
)
global ActionDescriptions := Map(
    "AutoClick", "Toggles background left-clicking at the cursor position. Works for no-rotation hammering too. Use Shift+Scroll to adjust the interval, max interval will pause it.",
    "AutoWalk", "Toggles background W key presses to drive forward.",
    "AutoReverse", "Toggles background S key presses to drive backward.",
    "ClickHold", "Toggles holding left mouse for harvesters and CV's.",
    "RightHold", "Toggles holding right mouse button for binoculars and crane rotation.",
    "VSpam", "Toggles background V key presses. For submitting large items.",
    "TrainSlow", "Toggles timed W key presses. Use Shift+Scroll to adjust the interval."
)
global CurrentKeys := Map()

global SettingsDir := A_AppData "\Foxhole Autoclicker"
global SettingsFile := SettingsDir "\FoxholeKeys.ini"

if !DirExist(SettingsDir)
    DirCreate(SettingsDir)

global ActionHandlers := Map(
    "AutoClick", Hotkey_AutoClick,
    "AutoWalk", Hotkey_AutoWalk,
    "AutoReverse", Hotkey_AutoReverse,
    "ClickHold", Hotkey_ClickHold,
    "RightHold", Hotkey_RightHold,
    "VSpam", Hotkey_VSpam,
    "TrainSlow", Hotkey_TrainSlow
)

global RebindGui := ""
global RebindButtons := Map()
global RebindResetButtons := Map()
global HelpControls := Map()
global HoveredHelpHwnd := 0
global ListeningForAction := ""
global StatusCtrl := ""
global PollKeyList := []

LoadKeybinds()
PrepareBannerAssets()
ApplyAllHotkeys()
BuildGui()
TraySetup()
ApplyStartupWindowState()
SetTimer(CheckForUpdate, -1000)

LoadKeybinds()
{
    global ActionNames, DefaultKeys, CurrentKeys, SettingsFile, DefaultClickX, DefaultClickY, TooltipsEnabled, UiTooltipsEnabled, LaunchMinimized, TrainSlowInterval, AutoClickInterval, BannerSelection

    for actionName in ActionNames
    {
        savedKey := IniRead(SettingsFile, "Keybinds", actionName, DefaultKeys[actionName])
        CurrentKeys[actionName] := savedKey
    }

    DefaultClickX := Integer(IniRead(SettingsFile, "ClickPos", "X", "0"))
    DefaultClickY := Integer(IniRead(SettingsFile, "ClickPos", "Y", "0"))

    TooltipsEnabled := IniRead(SettingsFile, "Settings", "TooltipsEnabled", "1") = "1"
    UiTooltipsEnabled := IniRead(SettingsFile, "Settings", "UiTooltipsEnabled", "1") = "1"
    LaunchMinimized := IniRead(SettingsFile, "Settings", "LaunchMinimized", "0") = "1"
    BannerSelection := Trim(IniRead(SettingsFile, "Settings", "BannerSelection", "Random Cycle"))
    if BannerSelection = ""
        BannerSelection := "Random Cycle"
    TrainSlowInterval := Integer(IniRead(SettingsFile, "Settings", "TrainSlowInterval", TrainSlowDefaultInterval))
    TrainSlowInterval := Max(10, Min(3000, TrainSlowInterval))
    SaveTrainSlowInterval(TrainSlowInterval)

    AutoClickInterval := Integer(IniRead(SettingsFile, "Settings", "AutoClickInterval", AutoClickDefaultInterval))
    AutoClickInterval := Max(10, Min(500, AutoClickInterval))
    SaveAutoClickInterval(AutoClickInterval)
}

SaveTooltipsEnabled(enabled)
{
    global SettingsFile
    IniWrite(enabled ? "1" : "0", SettingsFile, "Settings", "TooltipsEnabled")
}

SaveUiTooltipsEnabled(enabled)
{
    global SettingsFile
    IniWrite(enabled ? "1" : "0", SettingsFile, "Settings", "UiTooltipsEnabled")
}

SaveLaunchMinimized(enabled)
{
    global SettingsFile
    IniWrite(enabled ? "1" : "0", SettingsFile, "Settings", "LaunchMinimized")
}

SaveTrainSlowInterval(interval)
{
    global SettingsFile
    IniWrite(interval, SettingsFile, "Settings", "TrainSlowInterval")
}

SaveAutoClickInterval(interval)
{
    global SettingsFile
    IniWrite(interval, SettingsFile, "Settings", "AutoClickInterval")
}

ShowTooltip(text, durationMs := 1500)
{
    global TooltipsEnabled
    if !TooltipsEnabled
        return
    ToolTip(text)
    SetTimer(() => ToolTip(), -durationMs)
}

SaveKeybind(actionName, keyName)
{
    global SettingsFile
    IniWrite(keyName, SettingsFile, "Keybinds", actionName)
}

ApplyAllHotkeys()
{
    global ActionNames, CurrentKeys, ActionHandlers

    for actionName in ActionNames
    {
        try {
            Hotkey(CurrentKeys[actionName], ActionHandlers[actionName], "On")
        } catch as e {
            ToolTip("Failed to bind " actionName " to " CurrentKeys[actionName] ": " e.Message)
            SetTimer(() => ToolTip(), -3000)
        }
    }
}

PauseAllHotkeys()
{
    global ActionNames, CurrentKeys, ActionHandlers

    for actionName in ActionNames
    {
        try Hotkey(CurrentKeys[actionName], ActionHandlers[actionName], "Off")
    }
}

ResumeAllHotkeys()
{
    global ActionNames, CurrentKeys, ActionHandlers

    for actionName in ActionNames
    {
        try Hotkey(CurrentKeys[actionName], ActionHandlers[actionName], "On")
    }
}

RebindAction(actionName, newKey)
{
    global CurrentKeys, ActionHandlers

    oldKey := CurrentKeys[actionName]

    if (oldKey != "" && oldKey != newKey)
    {
        try Hotkey(oldKey, ActionHandlers[actionName], "Off")
    }

    try {
        Hotkey(newKey, ActionHandlers[actionName], "On")
    } catch as e {
        MsgBox("Could not bind '" newKey "': " e.Message, "Rebind Failed", "Icon!")
        return false
    }

    CurrentKeys[actionName] := newKey
    SaveKeybind(actionName, newKey)
    return true
}

PrepareBannerAssets()
{
    global BannerDefinitions, AvailableBanners, BannerAssetDir, RuntimeAssetDir

    AvailableBanners := []
    BannerAssetDir := A_IsCompiled ? RuntimeAssetDir "\Banners" : A_ScriptDir

    if A_IsCompiled
    {
        if !DirExist(BannerAssetDir)
            DirCreate(BannerAssetDir)

        try
        {
            FileInstall "Airborne.png", BannerAssetDir "\Airborne.png", 1
        }
        try
        {
            FileInstall "Entrenched.png", BannerAssetDir "\Entrenched.png", 1
        }
        try
        {
            FileInstall "Naval.png", BannerAssetDir "\Naval.png", 1
        }
        try
        {
            FileInstall "Inferno.png", BannerAssetDir "\Inferno.png", 1
        }
        try
        {
            FileInstall "TrenchWarfare.png", BannerAssetDir "\TrenchWarfare.png", 1
        }
        try
        {
            FileInstall "WarMachine.png", BannerAssetDir "\WarMachine.png", 1
        }
        try
        {
            FileInstall "WinterArmy.png", BannerAssetDir "\WinterArmy.png", 1
        }
    }

    for banner in BannerDefinitions
    {
        bannerPath := BannerAssetDir "\" banner.fileName
        if FileExist(bannerPath)
            AvailableBanners.Push({fileName: banner.fileName, displayName: banner.displayName, path: bannerPath})
    }
}

FindAvailableBanner(fileName)
{
    global AvailableBanners

    for banner in AvailableBanners
    {
        if StrLower(banner.fileName) = StrLower(fileName)
            return banner
    }

    return ""
}

ChooseStartupBanner()
{
    global BannerSelection, AvailableBanners

    if AvailableBanners.Length = 0 || StrLower(BannerSelection) = "disabled"
        return ""

    if StrLower(BannerSelection) = "random" || StrLower(BannerSelection) = "random cycle"
        return AvailableBanners[Random(1, AvailableBanners.Length)].fileName

    banner := FindAvailableBanner(BannerSelection)
    if IsObject(banner)
        return banner.fileName

    BannerSelection := "Random Cycle"
    return AvailableBanners[Random(1, AvailableBanners.Length)].fileName
}

ChooseDifferentRandomBanner()
{
    global AvailableBanners, CurrentBannerFile

    if AvailableBanners.Length = 0
        return ""
    if AvailableBanners.Length = 1
        return AvailableBanners[1].fileName

    choices := []
    for banner in AvailableBanners
    {
        if StrLower(banner.fileName) != StrLower(CurrentBannerFile)
            choices.Push(banner.fileName)
    }

    return choices[Random(1, choices.Length)]
}

SetAutoClickerBanner(fileName)
{
    global BannerPicture, CurrentBannerFile

    banner := FindAvailableBanner(fileName)
    if !IsObject(banner) || !IsObject(BannerPicture) || !FileExist(banner.path)
        return false

    try
    {
        BannerPicture.Value := banner.path
        BannerPicture.Redraw()
    }
    catch
        return false

    CurrentBannerFile := banner.fileName
    return true
}

SetGuiClientHeight(guiObj, clientHeight)
{

    hwnd := guiObj.Hwnd
    if !DllCall("IsWindow", "ptr", hwnd, "int")
        return false

    windowRect := Buffer(16, 0)
    clientRect := Buffer(16, 0)
    if !DllCall("GetWindowRect", "ptr", hwnd, "ptr", windowRect.Ptr, "int")
        return false
    if !DllCall("GetClientRect", "ptr", hwnd, "ptr", clientRect.Ptr, "int")
        return false

    outerHeight := NumGet(windowRect, 12, "int") - NumGet(windowRect, 4, "int")
    currentClientHeight := NumGet(clientRect, 12, "int")
    nonClientHeight := outerHeight - currentClientHeight
    guiObj.Move(, , , clientHeight + nonClientHeight)
    return true
}

SetAutoClickerBannerVisibility(visible)
{
    global RebindGui, BannerPicture, BannerDynamicControls, BannerVisible, BannerShift
    global BannerControlBaseY, BannerGuiHeightHidden, BannerGuiHeightVisible, BannerLayoutChanging

    if !IsObject(BannerPicture) || visible = BannerVisible || BannerLayoutChanging
        return

    BannerLayoutChanging := true
    guiHwnd := RebindGui.Hwnd
    targetHeight := visible ? BannerGuiHeightVisible : BannerGuiHeightHidden
    targetOffset := visible ? BannerShift : 0

    try
    {

        if DllCall("IsWindow", "ptr", guiHwnd, "int")
            DllCall("SendMessage", "ptr", guiHwnd, "uint", 0x000B, "uptr", 0, "ptr", 0)

        if visible
        {

            SetGuiClientHeight(RebindGui, targetHeight)
            BannerPicture.Visible := true
        }

        for ctrl in BannerDynamicControls
        {
            try
            {
                if BannerControlBaseY.Has(ctrl.Hwnd)
                    ctrl.Move(, BannerControlBaseY[ctrl.Hwnd] + targetOffset)
            }
        }

        if !visible
        {
            BannerPicture.Visible := false
            SetGuiClientHeight(RebindGui, targetHeight)
        }

        BannerVisible := visible
    }
    finally
    {

        if DllCall("IsWindow", "ptr", guiHwnd, "int")
        {
            DllCall("SendMessage", "ptr", guiHwnd, "uint", 0x000B, "uptr", 1, "ptr", 0)

            DllCall("RedrawWindow", "ptr", guiHwnd, "ptr", 0, "ptr", 0, "uint", 0x185)
        }
        BannerLayoutChanging := false
    }
}

AutoClickerBannerSelectionChanged(ctrl, *)
{
    global BannerSelection, AvailableBanners, SettingsFile

    if !IsObject(ctrl) || ctrl.Value < 1
        return

    if ctrl.Value = 1
    {
        BannerSelection := "Disabled"
        SetAutoClickerBannerVisibility(false)
    }
    else if ctrl.Value = 2
    {
        BannerSelection := "Random"
        if AvailableBanners.Length > 0
        {
            SetAutoClickerBanner(AvailableBanners[Random(1, AvailableBanners.Length)].fileName)
            SetAutoClickerBannerVisibility(true)
        }
    }
    else if ctrl.Value = 3
    {
        BannerSelection := "Random Cycle"
        if AvailableBanners.Length > 0
        {
            SetAutoClickerBanner(ChooseDifferentRandomBanner())
            SetAutoClickerBannerVisibility(true)
        }
    }
    else
    {
        bannerIndex := ctrl.Value - 3
        if bannerIndex < 1 || bannerIndex > AvailableBanners.Length
            return

        BannerSelection := AvailableBanners[bannerIndex].fileName
        SetAutoClickerBanner(AvailableBanners[bannerIndex].fileName)
        SetAutoClickerBannerVisibility(true)
    }

    IniWrite(BannerSelection, SettingsFile, "Settings", "BannerSelection")
}

RotateTopContent(*)
{
    global BannerSelection, AvailableBanners, TopMessageControl, TopMessageIndex, TopMessages

    if StrLower(BannerSelection) = "random cycle" && AvailableBanners.Length > 0
    {
        SetAutoClickerBanner(ChooseDifferentRandomBanner())
        SetAutoClickerBannerVisibility(true)
    }

    if IsObject(TopMessageControl) && TopMessages.Length > 0
    {
        TopMessageIndex := Mod(TopMessageIndex, TopMessages.Length) + 1
        TopMessageControl.Text := TopMessages[TopMessageIndex]
    }
}

BuildGui()
{
    global ActionNames, ActionLabels, ActionDescriptions, CurrentKeys, RebindGui, RebindButtons, RebindResetButtons, NormalWindowTitle
    global HelpControls, StatusCtrl, DefaultClickX, DefaultClickY, TooltipsEnabled, UiTooltipsEnabled, LaunchMinimized
    global AvailableBanners, BannerPicture, BannerDropDown, BannerDynamicControls
    global CurrentBannerFile, BannerVisible, BannerShift, BannerSelection
    global BannerControlBaseY, BannerGuiHeightHidden, BannerGuiHeightVisible, BannerLayoutChanging
    global TopMessageControl, TopMessageIndex, TopMessages

    padding := 20
    contentW := 380
    winW := contentW + (padding * 2)
    bannerHeight := Round(contentW * (206 / 679))
    bannerGap := 15
    BannerShift := bannerHeight + bannerGap
    BannerDynamicControls := []
    BannerControlBaseY := Map()
    BannerLayoutChanging := false

    RebindGui := Gui("-AlwaysOnTop", NormalWindowTitle)
    RebindGui.SetFont("s10", "Segoe UI")

    y := padding
    BannerPicture := ""
    BannerVisible := false
    CurrentBannerFile := ""

    if AvailableBanners.Length > 0
    {
        CurrentBannerFile := ChooseStartupBanner()
        initialBanner := CurrentBannerFile != "" ? FindAvailableBanner(CurrentBannerFile) : AvailableBanners[1]
        if IsObject(initialBanner)
        {

            try
            {
                BannerPicture := RebindGui.AddPicture("x" padding " y" y " w" contentW " h" bannerHeight, initialBanner.path)
                CurrentBannerFile := initialBanner.fileName
                BannerVisible := CurrentBannerFile != ""
            }
            catch
            {

                BannerPicture := RebindGui.AddPicture("x" padding " y" y " w" contentW " h" bannerHeight)
                BannerVisible := false
                CurrentBannerFile := ""
            }

            HelpControls[BannerPicture.Hwnd] := "Decorative banner. Use the Banner dropdown beside Tooltips On? to disable it, cycle images, or select a specific image."
            BannerPicture.Visible := BannerVisible
            if BannerVisible
                y += BannerShift
        }
    }

    TopMessageIndex := 1
    TopMessageControl := RebindGui.Add("Link", "x" padding " y" y " w" contentW " h24 Center", TopMessages[TopMessageIndex])
    BannerDynamicControls.Push(TopMessageControl)
    HelpControls[TopMessageControl.Hwnd] := "Cycles through setup guidance, support information, and the project link every 10 seconds."

    y += 34
    for actionName in ActionNames
    {
        label := ActionLabels[actionName]
        keyText := DisplayNameForHotkeyString(CurrentKeys[actionName])

        labelCtrl := RebindGui.AddText("x" (padding + 20) " y" y " w95 Right", label)
        HelpControls[labelCtrl.Hwnd] := ActionDescriptions[actionName]
        BannerDynamicControls.Push(labelCtrl)

        btn := RebindGui.AddButton("x" (padding + 120) " y" (y - 4) " w185 h30", "Rebind: " keyText)
        btn.OnEvent("Click", MakeRebindHandler(actionName))
        RebindButtons[actionName] := btn
        HelpControls[btn.Hwnd] := "Click to assign a new hotkey for " label ". After clicking, press the key or key combination you want to use; press Escape to cancel."
        BannerDynamicControls.Push(btn)

        resetBtn := RebindGui.AddButton("x" (padding + 305) " y" (y - 4) " w65 h30", "Reset")
        resetBtn.OnEvent("Click", MakeResetHandler(actionName))
        RebindResetButtons[actionName] := resetBtn
        HelpControls[resetBtn.Hwnd] := "Restore " label " to its original default hotkey. Auto-Clicker and Train Slow also restore their default timing values."
        BannerDynamicControls.Push(resetBtn)

        y += 40
    }

    statusLabel := RebindGui.AddText("x" padding " y" y " w" contentW " Center vStatusCtrl", "Status: Ready")
    StatusCtrl := RebindGui["StatusCtrl"]
    HelpControls[statusLabel.Hwnd] := "Shows whether the program is ready, listening for a new key, or has completed a keybind change or reset."
    BannerDynamicControls.Push(statusLabel)

    y += 30

    tooltipsChk := RebindGui.AddCheckbox("x" (padding + 20) " y" y " w110", "Tooltips On?")
    tooltipsChk.Value := TooltipsEnabled ? 1 : 0
    tooltipsChk.OnEvent("Click", ToggleTooltipsEnabled)
    HelpControls[tooltipsChk.Hwnd] := "Turn hotkey status notifications on or off. GUI hover explanations are controlled separately by UI Tooltips On?."
    BannerDynamicControls.Push(tooltipsChk)

    BannerDropDown := ""
    if AvailableBanners.Length > 0
    {
        bannerLabel := RebindGui.AddText("x" (padding + 135) " y" (y + 4) " w50 h20 +Right", "Banner:")
        BannerDynamicControls.Push(bannerLabel)

        bannerChoices := ["Disabled", "Random", "Random Cycle"]
        selectedChoice := 3

        if StrLower(BannerSelection) = "disabled"
            selectedChoice := 1
        else if StrLower(BannerSelection) = "random"
            selectedChoice := 2
        else if StrLower(BannerSelection) = "random cycle"
            selectedChoice := 3

        for index, banner in AvailableBanners
        {
            bannerChoices.Push(banner.displayName)
            if StrLower(BannerSelection) = StrLower(banner.fileName)
                selectedChoice := index + 3
        }

        BannerDropDown := RebindGui.AddDropDownList("x" (padding + 190) " y" (y - 2) " w170", bannerChoices)
        BannerDropDown.Choose(selectedChoice)
        BannerDropDown.OnEvent("Change", AutoClickerBannerSelectionChanged)
        HelpControls[BannerDropDown.Hwnd] := "Disable the banner, choose Random for a different banner each startup, choose Random Cycle to change it every 10 seconds, or select a named banner to always use it."
        BannerDynamicControls.Push(BannerDropDown)
    }

    y += 30

    uiTooltipsChk := RebindGui.AddCheckbox("x" (padding + 20) " y" y " w145", "UI Tooltips On?")
    uiTooltipsChk.Value := UiTooltipsEnabled ? 1 : 0
    uiTooltipsChk.OnEvent("Click", ToggleUiTooltipsEnabled)
    HelpControls[uiTooltipsChk.Hwnd] := "Turn GUI hover explanations on or off independently from hotkey status notifications."
    BannerDynamicControls.Push(uiTooltipsChk)

    launchMinimizedChk := RebindGui.AddCheckbox("x" (padding + 205) " y" y " w155", "Launch Minimized?")
    launchMinimizedChk.Value := LaunchMinimized ? 1 : 0
    launchMinimizedChk.OnEvent("Click", ToggleLaunchMinimized)
    HelpControls[launchMinimizedChk.Hwnd] := "Start the autoclicker hidden in the system tray. The tray icon, timers, and hotkeys remain active."
    BannerDynamicControls.Push(launchMinimizedChk)

    y += 30

    resetAllBtn := RebindGui.AddButton("x" padding " y" y " w335 h30", "Reset All to Defaults")
    resetAllBtn.OnEvent("Click", ResetAllToDefaults)
    HelpControls[resetAllBtn.Hwnd] := "Restore every action to its original hotkey. This also restores the default Auto-Clicker and Train Slow timing settings."
    BannerDynamicControls.Push(resetAllBtn)

    settingsBtn := RebindGui.AddButton("x" (padding + 340) " y" y " w40 h30", "⛭")
    settingsBtn.SetFont("s12", "Segoe UI Symbol")
    settingsBtn.OnEvent("Click", OpenSettingsFile)
    HelpControls[settingsBtn.Hwnd] := "Open the autoclicker settings file. Advanced users can inspect saved keybinds, timing values, tooltip state, click position, and banner choice."
    BannerDynamicControls.Push(settingsBtn)

    y += 40

    closeGuiBtn := RebindGui.AddButton("x" padding " y" y " w" contentW " h30", "Close GUI")
    closeGuiBtn.OnEvent("Click", (*) => RebindGui.Hide())
    HelpControls[closeGuiBtn.Hwnd] := "Hide this window while keeping the autoclicker and all configured hotkeys running. Reopen it from the tray icon."
    BannerDynamicControls.Push(closeGuiBtn)

    y += 40

    exitBtn := RebindGui.AddButton("x" padding " y" y " w" contentW " h30", "Exit Autoclicker")
    exitBtn.OnEvent("Click", (*) => ExitApp())
    HelpControls[exitBtn.Hwnd] := "Completely close the autoclicker and unregister all of its hotkeys."
    BannerDynamicControls.Push(exitBtn)

    y += 42

    footerText := RebindGui.AddText("x" padding " y" y " w" contentW " h36 Center", "This is an unofficial fan-made tool. Banner artwork is property of Siege Camp.")
    footerText.SetFont("s8", "Segoe UI")
    HelpControls[footerText.Hwnd] := "This project is an unofficial community tool and is not affiliated with Siege Camp."
    BannerDynamicControls.Push(footerText)

    footerBottomMargin := 8
    contentHeightCurrentLayout := y + 36 + footerBottomMargin
    BannerGuiHeightVisible := BannerVisible ? contentHeightCurrentLayout : contentHeightCurrentLayout + BannerShift
    BannerGuiHeightHidden := BannerGuiHeightVisible - BannerShift

    for ctrl in BannerDynamicControls
    {
        try
        {
            ctrl.GetPos(&ctrlX, &ctrlY)
            BannerControlBaseY[ctrl.Hwnd] := ctrlY - (BannerVisible ? BannerShift : 0)
        }
    }

    RebindGui.OnEvent("Close", (*) => ExitApp())
    RebindGui.OnEvent("Escape", HandleRebindGuiEscape)

    initialGuiHeight := BannerVisible ? BannerGuiHeightVisible : BannerGuiHeightHidden
    RebindGui.Show("w" winW " h" initialGuiHeight)
    SetTimer(TrackHelpHover, 50)
    SetTimer(RotateTopContent, 10000)
}

HandleRebindGuiEscape(*)
{
    global ListeningForAction, RebindGui

    if ListeningForAction != ""
        return

    RebindGui.Hide()
}

TrackHelpHover()
{
    global HelpControls, HoveredHelpHwnd, UiTooltipsEnabled

    MouseGetPos(,, &hoverWindow, &hoverControl, 2)
    if (UiTooltipsEnabled && HelpControls.Has(hoverControl))
    {
        if (HoveredHelpHwnd != hoverControl)
        {
            ToolTip(HelpControls[hoverControl])
            HoveredHelpHwnd := hoverControl
        }
        return
    }

    if (HoveredHelpHwnd)
    {
        ToolTip()
        HoveredHelpHwnd := 0
    }
}

MakeRebindHandler(actionName)
{
    return ButtonHandler

    ButtonHandler(ctrlObj, info)
    {
        StartListening(actionName, ctrlObj)
    }
}

InitPollKeyList()
{
    global PollKeyList
    list := []

    Loop 26
        list.Push(Chr(64 + A_Index))

    Loop 10
        list.Push(String(A_Index - 1))

    Loop 24
        list.Push("F" A_Index)

    for k in ["Space", "Enter", "Tab", "Escape", "Backspace", "Delete", "Insert",
        "Home", "End", "PgUp", "PgDn", "Up", "Down", "Left", "Right",
        "CapsLock", "PrintScreen", "Pause", "AppsKey",
        "LWin", "RWin",
        "LControl", "RControl", "LShift", "RShift", "LAlt", "RAlt",
        "NumpadDot", "NumpadDiv", "NumpadMult", "NumpadAdd", "NumpadSub", "NumpadEnter",
        "Numpad0", "Numpad1", "Numpad2", "Numpad3", "Numpad4",
        "Numpad5", "Numpad6", "Numpad7", "Numpad8", "Numpad9",
        "MButton", "XButton1", "XButton2",
        "`;", "'", "``", "[", "]", "\", ",", ".", "/", "-", "="]
        list.Push(k)

    PollKeyList := list
}

global ModifierKeyDefs := [
    { symbol: "^", keys: ["LControl", "RControl"] },
    { symbol: "+", keys: ["LShift", "RShift"] },
    { symbol: "!", keys: ["LAlt", "RAlt"] },
    { symbol: "#", keys: ["LWin", "RWin"] }
]

StartListening(actionName, btnCtrl)
{
    global ListeningForAction, StatusCtrl, PollKeyList

    if (PollKeyList.Length = 0)
        InitPollKeyList()

    PauseAllHotkeys()

    ListeningForAction := actionName
    btnCtrl.Text := "Press any key..."
    StatusCtrl.Text := "Listening for new key for '" actionName "'... (Esc to cancel)"

    SetTimer(PollForKey, 20)

    PollForKey()
    {
        for keyName in PollKeyList
        {

            if (IsModifierKeyName(keyName))
                continue

            if GetKeyState(keyName, "P")
            {
                SetTimer(PollForKey, 0)

                modPrefix := BuildHeldModifierPrefix()

                KeyWait(keyName)
                WaitForModifierRelease()

                FinishListening(actionName, btnCtrl, modPrefix, keyName)
                return
            }
        }
    }
}

BuildHeldModifierPrefix()
{
    global ModifierKeyDefs

    prefix := ""
    for modDef in ModifierKeyDefs
    {
        for sideKey in modDef.keys
        {
            if GetKeyState(sideKey, "P")
            {
                prefix .= modDef.symbol
                break
            }
        }
    }
    return prefix
}

WaitForModifierRelease()
{
    global ModifierKeyDefs

    for modDef in ModifierKeyDefs
    {
        for sideKey in modDef.keys
        {
            if GetKeyState(sideKey, "P")
                KeyWait(sideKey)
        }
    }
}

FinishListening(actionName, btnCtrl, modPrefix, keyName)
{
    global ListeningForAction, StatusCtrl, ActionLabels

    ListeningForAction := ""

    if (keyName = "Escape" && modPrefix = "")
    {
        StatusCtrl.Text := "Rebind cancelled."
        btnCtrl.Text := "Rebind: " CurrentKeysGet(actionName)
        ResumeAllHotkeys()
        return
    }

    if (IsModifierKeyName(keyName) && modPrefix = "")
    {
        StatusCtrl.Text := "Please hold a modifier and press a non-modifier key."
        btnCtrl.Text := "Rebind: " CurrentKeysGet(actionName)
        ResumeAllHotkeys()
        return
    }

    fullKey := modPrefix . keyName

    success := RebindAction(actionName, fullKey)

    if (success)
    {
        btnCtrl.Text := "Rebind: " FormatKeyDisplay(modPrefix, keyName)
        StatusCtrl.Text := "'" ActionLabels[actionName] "' is now bound to " FormatKeyDisplay(modPrefix, keyName) "."
    }
    else
    {
        btnCtrl.Text := "Rebind: " CurrentKeysGet(actionName)
        StatusCtrl.Text := "Failed to bind " FormatKeyDisplay(modPrefix, keyName) ". Try a different key."
    }

    ResumeAllHotkeys()
}

FormatKeyDisplay(modPrefix, keyName)
{
    parts := []
    if InStr(modPrefix, "^")
        parts.Push("Ctrl")
    if InStr(modPrefix, "+")
        parts.Push("Shift")
    if InStr(modPrefix, "!")
        parts.Push("Alt")
    if InStr(modPrefix, "#")
        parts.Push("Win")
    parts.Push(keyName)

    result := ""
    for i, p in parts
        result .= (i = 1 ? "" : "+") . p
    return result
}

IsModifierKeyName(keyName)
{
    static modNames := ["LControl", "RControl", "LShift", "RShift", "LAlt", "RAlt", "LWin", "RWin"]
    for m in modNames
        if (keyName = m)
            return true
    return false
}

DisplayNameForHotkeyString(hotkeyStr)
{
    modPrefix := ""
    pos := 1
    Loop Parse, hotkeyStr
    {
        if (A_LoopField = "^" || A_LoopField = "+" || A_LoopField = "!" || A_LoopField = "#")
        {
            modPrefix .= A_LoopField
            pos += 1
        }
        else
            break
    }
    keyName := SubStr(hotkeyStr, pos)
    return FormatKeyDisplay(modPrefix, keyName)
}

CurrentKeysGet(actionName)
{
    global CurrentKeys
    return CurrentKeys[actionName]
}

OpenSettingsFile(*)
{
    global SettingsFile
    if FileExist(SettingsFile)
        Run(SettingsFile)
    else
        Run("notepad.exe " Chr(34) SettingsFile Chr(34))
}

ToggleTooltipsEnabled(ctrlObj, info)
{
    global TooltipsEnabled
    TooltipsEnabled := ctrlObj.Value ? true : false
    SaveTooltipsEnabled(TooltipsEnabled)
}

ToggleUiTooltipsEnabled(ctrlObj, info)
{
    global UiTooltipsEnabled, HoveredHelpHwnd
    UiTooltipsEnabled := ctrlObj.Value ? true : false
    SaveUiTooltipsEnabled(UiTooltipsEnabled)

    if !UiTooltipsEnabled
    {
        ToolTip()
        HoveredHelpHwnd := 0
    }
}

ToggleLaunchMinimized(ctrlObj, info)
{
    global LaunchMinimized
    LaunchMinimized := ctrlObj.Value ? true : false
    SaveLaunchMinimized(LaunchMinimized)
}

ResetAllToDefaults(*)
{
    global ActionNames, DefaultKeys, RebindButtons, StatusCtrl, AutoClickInterval, AutoClickDefaultInterval, AutoClickActive, AutoClickPaused

    for actionName in ActionNames
    {
        RebindAction(actionName, DefaultKeys[actionName])
        RebindButtons[actionName].Text := "Rebind: " DisplayNameForHotkeyString(DefaultKeys[actionName])
    }
    StatusCtrl.Text := "All keybinds reset to defaults."
}

MakeResetHandler(actionName)
{
    return ResetHandler

    ResetHandler(ctrlObj, info)
    {
        ResetSingleToDefault(actionName)
    }
}

ResetSingleToDefault(actionName)
{
    global DefaultKeys, RebindButtons, ActionLabels, StatusCtrl, TrainSlowInterval, TrainSlowDefaultInterval, AutoClickInterval, AutoClickDefaultInterval, AutoClickActive, AutoClickPaused

    RebindAction(actionName, DefaultKeys[actionName])
    RebindButtons[actionName].Text := "Rebind: " DisplayNameForHotkeyString(DefaultKeys[actionName])

    if (actionName = "TrainSlow")
    {
        TrainSlowInterval := TrainSlowDefaultInterval
        SaveTrainSlowInterval(TrainSlowInterval)
        StatusCtrl.Text := "'Train Slow' reset to F9 with a 300 ms interval."
    }
    else if (actionName = "AutoClick")
    {
        AutoClickInterval := AutoClickDefaultInterval
        AutoClickPaused := false
        SaveAutoClickInterval(AutoClickInterval)
        if (AutoClickActive)
            SetTimer(SendBackgroundClick, AutoClickInterval)
        StatusCtrl.Text := "'Auto-Clicker' reset to F2 with a 50 ms interval."
    }
    else
        StatusCtrl.Text := "'" ActionLabels[actionName] "' reset to " DisplayNameForHotkeyString(DefaultKeys[actionName]) "."
}


CheckForUpdate()
{
    global AppVersion, GitHubLatestReleaseApi, RebindGui, UpdateWindowTitle

    try
    {
        request := ComObject("WinHttp.WinHttpRequest.5.1")
        request.SetTimeouts(3000, 3000, 5000, 5000)
        request.Open("GET", GitHubLatestReleaseApi, false)
        request.SetRequestHeader("Accept", "application/vnd.github+json")
        request.SetRequestHeader("User-Agent", "Foxhole-Autoclicker-" AppVersion)
        request.SetRequestHeader("X-GitHub-Api-Version", "2022-11-28")
        request.Send()

        if request.Status != 200
            return

        if !RegExMatch(request.ResponseText, '"tag_name"\s*:\s*"([^"]+)"', &tagMatch)
            return

        latestVersion := NormalizeVersion(tagMatch[1])
        if latestVersion = ""
            return

        if IsVersionNewer(latestVersion, AppVersion)
            RebindGui.Title := UpdateWindowTitle
    }
    catch
    {
    }
}

NormalizeVersion(versionText)
{
    versionText := Trim(versionText)
    versionText := RegExReplace(versionText, "i)^v")

    if !RegExMatch(versionText, "^\d+(?:\.\d+)*", &versionMatch)
        return ""

    return versionMatch[0]
}

IsVersionNewer(candidateVersion, currentVersion)
{
    candidateParts := StrSplit(candidateVersion, ".")
    currentParts := StrSplit(currentVersion, ".")
    partCount := Max(candidateParts.Length, currentParts.Length)

    Loop partCount
    {
        candidatePart := A_Index <= candidateParts.Length ? Integer(candidateParts[A_Index]) : 0
        currentPart := A_Index <= currentParts.Length ? Integer(currentParts[A_Index]) : 0

        if candidatePart > currentPart
            return true
        if candidatePart < currentPart
            return false
    }

    return false
}

TraySetup()
{
    global RebindGui
    A_TrayMenu.Add("Show GUI", (*) => RebindGui.Show())
    A_TrayMenu.Default := "Show GUI"
}

ApplyStartupWindowState()
{
    global RebindGui, LaunchMinimized
    if LaunchMinimized
        RebindGui.Hide()
}

Hotkey_AutoClick(*)
{
    global AutoClickActive, ClickHoldActive, ClickX, ClickY, TargetWindow, DefaultClickX, DefaultClickY, AutoClickInterval, AutoClickPaused

    if !WinExist(TargetWindow)
    {
        ShowTooltip("Foxhole window not found!", 2000)
        return
    }

    if (ClickHoldActive)
    {
        ClickHoldActive := false
        SetTimer(SendBackgroundHold, 0)
        PostMessage(0x0202, 0, MakeLParam(ClickX, ClickY), , TargetWindow)
    }

    AutoClickActive := !AutoClickActive

    if (AutoClickActive)
    {
        if WinActive(TargetWindow)
        {
            CoordMode "Mouse", "Client"
            MouseGetPos(&ClickX, &ClickY)
        }
        else
        {

            ClickX := DefaultClickX
            ClickY := DefaultClickY
        }

        AutoClickPaused := false
        ShowTooltip("Auto-Click ON (" AutoClickInterval " ms, Shift+Scroll to adjust)", 2500)
        SendBackgroundClick()
        SetTimer(SendBackgroundClick, AutoClickInterval)
    }
    else
    {
        ShowTooltip("Auto-Click OFF", 1500)
        SetTimer(SendBackgroundClick, 0)

        PostMessage(0x0202, 0, MakeLParam(ClickX, ClickY), , TargetWindow)
    }
}

SendBackgroundClick()
{
    global ClickX, ClickY, TargetWindow

    targetHwnd := WinExist(TargetWindow)
    if !targetHwnd
        return

    clickCoords := MakeLParam(ClickX, ClickY)
    restoreCoords := GetCurrentCursorClientLParam(targetHwnd)

    PostMessage(0x0201, 0x0001, clickCoords, , "ahk_id " targetHwnd)
    PostMessage(0x0202, 0, clickCoords, , "ahk_id " targetHwnd)

    if (restoreCoords != "")
        PostMessage(0x0200, 0, restoreCoords, , "ahk_id " targetHwnd)
}

GetCurrentCursorClientLParam(targetHwnd)
{
    cursorPoint := Buffer(8, 0)
    if !DllCall("GetCursorPos", "Ptr", cursorPoint.Ptr)
        return ""

    if !DllCall("ScreenToClient", "Ptr", targetHwnd, "Ptr", cursorPoint.Ptr)
        return ""

    cursorX := NumGet(cursorPoint, 0, "Int")
    cursorY := NumGet(cursorPoint, 4, "Int")

    clientRect := Buffer(16, 0)
    if DllCall("GetClientRect", "Ptr", targetHwnd, "Ptr", clientRect.Ptr)
    {
        clientWidth := NumGet(clientRect, 8, "Int")
        clientHeight := NumGet(clientRect, 12, "Int")

        if (clientWidth > 0)
            cursorX := Max(0, Min(clientWidth - 1, cursorX))
        if (clientHeight > 0)
            cursorY := Max(0, Min(clientHeight - 1, cursorY))
    }

    return MakeLParam(cursorX, cursorY)
}

RestoreGameCursorToPhysicalPosition(targetWindow)
{
    targetHwnd := WinExist(targetWindow)
    if !targetHwnd
        return

    restoreCoords := GetCurrentCursorClientLParam(targetHwnd)
    if (restoreCoords != "")
        PostMessage(0x0200, 0, restoreCoords, , "ahk_id " targetHwnd)
}

MakeLParam(x, y)
{
    return (x & 0xFFFF) | ((y & 0xFFFF) << 16)
}

Hotkey_AutoWalk(*)
{
    global AutoWalkActive, AutoReverseActive, TrainSlowActive, TargetWindow

    if !WinExist(TargetWindow)
    {
        ShowTooltip("Foxhole window not found!", 2000)
        return
    }

    if (AutoReverseActive)
    {
        AutoReverseActive := false
        SetTimer(SendBackgroundS, 0)
        PostMessage(0x0101, 0x53, 0xC0530001, , TargetWindow)
    }

    if (TrainSlowActive)
    {
        TrainSlowActive := false
        SetTimer(SendBackgroundTrainSlowW, 0)
        PostMessage(0x0101, 0x57, 0xC0570001, , TargetWindow)
    }

    AutoWalkActive := !AutoWalkActive

    if (AutoWalkActive)
    {
        ShowTooltip("FORWARD", 1500)
        SetTimer(SendBackgroundW, 50)
    }
    else
    {
        ShowTooltip("Forward OFF", 1500)
        SetTimer(SendBackgroundW, 0)
        PostMessage(0x0101, 0x57, 0xC0570001, , TargetWindow)
    }
}

SendBackgroundW()
{
    global TargetWindow
    if WinExist(TargetWindow)
    {
        PostMessage(0x0100, 0x57, 0x00570001, , TargetWindow)
    }
}

Hotkey_AutoReverse(*)
{
    global AutoWalkActive, AutoReverseActive, TrainSlowActive, TargetWindow

    if !WinExist(TargetWindow)
    {
        ShowTooltip("Foxhole window not found!", 2000)
        return
    }

    if (AutoWalkActive)
    {
        AutoWalkActive := false
        SetTimer(SendBackgroundW, 0)
        PostMessage(0x0101, 0x57, 0xC0570001, , TargetWindow)
    }

    if (TrainSlowActive)
    {
        TrainSlowActive := false
        SetTimer(SendBackgroundTrainSlowW, 0)
        PostMessage(0x0101, 0x57, 0xC0570001, , TargetWindow)
    }

    AutoReverseActive := !AutoReverseActive

    if (AutoReverseActive)
    {
        ShowTooltip("REVERSE", 1500)
        SetTimer(SendBackgroundS, 50)
    }
    else
    {
        ShowTooltip("Reverse OFF", 1500)
        SetTimer(SendBackgroundS, 0)
        PostMessage(0x0101, 0x53, 0xC0530001, , TargetWindow)
    }
}

SendBackgroundS()
{
    global TargetWindow
    if WinExist(TargetWindow)
    {
        PostMessage(0x0100, 0x53, 0x00530001, , TargetWindow)
    }
}

Hotkey_TrainSlow(*)
{
    global TrainSlowActive, TrainSlowInterval, AutoWalkActive, AutoReverseActive, TargetWindow

    if !WinExist(TargetWindow)
    {
        ShowTooltip("Foxhole window not found!", 2000)
        return
    }

    if (AutoWalkActive)
    {
        AutoWalkActive := false
        SetTimer(SendBackgroundW, 0)
        PostMessage(0x0101, 0x57, 0xC0570001, , TargetWindow)
    }

    if (AutoReverseActive)
    {
        AutoReverseActive := false
        SetTimer(SendBackgroundS, 0)
        PostMessage(0x0101, 0x53, 0xC0530001, , TargetWindow)
    }

    TrainSlowActive := !TrainSlowActive

    if (TrainSlowActive)
    {
        ShowTooltip("Train Slow ON (Use Shift+Scroll)", 2500)
        SendBackgroundTrainSlowW()
        SetTimer(SendBackgroundTrainSlowW, TrainSlowInterval)
    }
    else
    {
        ShowTooltip("Train Slow OFF", 1500)
        SetTimer(SendBackgroundTrainSlowW, 0)
        PostMessage(0x0101, 0x57, 0xC0570001, , TargetWindow)
    }
}

SendBackgroundTrainSlowW()
{
    global TargetWindow, TrainSlowHoldDuration
    if WinExist(TargetWindow)
    {
        PostMessage(0x0100, 0x57, 0x00570001, , TargetWindow)
        Sleep(TrainSlowHoldDuration)
        PostMessage(0x0101, 0x57, 0xC0570001, , TargetWindow)
    }
}

#HotIf TrainSlowActive
+WheelUp::AdjustTrainSlowInterval(25)
+WheelDown::AdjustTrainSlowInterval(-25)
#HotIf

#HotIf AutoClickActive
+WheelUp::AdjustAutoClickInterval(10)
+WheelDown::AdjustAutoClickInterval(-10)
#HotIf

AdjustAutoClickInterval(change)
{
    global AutoClickInterval, AutoClickDefaultInterval, AutoClickPaused

    if (AutoClickPaused)
    {
        if (change < 0)
        {
            AutoClickPaused := false
            AutoClickInterval := 500
            SaveAutoClickInterval(AutoClickInterval)
            SetTimer(SendBackgroundClick, AutoClickInterval)
            ShowTooltip("Auto-Click interval: 500 ms", 1500)
        }
        return
    }

    if (change > 0 && AutoClickInterval >= 500)
    {
        AutoClickPaused := true
        SetTimer(SendBackgroundClick, 10000000)
        ShowTooltip("PAUSED", 1500)
        return
    }

    AutoClickInterval := Max(10, Min(500, AutoClickInterval + change))
    SaveAutoClickInterval(AutoClickInterval)
    SetTimer(SendBackgroundClick, AutoClickInterval)
    ShowTooltip("Auto-Click interval: " AutoClickInterval " ms", 1500)
}

AdjustTrainSlowInterval(change)
{
    global TrainSlowInterval
    TrainSlowInterval := Max(10, Min(3000, TrainSlowInterval + change))
    SaveTrainSlowInterval(TrainSlowInterval)
    SetTimer(SendBackgroundTrainSlowW, TrainSlowInterval)
    ShowTooltip("Train Slow interval: " TrainSlowInterval " ms", 1500)
}

Hotkey_ClickHold(*)
{
    global AutoClickActive, ClickHoldActive, ClickX, ClickY, TargetWindow, DefaultClickX, DefaultClickY

    if !WinExist(TargetWindow)
    {
        ShowTooltip("Foxhole window not found!", 2000)
        return
    }

    if (AutoClickActive)
    {
        AutoClickActive := false
        SetTimer(SendBackgroundClick, 0)
    }

    ClickHoldActive := !ClickHoldActive

    if (ClickHoldActive)
    {
        if WinActive(TargetWindow)
        {
            CoordMode "Mouse", "Client"
            MouseGetPos(&ClickX, &ClickY)
        }
        else
        {
            ClickX := DefaultClickX
            ClickY := DefaultClickY
        }

        ShowTooltip("Holding Left", 2500)

        PackedCoords := MakeLParam(ClickX, ClickY)
        PostMessage(0x0201, 0x0001, PackedCoords, , TargetWindow)
        RestoreGameCursorToPhysicalPosition(TargetWindow)
    }
    else
    {
        ShowTooltip("Holding Left OFF", 1500)
        SetTimer(SendBackgroundHold, 0)

        PackedCoords := MakeLParam(ClickX, ClickY)
        PostMessage(0x0202, 0, PackedCoords, , TargetWindow)
        RestoreGameCursorToPhysicalPosition(TargetWindow)
    }
}

SendBackgroundHold()
{
    global ClickX, ClickY, TargetWindow
    if WinExist(TargetWindow)
        PostMessage(0x0201, 0x0001, MakeLParam(ClickX, ClickY), , TargetWindow)
}

Hotkey_RightHold(*)
{
    global RightHoldActive, TargetWindow

    if !WinExist(TargetWindow)
    {
        ShowTooltip("Foxhole window not found!", 2000)
        return
    }

    RightHoldActive := !RightHoldActive

    if (RightHoldActive)
    {
        ShowTooltip("Right Click ON", 2500)

        SendBackgroundRightHold()
        SetTimer(SendBackgroundRightHold, 200)
    }
    else
    {
        ShowTooltip("Right Click: OFF", 1500)

        SetTimer(SendBackgroundRightHold, 0)

        PostMessage(0x0205, 0, 0, , TargetWindow)
    }
}

SendBackgroundRightHold()
{
    global TargetWindow
    if WinExist(TargetWindow)
    {
        ControlClick(, TargetWindow, , "RIGHT", 1, "NA D{Blind}")
    }
}

Hotkey_VSpam(*)
{
    global VSpamActive, TargetWindow

    if !WinExist(TargetWindow)
    {
        ShowTooltip("Foxhole window not found!", 2000)
        return
    }

    VSpamActive := !VSpamActive

    if (VSpamActive)
    {
        ShowTooltip("V Spam ON", 2500)
        SendBackgroundV()
        SetTimer(SendBackgroundV, 50)
    }
    else
    {
        ShowTooltip("V Spam OFF", 1500)
        SetTimer(SendBackgroundV, 0)
        PostMessage(0x0101, 0x56, 0xC0560001, , TargetWindow)
    }
}

SendBackgroundV()
{
    global TargetWindow
    if WinExist(TargetWindow)
    {

        PostMessage(0x0100, 0x56, 0x00560001, , TargetWindow)
        PostMessage(0x0101, 0x56, 0xC0560001, , TargetWindow)
    }
}
