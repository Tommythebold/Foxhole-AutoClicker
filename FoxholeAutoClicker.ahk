#Requires AutoHotkey v2.0
#SingleInstance Force

;@Ahk2Exe-SetMainIcon Bin\AutoClicker2Icon.ico
;@Ahk2Exe-SetName Foxhole Autoclicker
;@Ahk2Exe-SetDescription Foxhole Autoclicker 2.0
;@Ahk2Exe-SetProductName Foxhole Autoclicker
;@Ahk2Exe-SetVersion 2.0.2
;@Ahk2Exe-SetProductVersion 2.0.2

global AppVersion := "2.0.2"
global NormalWindowTitle := "Foxhole Autoclicker " AppVersion
global UpdateWindowTitle := NormalWindowTitle " - Update Available"
global GitHubLatestReleaseApi := "https://api.github.com/repos/Tommythebold/Foxhole-AutoClicker/releases/latest"
global LatestVersion := ""
global UpdateAvailable := false
global UpdateCheckComplete := false

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
global ChangeOutputKeys := false

global ClickX := 0
global ClickY := 0

global DefaultClickX := 0
global DefaultClickY := 0

global AssetDir := A_ScriptDir "\Bin"
global IconPath := AssetDir "\AutoClicker2Icon.ico"

if FileExist(IconPath)
    TraySetIcon(IconPath)

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
    "VSpam", "Submit Large Item",
    "TrainSlow", "Train Slow"
)
global ActionDescriptions := Map(
    "AutoClick", "Toggles background left-clicking at the cursor position. Works for no-rotation hammering too. Use Shift+Scroll to adjust the interval, max interval will pause it.",
    "AutoWalk", "Toggles holding the configured Forward output key.",
    "AutoReverse", "Toggles holding the configured Reverse output key.",
    "ClickHold", "Toggles holding left mouse for harvesters and CV's.",
    "RightHold", "Toggles holding right mouse button for binoculars and crane rotation.",
    "VSpam", "Repeatedly presses the configured Submit Large Item output key.",
    "TrainSlow", "Periodically holds the configured Train Slow output key. Use Shift+Scroll to adjust the interval."
)
global CurrentKeys := Map()
global OutputActionNames := ["AutoWalk", "AutoReverse", "VSpam", "TrainSlow"]
global DefaultOutputKeys := Map(
    "AutoWalk", "W",
    "AutoReverse", "S",
    "VSpam", "V",
    "TrainSlow", "W"
)
global CurrentOutputKeys := Map()

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
global OutputKeyButtons := Map()
global HelpControls := Map()
global HoveredHelpHwnd := 0
global ListeningForAction := ""
global ListeningMode := ""
global StatusCtrl := ""
global PollKeyList := []
global OutputCaptureHook := ""
global ChangeOutputKeysCheckbox := ""

LoadKeybinds()
PrepareBannerAssets()
ApplyAllHotkeys()
BuildGui()
TraySetup()
ApplyStartupWindowState()
SetTimer(CheckForUpdate, -1000)
SetTimer(CheckForUpdate, 21600000)
OnExit(ReleaseAllOutputKeys)

