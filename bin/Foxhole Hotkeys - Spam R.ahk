#singleInstance, Force
#MaxThreadsPerHotkey 2

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
