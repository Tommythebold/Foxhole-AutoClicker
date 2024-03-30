#singleInstance, Force
#MaxThreadsPerHotkey 2

;------------------------------------------------------------;
; Foxhole Hotkeys - Manual Version - by Tommythebold         ;
;------------------------------------------------------------;
; A version with GUI for setting keybinds is available at    ;
; https://github.com/Tommythebold/Foxhole-AutoClicker        ;
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
; To change keybindings, edit the value before the "::".     ;
; A list of keys and modifiers can be found here:            ;
; https://www.autohotkey.com/docs/v1/lib/Send.htm#Parameters ;
; ^ = Control, + = Shift, ! = Alt, etc.                      ;
;------------------------------------------------------------;

;-----------------------------;
; Spam Left Click at Location ;
;-----------------------------;

F2::
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

F6::
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

F5::
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

F3::
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

F4::
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

F7::Suspend

;---------------;
; Close Program ;
;---------------;

F9::ExitApp
