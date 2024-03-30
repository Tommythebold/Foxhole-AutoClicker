#singleInstance, Force
#MaxThreadsPerHotkey 2
SetWorkingDir, %A_ScriptDir%

;------------------------------------------------------------;
; Foxhole Hotkeys - GUI Version - by Tommythebold            ;
;------------------------------------------------------------;
; Default key bindings are:				     ;
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
; https://github.com/Tommythebold/foxholeautoclicker         ;
;------------------------------------------------------------;

IniRead, HoldW, KeyBindings.ini, Hotkeys, Hold W
IniRead, HoldS, KeyBindings.ini, Hotkeys, Hold S
IniRead, HoldLeft, KeyBindings.ini, Hotkeys, Hold Left
IniRead, HoldRight, KeyBindings.ini, Hotkeys, Hold Right
IniRead, SpamLeft, KeyBindings.ini, Hotkeys, Spam Left
IniRead, Suspend, KeyBindings.ini, Hotkeys, Suspend
IniRead, Close, KeyBindings.ini, Hotkeys, Close

Hotkey, %HoldW%, Hold_W
Hotkey, %HoldS%, Hold_S
Hotkey, %HoldRight%, Hold_Right
Hotkey, %HoldLeft%, Hold_Left
Hotkey, %SpamLeft%, Spam_Left
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
T := !T
If (T) {
	While (T) {
		ControlSend,,{w down}, ahk_class UnrealWindow
	}
}
ControlSend,,{w up}, ahk_class UnrealWindow
return

;--------;
; Hold S ;
;--------;

Hold_S:
T := !T
	If (T) {
		While (T) {
			ControlSend,,{s down}, ahk_class UnrealWindow
}
}
ControlSend,,{s up}, ahk_class UnrealWindow
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
