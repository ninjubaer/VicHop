/*
$$\   $$\                           $$\
$$ |  $$ |                          $$ |
$$ |  $$ | $$$$$$\   $$$$$$\   $$$$$$$ |
$$$$$$$$ |$$  __$$\  \____$$\ $$  __$$ |
$$  __$$ |$$$$$$$$ | $$$$$$$ |$$ /  $$ |
$$ |  $$ |$$   ____|$$  __$$ |$$ |  $$ |
$$ |  $$ |\$$$$$$$\ \$$$$$$$ |\$$$$$$$ |
\__|  \__| \_______| \_______| \_______|
*/
#NoEnv
#SingleInstance, force
#Requires AutoHotkey v1.1.36.01+
SetBatchLines, -1
SetWorkingDir %A_ScriptDir%
#Include lib/Gdip_all.ahk
#Include lib/Gdip_ImageSearch.ahk
#Include lib/Ocr.ahk
#Include lib/HyperSleep.ahk
#include lib/Socket.ahk
pToken := Gdip_Startup()
clients := []
HourlyStingers := 0
RunWith(32)
RunWith(bits) {
	If (A_IsUnicode && (A_PtrSize = (bits = 32 ? 4 : 8)))
		Return

	SplitPath, A_AhkPath,, ahkDirectory

	If (!FileExist(ahkPath := ahkDirectory "\AutoHotkeyU" bits ".exe"))
		MsgBox, 0x10, "Error", % "Couldn't find the " bits "-bit Unicode version of Autohotkey in:`n" ahkPath
	Else
		Reload(ahkpath)

	ExitApp
}
Reload(ahkpath) {
	static cmd := DllCall("GetCommandLine", "Str"), params := DllCall("shlwapi\PathGetArgs","Str",cmd,"Str")
	Run, "%ahkpath%" /r %params%
}
;create config file
If (!FileExist("Settings"))
{
   FileCreateDir, settings
   If (ErrorLevel)
   {
      MsgBox, 0x30,, Couldn't create the settings directory! Make sure the script is elevated if it needs to be.
      ExitApp
   }
}

