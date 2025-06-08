#singleInstance, Force
#MaxThreadsPerHotkey 2

;------------------------------------------------------------;
; To change keybindings, edit the value before the "::".     ;
; A list of keys and modifiers can be found here:            ;
; https://www.autohotkey.com/docs/v1/lib/Send.htm#Parameters ;
; ^ = Control, + = Shift, ! = Alt, etc.                      ;
;------------------------------------------------------------;

;---------;
; Spam R  ;
;---------;

F7::
T := !T
If (T) {
	While (T) {
		ControlSend,,{r down}, ahk_class UnrealWindow
		ControlSend,,{r up}, ahk_class UnrealWindow
	}
}
return

F10::ExitApp
