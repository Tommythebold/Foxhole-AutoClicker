﻿#singleInstance, Force
#MaxThreadsPerHotkey 2
SetWorkingDir, %A_ScriptDir%

;------------------------------------------------------------;
; Foxhole Hotkeys - GUI Version - by Tommythebold            ;
;------------------------------------------------------------;
; Default key bindings are:									 ;
; F2 - Spam Left Click at Location                           ;
; F3 - Hold W                                                ;
; F4 - Hold S                                                ;
; F5 - Hold Right Click                                      ;
; F6 - Hold Left Click                                       ;
; F7 - Suspend Program                                       ;
; F9 - Exit Program                                          ;
; All hotkeys work while tabbed out.                         ;
;------------------------------------------------------------;
; If you want to manually change keybinds, use the           ;
; FoxholeHotkeysManual version in the bin folder.            ;
; https://github.com/Tommythebold/Foxhole-AutoClicker        ;
;------------------------------------------------------------;

IniRead, HoldW, KeyBindings.ini, Hotkeys, Hold W
IniRead, HoldS, KeyBindings.ini, Hotkeys, Hold S
IniRead, HoldLeft, KeyBindings.ini, Hotkeys, Hold Left
IniRead, HoldRight, KeyBindings.ini, Hotkeys, Hold Right
IniRead, SpamLeft, KeyBindings.ini, Hotkeys, Spam Left
IniRead, SpamLeftBuild, KeyBindings.ini, Hotkeys, Spam Left Build
IniRead, Suspend, KeyBindings.ini, Hotkeys, Suspend
IniRead, Close, KeyBindings.ini, Hotkeys, Close

Hotkey, %HoldW%, Hold_W
Hotkey, %HoldS%, Hold_S
Hotkey, %HoldRight%, Hold_Right
Hotkey, %HoldLeft%, Hold_Left
Hotkey, %SpamLeft%, Spam_Left
Hotkey, %SpamLeftBuild%, Spam_Left_Build
Hotkey, %Suspend%, Key_Suspend
Hotkey, %Close%, Key_Close
return

;-----------------------------;
; Spam Left Click at Location ;
;-----------------------------;

Spam_Left:
MouseGetPos, xpos, ypos
T := !T
While (T) {
	ControlClick, X%xpos% Y%ypos%, ahk_class UnrealWindow, , Left, 1
	sleep, 100
}
return

;-----------------;
; Hold Left Click ;
;-----------------;

Hold_Left:
MouseGetPos, xpos, ypos
T := !T
While (T) {
	ControlClick, X%xpos% Y%ypos%, ahk_class UnrealWindow, , Left, 1, D
}
ControlClick, X%xpos% Y%ypos%, ahk_class UnrealWindow, , Left, 1, u
return

;------------------------------;
; Spam Left Click for Building ;
;------------------------------;
Spam_Left_Build:
T := !T
While (T) {
	PostMessage, 0x0200, 0, cX&0xFFFF | cY<<16,, ahk_class UnrealWindow ; WM_MOVEMOUSE
	PostMessage, 0x201, 0, cX&0xFFFF | cY<<16,, ahk_class UnrealWindow ; WM_LBUTTONDOWN  
  	PostMessage, 0x202, 0, cX&0xFFFF | cY<<16,, ahk_class UnrealWindow ; WM_LBUTTONUP  
	sleep, 100
}
return

;------------------;
; Hold Right Click ;
;------------------;

Hold_Right:
MouseGetPos, xpos, ypos
T := !T
While (T) {
	ControlClick, X%xpos% Y%ypos%, ahk_class UnrealWindow, , Right, 1, D
}
ControlClick, X%xpos% Y%ypos%, ahk_class UnrealWindow, , Right, 1, u
return

;---------;
; Hold W  ;
;---------;

Hold_W:
toggle := !toggle
ControlSend,,{w down}, ahk_class UnrealWindow
if (toggle) {
	SetTimer, PressW, 1000
}	else {
	SetTimer, PressW, Off
	ControlSend,,{w up}, ahk_class UnrealWindow
}
return

PressW:
ControlSend,,{w down}, ahk_class UnrealWindow
return

;--------;
; Hold S ;
;--------;

Hold_S:
toggle := !toggle
ControlSend,,{s down}, ahk_class UnrealWindow
if (toggle) {
	SetTimer, PressS, 1000
}	else {
	SetTimer, PressS, Off
	ControlSend,,{s up}, ahk_class UnrealWindow
}
return

PressS:
ControlSend,,{s down}, ahk_class UnrealWindow
return

;-----------------;
; Suspend Program ;
;-----------------;

Key_Suspend:
Suspend
return

;---------------;
; Close Program ;
;---------------;

Key_Close:
ExitApp