If (!FileExist("Settings/config.ini"))
{
	FileAppend, [Socket]`nHost=localhost`nPort=6969`n[GUI]`nTheme=MacLion3`n[Planter]`n`n[Settings]`nPrivServer=`nWebhookCheck=`nWebhookURL=`nMoveSpeed=28, Settings/config.ini
}
if (!FileExist(A_ScriptDir . "\Styles\USkin.dll"))
	MsgBox, dll file not exist

;create ini values obj
IniValues:={"Socket":"Host", "Socket":"Port", "GUI":"Theme", "Setting":"PrivServer", "Settings":"WebhookCheck", "Settings":"WebhookURL", "Settings":"MoveSpeed"}
;read ini values from iniValues obj
for k,v in IniValues
{
	IniRead, %v%, Settings/config.ini, %k%, %v%
}

/*
 $$$$$$\  $$\   $$\ $$$$$$\
$$  __$$\ $$ |  $$ |\_$$  _|
$$ /  \__|$$ |  $$ |  $$ |
$$ |$$$$\ $$ |  $$ |  $$ |
$$ |\_$$ |$$ |  $$ |  $$ |
$$ |  $$ |$$ |  $$ |  $$ |
\$$$$$$  |\$$$$$$  |$$$$$$\
 \______/  \______/ \______|
*/

importStyles()
SkinForm(Apply, A_ScriptDir . "\Styles\USkin.dll" , A_ScriptDir . "\Styles\" . Theme . ".msstyles")
OnExit("GetOut")
/*
if (A_ScreenDPI*100//96 != 100)
	msgbox, 0x1030, WARNING!!, % "Your Display Scale seems to be a value other than 100`%. This means the macro will NOT work correctly!`n`nTo change this, right click on your Desktop -> Click 'Display Settings' -> Under 'Scale & Layout', set Scale to 100`% -> Close and Restart Roblox before starting the macro.", 60
*/
Gui main:+border +hwndhGUI +OwnDialogs
; Footer
Gui, main:Add, Button, x5 y260 w65 h20 -Wrap vStartButton, % " Start (F1)"
Gui, main:Add, Button, x75  y260 w65 h20 -Wrap vPauseButton, % " Pause (F2)"
Gui, main:Add, Button, x145 y260 w65 h20 -Wrap vStopButton, % " Stop (F3)"
Gui, main:Add, Text, x215 y263 w90 h15 +Border +BackgroundTrans, % " Connections: " (clients.maxindex() ? clients.maxindex() : 0)
Gui, main:Add, Text, x310 y263 w100 h15 +Border +BackgroundTrans, % " Hourly Stingers: " HourlyStingers
Gui, main:Font, w700
Gui, main:Add, Text, x435 y263 , BETAv1

;header
Gui, main:Font, cDefault norm s8, Tahoma
Gui, main:Add, Tab, x0 y0 w502 h240 -Wrap hwndhTab vTab, Main|Planter|Status|Settings|Contributor
SendMessage, 0x1331, 0, 99, , ahk_id %hTab% ; set minimum tab width
Gui, main:Tab, Main
Gui, main:Font, cDefault w700 s13 underline, Tahoma
Gui, main:Add, Text, x7 y31 +backgroundtrans, Main Settings
Gui, main:Font, s9 norm w700 
Gui, main:Add, GroupBox, x5 y60 w160 h150 vHostConnectBox, Setup Host
Gui, main:Font, cDefault norm s9, Tahoma
Gui, main:Add, Text, x10 y80 +BackgroundTrans vHostText, Host:
Gui, main:Add, Edit, x10 y100 w140 h20 r1 vHostIP, localhost
Gui, main:Add, Text, x10 y130 +BackgroundTrans vHostPortText, Port (min 4 characters):
Gui, main:Add, Edit, x10 y150 w140 h20 r1 vHostPort, 6969
Gui, main:Add, Button, x10 y170 w140 h20 vHostBind, Bind
;Groupbox Functions Host
Gui, main:Font, s9 w700
Gui, main:Add, GroupBox, x170 y60 w325 h150 vHostFunctionBox, Options
Gui, main:Font, s9
Gui, main:Add, Checkbox, x175 y80 vHostFunctionsVicious disabled, Placeholder for future
Gui, main:Font, s10
;status tab
Gui, main:Tab, Status
Gui, main:Font, cDefault w700 s13 underline, Tahoma
Gui, main:Add, Text, x9 y31 +backgroundtrans, Status
Gui, main:Font, s9 norm w700 
Gui, main:Add, GroupBox, x7 y60 w200 h90 vWebhookFunctionBox, Webhook
Gui, main:Font, cDefault norm s9, Tahoma

Gui, main:Add, Checkbox, x10 y75 vWebhookCheck gWebhookCheck, Enable Webhook
Gui, main:Add, Text, x10 y100, WebhookURL
Gui, main:Add, Edit,% "x10 y115 w190 h19 r1 vWebhookURL " (WebhookCheck ? "" : "disabled")


Gui, main:show, w500 h285, VicHop Macro
return

WebhookCheck(){
    GuiControlGet, WebhookCheck
    GuiControl, % (WebhookCheck ? "enable" : "disable"), WebhookURL
}


/*
                        $$\                   $$\     $$\                                           $$\
                        \__|                  $$ |    $$ |                                          $$ |
$$$$$$\$$$$\   $$$$$$\  $$\ $$$$$$$\        $$$$$$\   $$$$$$$\   $$$$$$\   $$$$$$\   $$$$$$\   $$$$$$$ |
$$  _$$  _$$\  \____$$\ $$ |$$  __$$\       \_$$  _|  $$  __$$\ $$  __$$\ $$  __$$\  \____$$\ $$  __$$ |
$$ / $$ / $$ | $$$$$$$ |$$ |$$ |  $$ |        $$ |    $$ |  $$ |$$ |  \__|$$$$$$$$ | $$$$$$$ |$$ /  $$ |
$$ | $$ | $$ |$$  __$$ |$$ |$$ |  $$ |        $$ |$$\ $$ |  $$ |$$ |      $$   ____|$$  __$$ |$$ |  $$ |
$$ | $$ | $$ |\$$$$$$$ |$$ |$$ |  $$ |        \$$$$  |$$ |  $$ |$$ |      \$$$$$$$\ \$$$$$$$ |\$$$$$$$ |
\__| \__| \__| \_______|\__|\__|  \__|         \____/ \__|  \__|\__|       \_______| \_______| \_______|

*/

;-------------------------------------------------------------------------------------
/*
 $$$$$$\                                  $$\     $$\
$$  __$$\                                 $$ |    \__|
$$ /  \__|$$\   $$\ $$$$$$$\   $$$$$$$\ $$$$$$\   $$\  $$$$$$\  $$$$$$$\   $$$$$$$\
$$$$\     $$ |  $$ |$$  __$$\ $$  _____|\_$$  _|  $$ |$$  __$$\ $$  __$$\ $$  _____|
$$  _|    $$ |  $$ |$$ |  $$ |$$ /        $$ |    $$ |$$ /  $$ |$$ |  $$ |\$$$$$$\
$$ |      $$ |  $$ |$$ |  $$ |$$ |        $$ |$$\ $$ |$$ |  $$ |$$ |  $$ | \____$$\
$$ |      \$$$$$$  |$$ |  $$ |\$$$$$$$\   \$$$$  |$$ |\$$$$$$  |$$ |  $$ |$$$$$$$  |
\__|       \______/ \__|  \__| \_______|   \____/ \__| \______/ \__|  \__|\_______/
*/
GetOut(){
Gui, Hide
SkinForm(0)
ExitApp
return
}

importStyles() {
	global StylesList, Theme
	StylesList := ""
	Loop, Files, %A_ScriptDir%\Styles\*.msstyles
		StylesList .= "|" A_LoopFileName

	StylesList .= "|", StylesList := StrReplace(StylesList, ".msstyles")

	if !(Instr(StylesList, GuiTheme))
		StylesList .= GuiTheme "|"
}

GuiClose:
Gui, Hide
SkinForm(0)
ExitApp
return

SkinForm(Param1 = "Apply", DLL = "", SkinName = ""){
	if(Param1 = Apply){
		DllCall("LoadLibrary", str, DLL)
		DllCall(DLL . "\USkinInit", Int,0, Int,0, AStr, SkinName)
	}
    else if(Param1 = 0){
		DllCall(DLL . "\USkinExit")
	}
}