LoadKeybinds()
{
    global ActionNames, DefaultKeys, CurrentKeys, OutputActionNames, DefaultOutputKeys, CurrentOutputKeys, SettingsFile, DefaultClickX, DefaultClickY, TooltipsEnabled, UiTooltipsEnabled, LaunchMinimized, ChangeOutputKeys, TrainSlowInterval, AutoClickInterval, BannerSelection

    for actionName in ActionNames
    {
        savedKey := IniRead(SettingsFile, "Keybinds", actionName, DefaultKeys[actionName])
        CurrentKeys[actionName] := savedKey
    }

    for actionName in OutputActionNames
    {
        savedOutputKey := IniRead(SettingsFile, "OutputKeys", actionName, DefaultOutputKeys[actionName])
        if !IsValidOutputKey(savedOutputKey)
            savedOutputKey := DefaultOutputKeys[actionName]
        CurrentOutputKeys[actionName] := savedOutputKey
    }

    DefaultClickX := Integer(IniRead(SettingsFile, "ClickPos", "X", "0"))
    DefaultClickY := Integer(IniRead(SettingsFile, "ClickPos", "Y", "0"))

    TooltipsEnabled := IniRead(SettingsFile, "Settings", "TooltipsEnabled", "1") = "1"
    UiTooltipsEnabled := IniRead(SettingsFile, "Settings", "UiTooltipsEnabled", "1") = "1"
    LaunchMinimized := IniRead(SettingsFile, "Settings", "LaunchMinimized", "0") = "1"
    ChangeOutputKeys := IniRead(SettingsFile, "Settings", "ChangeOutputKeys", "0") = "1"
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

SaveChangeOutputKeys(enabled)
{
    global SettingsFile
    IniWrite(enabled ? "1" : "0", SettingsFile, "Settings", "ChangeOutputKeys")
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

SaveOutputKey(actionName, keyName)
{
    global SettingsFile
    IniWrite(keyName, SettingsFile, "OutputKeys", actionName)
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
    global BannerDefinitions, AvailableBanners, BannerAssetDir, AssetDir

    AvailableBanners := []
    BannerAssetDir := AssetDir

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
    global ActionNames, ActionLabels, ActionDescriptions, CurrentKeys, CurrentOutputKeys, RebindGui, RebindButtons, RebindResetButtons, OutputKeyButtons, NormalWindowTitle
    global HelpControls, StatusCtrl, DefaultClickX, DefaultClickY, TooltipsEnabled, UiTooltipsEnabled, LaunchMinimized, ChangeOutputKeys, ChangeOutputKeysCheckbox
    global AvailableBanners, BannerPicture, BannerDropDown, BannerDynamicControls
    global CurrentBannerFile, BannerVisible, BannerShift, BannerSelection
    global BannerControlBaseY, BannerGuiHeightHidden, BannerGuiHeightVisible, BannerLayoutChanging
    global TopMessageControl, TopMessageIndex, TopMessages
    global UpdateAvailable, LatestVersion

    padding := 20
    contentW := ChangeOutputKeys ? 400 : 330
    winW := contentW + (padding * 2)

    actionX := padding + 5
    actionW := 110
    hotkeyX := padding + 120
    hotkeyW := 105
    outputX := padding + 230
    outputW := 55
    resetX := ChangeOutputKeys ? padding + 290 : padding + 230
    resetW := ChangeOutputKeys ? 70 : 75

    bannerHeight := Round(contentW * (206 / 679))
    bannerGap := 15
    BannerShift := bannerHeight + bannerGap
    BannerDynamicControls := []
    BannerControlBaseY := Map()
    BannerLayoutChanging := false
    RebindButtons := Map()
    RebindResetButtons := Map()
    OutputKeyButtons := Map()
    HelpControls := Map()

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
            HelpControls[BannerPicture.Hwnd] := "Decorative banner. Use the Banner dropdown to disable it, cycle images, or select a specific image."
            BannerPicture.Visible := BannerVisible
            if BannerVisible
                y += BannerShift
        }
    }

    TopMessageIndex := 1
    TopMessageControl := RebindGui.Add("Link", "x" padding " y" y " w" contentW " h24 Center", TopMessages[TopMessageIndex])
    BannerDynamicControls.Push(TopMessageControl)
    HelpControls[TopMessageControl.Hwnd] := "Cycles through setup guidance, support information, and the project link every 10 seconds."

    y += 28
    actionHeader := RebindGui.AddText("x" actionX " y" y " w" actionW " Right", "Action")
    hotkeyHeader := RebindGui.AddText("x" hotkeyX " y" y " w" hotkeyW " Center", "Hotkey")
    headerCtrls := [actionHeader, hotkeyHeader]
    if ChangeOutputKeys
    {
        outputHeader := RebindGui.AddText("x" outputX " y" y " w" outputW " Center", "Output")
        headerCtrls.Push(outputHeader)
    }
    resetHeader := RebindGui.AddText("x" resetX " y" y " w" resetW " Center", "Reset")
    headerCtrls.Push(resetHeader)
    for headerCtrl in headerCtrls
    {
        headerCtrl.SetFont("s8 Bold", "Segoe UI")
        BannerDynamicControls.Push(headerCtrl)
    }
    y += 25

    for actionName in ActionNames
    {
        label := ActionLabels[actionName]
        labelCtrl := RebindGui.AddText("x" actionX " y" y " w" actionW " Right", label)
        HelpControls[labelCtrl.Hwnd] := ActionDescriptions[actionName]
        BannerDynamicControls.Push(labelCtrl)

        btn := RebindGui.AddButton("x" hotkeyX " y" (y - 4) " w" hotkeyW " h30", DisplayNameForHotkeyString(CurrentKeys[actionName]))
        btn.OnEvent("Click", MakeRebindHandler(actionName))
        RebindButtons[actionName] := btn
        HelpControls[btn.Hwnd] := "Click to assign the activation hotkey for " label ". Key combinations are supported; press Escape to cancel."
        BannerDynamicControls.Push(btn)

        if ChangeOutputKeys && HasOutputKey(actionName)
        {
            outputBtn := RebindGui.AddButton("x" outputX " y" (y - 4) " w" outputW " h30", DisplayNameForOutputKey(CurrentOutputKeys[actionName]))
            outputBtn.OnEvent("Click", MakeOutputKeyHandler(actionName))
            OutputKeyButtons[actionName] := outputBtn
            HelpControls[outputBtn.Hwnd] := "Click to choose the single keyboard key that " label " sends to Foxhole. Press Escape to cancel."
            BannerDynamicControls.Push(outputBtn)
        }

        resetBtn := RebindGui.AddButton("x" resetX " y" (y - 4) " w" resetW " h30", "Reset")
        resetBtn.OnEvent("Click", MakeResetHandler(actionName))
        RebindResetButtons[actionName] := resetBtn
        resetTip := "Restore " label " to its original activation hotkey"
        if HasOutputKey(actionName)
            resetTip .= " and output key"
        resetTip .= ". Auto-Clicker and Train Slow also restore timing defaults."
        HelpControls[resetBtn.Hwnd] := resetTip
        BannerDynamicControls.Push(resetBtn)
        y += 40
    }

    statusLabel := RebindGui.AddText("x" padding " y" y " w" contentW " Center vStatusCtrl", "Status: Ready")
    StatusCtrl := RebindGui["StatusCtrl"]
    HelpControls[statusLabel.Hwnd] := "Shows whether the program is ready, listening for a new key, or has completed a keybind change or reset."
    BannerDynamicControls.Push(statusLabel)
    y += 30

    checkboxGap := 10
    checkboxW := Floor((contentW - checkboxGap) / 2)
    checkboxRightX := padding + checkboxW + checkboxGap

    tooltipsChk := RebindGui.AddCheckbox("x" padding " y" y " w" checkboxW, "Tooltips On?")
    tooltipsChk.Value := TooltipsEnabled ? 1 : 0
    tooltipsChk.OnEvent("Click", ToggleTooltipsEnabled)
    HelpControls[tooltipsChk.Hwnd] := "Turn hotkey status notifications on or off."
    BannerDynamicControls.Push(tooltipsChk)

    uiTooltipsChk := RebindGui.AddCheckbox("x" checkboxRightX " y" y " w" checkboxW, "UI Tooltips On?")
    uiTooltipsChk.Value := UiTooltipsEnabled ? 1 : 0
    uiTooltipsChk.OnEvent("Click", ToggleUiTooltipsEnabled)
    HelpControls[uiTooltipsChk.Hwnd] := "Turn GUI hover explanations on or off independently from hotkey status notifications."
    BannerDynamicControls.Push(uiTooltipsChk)
    y += 26

    launchMinimizedChk := RebindGui.AddCheckbox("x" padding " y" y " w" checkboxW, "Launch Minimized?")
    launchMinimizedChk.Value := LaunchMinimized ? 1 : 0
    launchMinimizedChk.OnEvent("Click", ToggleLaunchMinimized)
    HelpControls[launchMinimizedChk.Hwnd] := "Start the autoclicker hidden in the system tray."
    BannerDynamicControls.Push(launchMinimizedChk)

    ChangeOutputKeysCheckbox := RebindGui.AddCheckbox("x" checkboxRightX " y" y " w" checkboxW, "Change Output Keys?")
    ChangeOutputKeysCheckbox.Value := ChangeOutputKeys ? 1 : 0
    ChangeOutputKeysCheckbox.OnEvent("Click", ToggleChangeOutputKeys)
    HelpControls[ChangeOutputKeysCheckbox.Hwnd] := "Show or hide controls for changing the keyboard keys sent to Foxhole. Useful for AZERTY keyboards and other custom keyboard layouts. Disabled by default to keep the interface simple."
    BannerDynamicControls.Push(ChangeOutputKeysCheckbox)
    y += 32

    BannerDropDown := ""
    if AvailableBanners.Length > 0
    {
        bannerLabel := RebindGui.AddText("x" padding " y" (y + 4) " w55 h20", "Banner:")
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
        BannerDropDown := RebindGui.AddDropDownList("x" (padding + 60) " y" (y - 2) " w" (contentW - 60), bannerChoices)
        BannerDropDown.Choose(selectedChoice)
        BannerDropDown.OnEvent("Change", AutoClickerBannerSelectionChanged)
        HelpControls[BannerDropDown.Hwnd] := "Disable the banner, choose Random for a different banner each startup, choose Random Cycle to change it every 10 seconds, or select a named banner."
        BannerDynamicControls.Push(BannerDropDown)
        y += 30
    }

    settingsW := 40
    resetAllBtn := RebindGui.AddButton("x" padding " y" y " w" (contentW - settingsW - 5) " h30", "Reset All to Defaults")
    resetAllBtn.OnEvent("Click", ResetAllToDefaults)
    HelpControls[resetAllBtn.Hwnd] := "Restore every action to its original activation hotkey and output key, plus timing defaults."
    BannerDynamicControls.Push(resetAllBtn)

    settingsBtn := RebindGui.AddButton("x" (padding + contentW - settingsW) " y" y " w" settingsW " h30", "⛭")
    settingsBtn.SetFont("s12", "Segoe UI Symbol")
    settingsBtn.OnEvent("Click", OpenSettingsFile)
    HelpControls[settingsBtn.Hwnd] := "Open the autoclicker settings file."
    BannerDynamicControls.Push(settingsBtn)
    y += 40

    closeGuiBtn := RebindGui.AddButton("x" padding " y" y " w" contentW " h30", "Close GUI")
    closeGuiBtn.OnEvent("Click", (*) => RebindGui.Hide())
    HelpControls[closeGuiBtn.Hwnd] := "Hide this window while keeping the autoclicker and configured hotkeys running."
    BannerDynamicControls.Push(closeGuiBtn)
    y += 40

    exitBtn := RebindGui.AddButton("x" padding " y" y " w" contentW " h30", "Exit Autoclicker")
    exitBtn.OnEvent("Click", (*) => ExitApp())
    HelpControls[exitBtn.Hwnd] := "Completely close the autoclicker and unregister all hotkeys."
    BannerDynamicControls.Push(exitBtn)
    y += 42

    footerText := RebindGui.AddText("x" padding " y" y " w" contentW " h30 Center", "This is an unofficial fan-made tool. Banner artwork is property of Siege Camp.")
    footerText.SetFont("s8", "Segoe UI")
    HelpControls[footerText.Hwnd] := "This project is an unofficial community tool and is not affiliated with Siege Camp."
    BannerDynamicControls.Push(footerText)
    y += 27

    ; Link controls do not consistently honor the Center style on every Windows theme.
    ; Create the link at its natural width, then center that actual width explicitly.
    githubLink := RebindGui.Add("Link", "x" padding " y" y " h18", '<a href="https://github.com/Tommythebold/Foxhole-AutoClicker/releases">GitHub</a>')
    githubLink.SetFont("s8", "Segoe UI")
    githubLink.GetPos(, , &githubLinkW)
    githubLink.Move(padding + Floor((contentW - githubLinkW) / 2), y)
    HelpControls[githubLink.Hwnd] := "Open the Foxhole AutoClicker releases page on GitHub."
    BannerDynamicControls.Push(githubLink)

    footerBottomMargin := 8
    contentHeightCurrentLayout := y + 18 + footerBottomMargin
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
    ApplyUpdateState()
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
        StartHotkeyListening(actionName, ctrlObj)
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

StartHotkeyListening(actionName, btnCtrl)
{
    global ListeningForAction, ListeningMode, StatusCtrl, PollKeyList

    if (PollKeyList.Length = 0)
        InitPollKeyList()

    PauseAllHotkeys()

    ListeningForAction := actionName
    ListeningMode := "Hotkey"
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

MakeOutputKeyHandler(actionName)
{
    return OutputButtonHandler

    OutputButtonHandler(ctrlObj, info)
    {
        StartOutputKeyListening(actionName, ctrlObj)
    }
}

StartOutputKeyListening(actionName, btnCtrl)
{
    global ListeningForAction, ListeningMode, StatusCtrl

    PauseAllHotkeys()
    ListeningForAction := actionName
    ListeningMode := "OutputKey"
    btnCtrl.Text := "Press..."
    StatusCtrl.Text := "Listening for output key for '" actionName "'... (Esc to cancel)"

    BeginOutputKeyCapture(actionName, btnCtrl)
}

BeginOutputKeyCapture(actionName, btnCtrl)
{
    global OutputCaptureHook, ListeningForAction, ListeningMode

    if (ListeningForAction != actionName || ListeningMode != "OutputKey")
        return

    ; Suppress the captured key so it never reaches the focused GUI button.
    ; This prevents the standard Windows invalid-key notification sound.
    OutputCaptureHook := InputHook("L0")
    OutputCaptureHook.KeyOpt("{All}", "ES")
    OutputCaptureHook.OnEnd := (*) => HandleOutputKeyCaptureEnd(actionName, btnCtrl)
    OutputCaptureHook.Start()
}

HandleOutputKeyCaptureEnd(actionName, btnCtrl)
{
    global OutputCaptureHook, ListeningForAction, ListeningMode

    if (ListeningForAction != actionName || ListeningMode != "OutputKey")
        return

    keyName := OutputCaptureHook.EndKey
    OutputCaptureHook := ""

    if (keyName = "")
    {
        BeginOutputKeyCapture(actionName, btnCtrl)
        return
    }

    if IsModifierKeyName(keyName)
    {
        KeyWait(keyName)
        BeginOutputKeyCapture(actionName, btnCtrl)
        return
    }

    FinishOutputKeyListening(actionName, btnCtrl, keyName)
}

FinishOutputKeyListening(actionName, btnCtrl, keyName)
{
    global ListeningForAction, ListeningMode, StatusCtrl, ActionLabels, CurrentOutputKeys

    ListeningForAction := ""
    ListeningMode := ""

    if (keyName = "Escape")
    {
        StatusCtrl.Text := "Output-key change cancelled."
        btnCtrl.Text := DisplayNameForOutputKey(CurrentOutputKeys[actionName])
        ResumeAllHotkeys()
        return
    }

    if !IsValidOutputKey(keyName)
    {
        StatusCtrl.Text := "That key cannot be sent in the background. Try another keyboard key."
        btnCtrl.Text := DisplayNameForOutputKey(CurrentOutputKeys[actionName])
        ResumeAllHotkeys()
        return
    }

    StopOutputAction(actionName)
    CurrentOutputKeys[actionName] := keyName
    SaveOutputKey(actionName, keyName)
    btnCtrl.Text := DisplayNameForOutputKey(keyName)
    StatusCtrl.Text := "'" ActionLabels[actionName] "' now sends " DisplayNameForOutputKey(keyName) "."
    ResumeAllHotkeys()
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
    global ListeningForAction, ListeningMode, StatusCtrl, ActionLabels

    ListeningForAction := ""
    ListeningMode := ""

    if (keyName = "Escape" && modPrefix = "")
    {
        StatusCtrl.Text := "Rebind cancelled."
        btnCtrl.Text := DisplayNameForHotkeyString(CurrentKeysGet(actionName))
        ResumeAllHotkeys()
        return
    }

    if (IsModifierKeyName(keyName) && modPrefix = "")
    {
        StatusCtrl.Text := "Please hold a modifier and press a non-modifier key."
        btnCtrl.Text := DisplayNameForHotkeyString(CurrentKeysGet(actionName))
        ResumeAllHotkeys()
        return
    }

    fullKey := modPrefix . keyName

    success := RebindAction(actionName, fullKey)

    if (success)
    {
        btnCtrl.Text := FormatKeyDisplay(modPrefix, keyName)
        StatusCtrl.Text := "'" ActionLabels[actionName] "' is now bound to " FormatKeyDisplay(modPrefix, keyName) "."
    }
    else
    {
        btnCtrl.Text := DisplayNameForHotkeyString(CurrentKeysGet(actionName))
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

HasOutputKey(actionName)
{
    global DefaultOutputKeys
    return DefaultOutputKeys.Has(actionName)
}

IsMouseKeyName(keyName)
{
    return keyName = "MButton" || keyName = "XButton1" || keyName = "XButton2"
}

IsValidOutputKey(keyName)
{
    if keyName = "" || keyName = "Escape" || IsModifierKeyName(keyName) || IsMouseKeyName(keyName)
        return false
    try
    {
        vk := GetKeyVK(keyName)
        sc := GetKeySC(keyName)
        return vk > 0 && sc > 0
    }
    catch
        return false
}

DisplayNameForOutputKey(keyName)
{
    ; Display single-letter output bindings in uppercase without changing the
    ; stored key name used by GetKeyVK/GetKeySC and the background send logic.
    if RegExMatch(keyName, "i)^[a-z]$")
        return StrUpper(keyName)

    return keyName = "Space" ? "Space" : keyName
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

ToggleChangeOutputKeys(ctrlObj, info)
{
    global ChangeOutputKeys, RebindGui, ListeningForAction

    if ListeningForAction != ""
    {
        ctrlObj.Value := ChangeOutputKeys ? 1 : 0
        return
    }

    ChangeOutputKeys := ctrlObj.Value ? true : false
    SaveChangeOutputKeys(ChangeOutputKeys)

    oldGui := RebindGui
    SetTimer(() => RebuildGuiForOutputKeyMode(oldGui), -1)
}

RebuildGuiForOutputKeyMode(oldGui)
{
    global RebindGui

    try oldGui.Destroy()
    BuildGui()
}

ResetAllToDefaults(*)
{
    global ActionNames, DefaultKeys, RebindButtons, OutputActionNames, DefaultOutputKeys, CurrentOutputKeys, OutputKeyButtons
    global StatusCtrl, AutoClickInterval, AutoClickDefaultInterval, AutoClickPaused, TrainSlowInterval, TrainSlowDefaultInterval

    for actionName in OutputActionNames
        StopOutputAction(actionName)

    for actionName in ActionNames
    {
        RebindAction(actionName, DefaultKeys[actionName])
        RebindButtons[actionName].Text := DisplayNameForHotkeyString(DefaultKeys[actionName])
    }

    for actionName in OutputActionNames
    {
        CurrentOutputKeys[actionName] := DefaultOutputKeys[actionName]
        SaveOutputKey(actionName, DefaultOutputKeys[actionName])
        if OutputKeyButtons.Has(actionName)
            OutputKeyButtons[actionName].Text := DisplayNameForOutputKey(DefaultOutputKeys[actionName])
    }

    AutoClickInterval := AutoClickDefaultInterval
    AutoClickPaused := false
    SaveAutoClickInterval(AutoClickInterval)
    TrainSlowInterval := TrainSlowDefaultInterval
    SaveTrainSlowInterval(TrainSlowInterval)
    StatusCtrl.Text := "All activation hotkeys, output keys, and timing values reset to defaults."
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
    global DefaultKeys, RebindButtons, ActionLabels, StatusCtrl, TrainSlowInterval, TrainSlowDefaultInterval
    global AutoClickInterval, AutoClickDefaultInterval, AutoClickActive, AutoClickPaused
    global DefaultOutputKeys, CurrentOutputKeys, OutputKeyButtons

    if HasOutputKey(actionName)
        StopOutputAction(actionName)

    RebindAction(actionName, DefaultKeys[actionName])
    RebindButtons[actionName].Text := DisplayNameForHotkeyString(DefaultKeys[actionName])

    outputSummary := ""
    if HasOutputKey(actionName)
    {
        CurrentOutputKeys[actionName] := DefaultOutputKeys[actionName]
        SaveOutputKey(actionName, DefaultOutputKeys[actionName])
        if OutputKeyButtons.Has(actionName)
            OutputKeyButtons[actionName].Text := DisplayNameForOutputKey(DefaultOutputKeys[actionName])
        outputSummary := " and sends " DisplayNameForOutputKey(DefaultOutputKeys[actionName])
    }

    if (actionName = "TrainSlow")
    {
        TrainSlowInterval := TrainSlowDefaultInterval
        SaveTrainSlowInterval(TrainSlowInterval)
        StatusCtrl.Text := "'Train Slow' reset to F9, sends W, with a 300 ms interval."
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
        StatusCtrl.Text := "'" ActionLabels[actionName] "' reset to " DisplayNameForHotkeyString(DefaultKeys[actionName]) outputSummary "."
}


CheckForUpdate()
{
    global AppVersion, GitHubLatestReleaseApi, LatestVersion, UpdateAvailable, UpdateCheckComplete

    try
    {
        request := ComObject("WinHttp.WinHttpRequest.5.1")
        request.SetTimeouts(3000, 3000, 5000, 5000)
        request.Open("GET", GitHubLatestReleaseApi, false)
        request.SetRequestHeader("Accept", "application/vnd.github+json")
        request.SetRequestHeader("User-Agent", "Foxhole-Autoclicker/" AppVersion)
        request.SetRequestHeader("X-GitHub-Api-Version", "2022-11-28")
        request.Send()

        if request.Status != 200
            return

        ; GitHub's /releases/latest endpoint returns the latest published,
        ; non-draft, non-prerelease release. Tags alone are not releases.
        if !RegExMatch(request.ResponseText, '"tag_name"\s*:\s*"([^"]+)"', &tagMatch)
            return

        checkedVersion := NormalizeVersion(tagMatch[1])
        if checkedVersion = ""
            return

        LatestVersion := checkedVersion
        UpdateAvailable := IsVersionNewer(LatestVersion, AppVersion)
        UpdateCheckComplete := true
        ApplyUpdateState()
    }
    catch
    {
        ; Network failures are intentionally silent. The recurring timer will
        ; try again later without interrupting normal autoclicker operation.
    }
}

ApplyUpdateState()
{
    global RebindGui, NormalWindowTitle, UpdateWindowTitle, UpdateAvailable, LatestVersion, StatusCtrl

    if !IsObject(RebindGui)
        return

    try
    {
        if UpdateAvailable
        {
            RebindGui.Title := UpdateWindowTitle " (v" LatestVersion ")"
            if IsObject(StatusCtrl)
                StatusCtrl.Text := "Update available: version " LatestVersion "."
        }
        else
            RebindGui.Title := NormalWindowTitle
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

ReleaseAllOutputKeys(*)
{
    global OutputActionNames
    for actionName in OutputActionNames
        StopOutputAction(actionName)
}

BuildKeyboardLParam(scanCode, isKeyUp := false, isExtended := false)
{
    lParam := 1 | ((scanCode & 0xFF) << 16)
    if isExtended
        lParam |= (1 << 24)
    if isKeyUp
        lParam |= (1 << 30) | (1 << 31)
    return lParam
}

IsExtendedOutputKey(keyName)
{
    static extendedKeys := Map(
        "Insert", true, "Delete", true, "Home", true, "End", true, "PgUp", true, "PgDn", true,
        "Up", true, "Down", true, "Left", true, "Right", true, "RControl", true, "RAlt", true,
        "NumpadDiv", true, "NumpadEnter", true, "LWin", true, "RWin", true, "AppsKey", true
    )
    return extendedKeys.Has(keyName)
}

PostBackgroundKeyDown(keyName)
{
    global TargetWindow
    targetHwnd := WinExist(TargetWindow)
    if !targetHwnd || !IsValidOutputKey(keyName)
        return false
    vk := GetKeyVK(keyName)
    sc := GetKeySC(keyName)
    PostMessage(0x0100, vk, BuildKeyboardLParam(sc, false, IsExtendedOutputKey(keyName)), , "ahk_id " targetHwnd)
    return true
}

PostBackgroundKeyUp(keyName)
{
    global TargetWindow
    targetHwnd := WinExist(TargetWindow)
    if !targetHwnd || !IsValidOutputKey(keyName)
        return false
    vk := GetKeyVK(keyName)
    sc := GetKeySC(keyName)
    PostMessage(0x0101, vk, BuildKeyboardLParam(sc, true, IsExtendedOutputKey(keyName)), , "ahk_id " targetHwnd)
    return true
}

PostBackgroundKeyPress(keyName)
{
    if PostBackgroundKeyDown(keyName)
        PostBackgroundKeyUp(keyName)
}

StopOutputAction(actionName)
{
    global AutoWalkActive, AutoReverseActive, VSpamActive, TrainSlowActive, CurrentOutputKeys

    if actionName = "AutoWalk"
    {
        SetTimer(SendBackgroundForward, 0)
        PostBackgroundKeyUp(CurrentOutputKeys["AutoWalk"])
        AutoWalkActive := false
    }
    else if actionName = "AutoReverse"
    {
        SetTimer(SendBackgroundReverse, 0)
        PostBackgroundKeyUp(CurrentOutputKeys["AutoReverse"])
        AutoReverseActive := false
    }
    else if actionName = "VSpam"
    {
        SetTimer(SendBackgroundSpamKey, 0)
        PostBackgroundKeyUp(CurrentOutputKeys["VSpam"])
        VSpamActive := false
    }
    else if actionName = "TrainSlow"
    {
        SetTimer(SendBackgroundTrainSlow, 0)
        PostBackgroundKeyUp(CurrentOutputKeys["TrainSlow"])
        TrainSlowActive := false
    }
}

Hotkey_AutoWalk(*)
{
    global AutoWalkActive, CurrentOutputKeys, TargetWindow
    if !WinExist(TargetWindow)
    {
        ShowTooltip("Foxhole window not found!", 2000)
        return
    }

    StopOutputAction("AutoReverse")
    StopOutputAction("TrainSlow")
    AutoWalkActive := !AutoWalkActive

    if AutoWalkActive
    {
        ShowTooltip("FORWARD — holding " DisplayNameForOutputKey(CurrentOutputKeys["AutoWalk"]), 1500)
        SendBackgroundForward()
        SetTimer(SendBackgroundForward, 50)
    }
    else
    {
        ShowTooltip("Forward OFF", 1500)
        StopOutputAction("AutoWalk")
    }
}

SendBackgroundForward()
{
    global CurrentOutputKeys
    PostBackgroundKeyDown(CurrentOutputKeys["AutoWalk"])
}

Hotkey_AutoReverse(*)
{
    global AutoReverseActive, CurrentOutputKeys, TargetWindow
    if !WinExist(TargetWindow)
    {
        ShowTooltip("Foxhole window not found!", 2000)
        return
    }

    StopOutputAction("AutoWalk")
    StopOutputAction("TrainSlow")
    AutoReverseActive := !AutoReverseActive

    if AutoReverseActive
    {
        ShowTooltip("REVERSE — holding " DisplayNameForOutputKey(CurrentOutputKeys["AutoReverse"]), 1500)
        SendBackgroundReverse()
        SetTimer(SendBackgroundReverse, 50)
    }
    else
    {
        ShowTooltip("Reverse OFF", 1500)
        StopOutputAction("AutoReverse")
    }
}

SendBackgroundReverse()
{
    global CurrentOutputKeys
    PostBackgroundKeyDown(CurrentOutputKeys["AutoReverse"])
}

Hotkey_TrainSlow(*)
{
    global TrainSlowActive, TrainSlowInterval, CurrentOutputKeys, TargetWindow
    if !WinExist(TargetWindow)
    {
        ShowTooltip("Foxhole window not found!", 2000)
        return
    }

    StopOutputAction("AutoWalk")
    StopOutputAction("AutoReverse")
    TrainSlowActive := !TrainSlowActive

    if TrainSlowActive
    {
        ShowTooltip("Train Slow ON — pressing " DisplayNameForOutputKey(CurrentOutputKeys["TrainSlow"]) " (Shift+Scroll)", 2500)
        SendBackgroundTrainSlow()
        SetTimer(SendBackgroundTrainSlow, TrainSlowInterval)
    }
    else
    {
        ShowTooltip("Train Slow OFF", 1500)
        StopOutputAction("TrainSlow")
    }
}

SendBackgroundTrainSlow()
{
    global CurrentOutputKeys, TrainSlowHoldDuration
    keyName := CurrentOutputKeys["TrainSlow"]
    if PostBackgroundKeyDown(keyName)
    {
        Sleep(TrainSlowHoldDuration)
        PostBackgroundKeyUp(keyName)
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
    SetTimer(SendBackgroundTrainSlow, TrainSlowInterval)
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
    global VSpamActive, CurrentOutputKeys, TargetWindow

    if !WinExist(TargetWindow)
    {
        ShowTooltip("Foxhole window not found!", 2000)
        return
    }

    VSpamActive := !VSpamActive

    if VSpamActive
    {
        ShowTooltip("Submit Large Item ON — pressing " DisplayNameForOutputKey(CurrentOutputKeys["VSpam"]), 2500)
        SendBackgroundSpamKey()
        SetTimer(SendBackgroundSpamKey, 50)
    }
    else
    {
        ShowTooltip("Submit Large Item OFF", 1500)
        StopOutputAction("VSpam")
    }
}

SendBackgroundSpamKey()
{
    global CurrentOutputKeys
    PostBackgroundKeyPress(CurrentOutputKeys["VSpam"])
}

