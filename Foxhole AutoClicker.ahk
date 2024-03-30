#singleInstance, Force
#MaxThreadsPerHotkey 2
DetectHiddenWindows,on
SetWorkingDir, %A_ScriptDir%

IniRead, Suspend, bin\KeyBindings.ini, Hotkeys, Suspend
IniRead, Close, bin\KeyBindings.ini, Hotkeys, Close

Menu, Tray, Icon, bin\icon.ico
Gui, New
Gui, Margin, 40, 10
Gui, Font, s11, Verdana
Gui, Add, Picture,w150 h150, bin\iconLarge.png
Gui, Add, Text,, Foxhole AutoClicker                   
Gui, Font, s8, Verdana
Gui, Add, GroupBox, x20 y200 w170 h115, Controls
Gui, Add, Button, xp+20 yp+20 gRunHotkey, Start Hotkeys
Gui, Add, Button, gSuspendHotkey, Suspend Hotkeys - %Suspend%
Gui, Add, Button, gExitHotkey, Close Hotkeys - %Close%
Gui, Add, GroupBox, x20 y320 w170 h82, KeyBinds
Gui, Add, Button, xp+20 yp+20 gChangeKeybindGUI, Change Keybinds
Gui, Add, Button, gviewKeybinds, View Keybinds
Gui, Font, s8, Verdana
Gui, Add, CheckBox, gontop, Window Always on Top?
Gui, Add, Link,, <a href="https://github.com/Tommythebold/Foxhole-AutoClicker">GitHub</a>
Gui, Show
return

ChangeKeybindGUI:
{
	Gui, Keys:New
	Gui, Keys:Margin, 40, 10
	Gui, Keys:Font, s12, Verdana
	Gui, Keys:Add, Picture,w150 h150, bin\iconLarge.png
	Gui, Keys:Add, Text,, Change Keybinds
	Gui, Keys:Font, s8, Verdana
	Gui, Keys:Add, Button, gSetKeyW, Set Key for Hold W
	Gui, Keys:Add, Button, gSetKeyS, Set Key for Hold S
	Gui, Keys:Add, Button, gSetKeyRight, Set Key for Hold Right
	Gui, Keys:Add, Button, gSetKeyLeft, Set Key for Hold Left
	Gui, Keys:Add, Button, gSetKeySpamLeft, Set Key for Spam Left
	Gui, Keys:Add, Button, gSetKeySuspend, Set Key for Suspend
	Gui, Keys:Add, Button, gSetKeyClose, Set Key for Close
	Gui, Keys:Show
}
return

SetKeyW:
{
	var1 := KeyWaitCombo()
	IniWrite, %var1%, bin\KeyBindings.ini, Hotkeys, Hold W
}
return

SetKeyS:
{
	var1 := KeyWaitCombo()
	IniWrite, %var1%, bin\KeyBindings.ini, Hotkeys, Hold S
}
return

SetKeyRight:
{
	var1 := KeyWaitCombo()
	IniWrite, %var1%, bin\KeyBindings.ini, Hotkeys, Hold Right
}
return

SetKeyLeft:
{
	var1 := KeyWaitCombo()
	IniWrite, %var1%, bin\KeyBindings.ini, Hotkeys, Hold Left
}
return

SetKeySpamLeft:
{
	var1 := KeyWaitCombo()
	IniWrite, %var1%, bin\KeyBindings.ini, Hotkeys, Spam Left
}
return

SetKeySuspend:
{
	var1 := KeyWaitCombo()
	IniWrite, %var1%, bin\KeyBindings.ini, Hotkeys, Suspend
}
return

SetKeyClose:
{
	var1 := KeyWaitCombo()
	IniWrite, %var1%, bin\KeyBindings.ini, Hotkeys, Close
}
return

KeyWaitCombo(Options:="")
{
	ToolTip, Press a Key
	SetTimer, RemoveToolTip, -5000

    ih := InputHook(Options)
    if !InStr(Options, "V")
        ih.VisibleNonText := false
    ih.KeyOpt("{All}", "E")
    ih.KeyOpt("{LCtrl}{RCtrl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}", "-E")
    ih.Start()
    ErrorLevel := ih.Wait()
	var := ih.EndMods . ih.EndKey
	endkey := ih.EndKey
	var1 := Escape
	if endkey == %var1%
		{
			return
		}
	ToolTip, Set to %var%
	SetTimer, RemoveToolTip, -2000
    return ih.EndMods . ih.EndKey 
}

RemoveToolTip:
{
	ToolTip
	return
}
return

RunHotkey:
{
	Run, bin\FoxholeHotkeys.ahk
}
return

SuspendHotKey:
{
	IniRead, Suspend, bin\KeyBindings.ini, Hotkeys, Suspend
	Send {%Suspend%}
}
return

ExitHotkey:
{
	IniRead, Close, bin\KeyBindings.ini, Hotkeys, Close
	IniRead, Suspend, bin\KeyBindings.ini, Hotkeys, Suspend
	Send {%Close%}
	Send {%Suspend%}
	Send {%Close%}
}
return

viewKeybinds:
{
	Run, bin\KeyBindings.ini
}
return

ontop:
{
	T := !T
	If T
		Gui +AlwaysOnTop
	else
		Gui -AlwaysOnTop
}
return

GuiClose:
ExitApp