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
TotalStingersGained := 0
TotalVicKills := 0
SessionVicKills := 0
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
	FileAppend, [Socket]`nHost=localhost`nPort=6969`n[GUI]`nTheme=MacLion3`n[Planter]`n`n[Settings]`nPrivServer=`nWebhookCheck=`nWebhookURL=`nUserID=`nscreenshots=`nBackupLink1=`nBackupLink2=`nMainLink=`nFallbackServers=`nKeyDelay=20`nGuiTransparency=0`nAlwaysOnTop=1`nHiveSlot=6`nMoveSpeed=28, Settings/config.ini
}
if (!FileExist(A_ScriptDir . "\Styles\USkin.dll"))
	MsgBox, dll file not exist

;create ini values obj
IniValues:={"Socket":"Host", "Socket":"Port", "GUI":"Theme", "Setting":"PrivServer", "Settings":"WebhookCheck", "Settings":"WebhookURL", "Settings":"UserID", "Settings":"Screenshots", "Settings":"BackupLink1", "Settings":"BackupLink2", "Settings":"MainLink", "Settings":"GuiTransparency","Settings":"HiveSlot", "Settings":"FallbackServers", "Settings":"KeyDelay", "Settings":"MoveSpeed"}
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
if (AlwaysOnTop)
	gui +AlwaysOnTop
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
Gui, main:Add, GroupBox, x7 y60 w200 h150 vWebhookFunctionBox, Webhook
Gui, main:Font, cDefault norm s9, Tahoma
Gui, main:Add, Checkbox, x10 y80 vWebhookCheck gWebhookCheck, Enable Webhook
Gui, main:Add, Text, x10 y100, WebhookURL:
Gui, main:Add, Edit,% "x10 y115 w190 h19 r1 vWebhookURL " (WebhookCheck ? "" : "disabled")
Gui, main:Add, Text, x10 y145, User Ping ID:
Gui, main:Add, Edit,% "x10 y160 w190 h19 r1 vUserID " (WebhookCheck ? "" : "disabled")
Gui, main:Add, CheckBox,% "x10 y185 w140 h19 vScreenShots " (WebhookCheck ? "" : "disabled"), ScreenShots
Gui, main:Font, s9 norm w700 
Gui, main:Add, GroupBox, x220 y60 w270 h150 vStatsFunctionBox, Stats
gui, main:Add, Button, x225 y170 vShowLogs, Show Logs
Gui, main:Font, cDefault norm s9, Tahoma
stats := Stats()
Gui, main:Add, Text, x225 y85 vstats, %stats%
;Settings Tab
Gui, main:Tab, Settings
Gui, main:Font, cDefault w700 s13 underline, Tahoma
Gui, main:Add, Text, x9 y31 +backgroundtrans, Settings
Gui, main:Font, s9 norm w700 
Gui, main:Add, GroupBox, x7 y60 w480 h170 vSettingsFunctionBox, Main Settings
Gui, main:Font, cDefault norm s9, Tahoma
Gui, main:Add, Text, x14 y80 +backgroundtrans, MoveSpeed: 
Gui, main:Add, Edit,% " x97 y77 w43 r1 limit5 vMoveSpeedNum ", %MoveSpeed%
Gui, main:Add, CheckBox,% " x180 y77 vAlwaysOnTop gAlwaysOnTop ", Always On Top
Gui, main:Add, Text, x180 y97 +backgroundtrans, Theme Select
Gui, main:Add, DropDownlist, x180 y112 w90 vGuiTheme gThemeSelect disabled, % LTrim(StrReplace("|Allure|Ayofe|BluePaper|Concaved|Core|Cosmo|Fanta|GrayGray|Hana|Invoice|Lakrits|Luminous|MacLion3|Minimal|Museo|Panther|PaperAGV|PINK|Relapse|Simplex3|SNAS|Stomp|VS7|WhiteGray|Woodwork|", "|" GuiTheme "|", "|" GuiTheme "||"), "|")
Gui, main:Add, Text, x280 y97 +backgroundtrans, Transparency:
Gui, main:Add, Edit, x280 y112 w90 +backgroundtrans
Gui, main:Add, UpDown, w60 vGuiTransparency gguiTransparencySet range0-100, %GuiTransparency%
Gui, main:Add, Text, x400 y97 w90 +backgroundtrans, KeyDelay
Gui, main:Add, Edit,% " x400 y112 w50 vKeyDelay ", %KeyDelay%
Gui, main:Add, Text, x14 y115 +backgroundtrans, HiveSlot(6-1): 
Gui, main:Add, DropDownList,% " x98 y112 w40 vHiveSlot ", %HiveSlot%||1|2|3|4|5|6
Gui, main:Add, Text, x14 y145 +backgroundtrans, Main Server    (0 Fails): 
Gui, main:Add, Text, x14 y175 +backgroundtrans, Backup Server(3 Fails): 
Gui, main:Add, Text, x14 y205 +backgroundtrans, Backup Server(6 Fails): 
Gui, main:Add, Edit,% "x180 y143 w190 h15 r1 vMainLink ", 
Gui, main:Add, Edit,% "x180 y173 w190 h15 r1 vBackupLink1 gSettingsCheck " (FallbackServers ? "" : "disabled")
Gui, main:Add, Edit,% "x180 y203 w190 h15 r1 vBackupLink2 " (BackupLink1 ? "" : "disabled")
Gui, main:Add, Checkbox, x300 y77 vFallbackServers gFallBackCheck, FallBack Servers

Gui, main:show, w500 h285, VicHop Macro
return

FallBackCheck(){
	GuiControlGet, FallbackServers
	if (FallbackServers){
		GuiControl, % (FallbackServers ? "enable" : "disable"), BackupLink1
	} else {
		GuiControl, disable, BackupLink1
		GuiControl, disable, BackupLink2
	}
    

}

SettingsCheck(){
    GuiControlGet, BackupLink1
    GuiControl, % (BackupLink1 ? "enable" : "disable"), BackupLink2
}

guiTransparencySet(){
	GuiControlGet, GuiTransparency
	IniWrite, %GuiTransparency%, settings\config.ini, Settings, GuiTransparency
	setVal:=255-floor(GuiTransparency*2.55)
	winset, transparent, %setval%, VicHop Macro
}

ThemeSelect(){
	GuiControlGet, GuiTheme
	IniWrite, %GuiTheme%, settings\config.ini, Settings, GuiTheme
	reload
	Sleep, 10000
}

AlwaysOnTop(){
	GuiControlGet, AlwaysOnTop
	IniWrite, %AlwaysOnTop%, settings\config.ini, Settings, AlwaysOnTop
	if(AlwaysOnTop)
		Gui +AlwaysOnTop
	else
		Gui -AlwaysOnTop
}

Stats(){
	global HourlyStingers, TotalVicKills, SessionVicKills, TotalStingersGained
	if (A_Min = 00){
		HourlyStingers := TotalStingersGained // TotalVicKills
	}
	Text := "Total Vicous Kills: " . TotalVicKills . "`nVicous Kills This Session: " . SessionVicKills . "`nTotal Stingers Gained: " . TotalStingersGained . "`nStingers Gained This Hour: " . HourlyStingers . "`nAverage Stingers Per Hour: " . HourlyStingers
	GuiControl,,stats,%text%
	return text
}


WebhookCheck(){
    GuiControlGet, WebhookCheck
	GuiControlGet, UserID
	GuiControlGet, ScreenShots
    GuiControl, % (WebhookCheck ? "enable" : "disable"), WebhookURL
	GuiControl, % (WebhookCheck ? "enable" : "disable"), UserID
	GuiControl, % (WebhookCheck ? "enable" : "disable"), ScreenShots
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
	global StylesList, GuiTheme
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