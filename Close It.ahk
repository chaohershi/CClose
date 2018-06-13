#SingleInstance ignore ; allow only one instance of this script to be running
; add tray menu
Menu, Tray, Icon, , , 1
Menu, Tray, NoStandard
Menu, Tray, Add, Autostart, AutostartProgram
Menu, Tray, Add, Suspend, SuspendProgram
Menu, Tray, Add, Exit, ExitProgram

; add shortcut to Startup folder
SplitPath, A_Scriptname, , , , OutNameNoExt
LinkFile := A_Startup . "\" . OutNameNoExt . ".lnk"
if A_IsAdmin
{
	FileCreateShortcut, %A_ScriptFullPath%, %LinkFile%
}

; check Autostart menu if shortcut exists in Startup folder
IsAutostart := FileExist(LinkFile)
if IsAutostart
{
	Menu, Tray, Check, Autostart
}

Return ; end of auto-execute section

AutostartProgram:
if IsAutostart
{
	Menu, Tray, Uncheck, Autostart ; uncheck Autostart menu
	FileDelete, %LinkFile% ; delete shortcut
	IsAutostart := false
}
else
{
	; restart and try run as administrator
	full_command_line := DllCall("GetCommandLine", "str")
	if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
	{
		MsgBox, Close It will need your premission to create a shortcut in the Windows Startup folder.
		try
		{
			if A_IsCompiled
			{
				Run *RunAs "%A_ScriptFullPath%" /restart
			}
			else
			{
				Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
			}
			ExitApp
		}
	}
	else
	{
		if A_IsAdmin
		{
			FileCreateShortcut, %A_ScriptFullPath%, %LinkFile%
			Menu, Tray, Check, Autostart
			IsAutostart := true
		}
	}
}
Return

SuspendProgram:
Menu, Tray, ToggleCheck, Suspend
Suspend, Toggle
Return

ExitProgram:
ExitApp

#If MouseIsOver("ahk_class Shell_TrayWnd") ; apply the following hotkey only if the mouse is over the taskbar
~RButton:: ; when right clicked
sleep 350 ; wait for the Jump List to pop up (if clicked on apps)

if WinActive("ahk_class Windows.UI.Core.CoreWindow") ; if Jump List pops up
{
	WinGetPos, , , width, height, A ; get active window (Jump List) position
	MouseMove, (width - 128), (height - 24), 1 ; move mouse to the bottom of the Jump List (Close window)
}

MouseIsOver(WinTitle)
{
	MouseGetPos, , , Win
	Return WinExist(WinTitle . " ahk_id " . Win)
}

#If ; apply the following hotkey with no conditions
~Esc::
if (A_TimeSincePriorHotkey < 400) and (A_PriorHotkey = "~Esc") ; if double press Esc
{
	KeyWait, Esc ; wait for Esc to be released
	WinGetClass, class, A
	if class in Shell_TrayWnd,Progman,WorkerW
	{
		Return ; do nothing if the active window is taskbar or desktop
	}
	WinClose, A ; close active window
	Return
}
