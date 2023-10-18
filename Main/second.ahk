#NoEnv
#SingleInstance, Force
#Requires AutoHotkey v1.1.36.01+
SetBatchLines, -1
#Include, lib/Library.ahk
SetWorkingDir, %A_ScriptDir%
pToken := Gdip_Startup()

;START VARS
clients := []
HourlyStingers := 0
TotalStingersGained := 0
TotalVicKills := 0
SessionVicKills := 0
;runwith 32bit
RunWith(32)
iniConfig()
;STYLING
importStyles()
SkinForm(Apply, A_ScriptDir . "\Styles\USkin.dll" , A_ScriptDir . "\Styles\" . GuiTheme . ".msstyles")
OnExit("GetOut")
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
if (AlwaysOnTop)
	gui +AlwaysOnTop
/*
if (A_ScreenDPI*100//96 != 100)
	msgbox, 0x1030, WARNING!!, % "Your Display Scale seems to be a value other than 100`%. This means the macro will NOT work correctly!`n`nTo change this, right click on your Desktop -> Click 'Display Settings' -> Under 'Scale & Layout', set Scale to 100`% -> Close and Restart Roblox before starting the macro.", 60
*/
Gui +border +hwndhGUI +OwnDialogs
; Footer
Gui, Add, Button, x5 y260 w65 h20 -Wrap vStartButton, % " Start (F1)"
Gui, Add, Button, x75  y260 w65 h20 -Wrap vPauseButton, % " Pause (F2)"
Gui, Add, Button, x145 y260 w65 h20 -Wrap vStopButton, % " Stop (F3)"
Gui, Add, Text, x5 y243 w100 h15 +Border +BackgroundTrans, % " Connections: " (clients.maxindex() ? clients.maxindex() : 0)
Gui, Add, Text, x110 y243 w100 h15 +Border +BackgroundTrans, % " Hourly Stingers: " HourlyStingers
Gui, Add, Picture,  x220 y248 gGithubLink, images/github.png
Gui, Font, w700
Gui, Add, Text, x435 y256 +BackgroundTrans, BETAv1
;header
Gui, Font, cDefault norm s8, Tahoma
Gui, Add, Tab, x0 y0 w502 h240 -Wrap hwndhTab vTab, Main|Planter|Status|Settings|Contributor
SendMessage, 0x1331, 0, 99, , ahk_id %hTab% ; set minimum tab width
Gui, Tab, Main
Gui, Font, cDefault w700 s13 underline, Tahoma
Gui, Add, Text, x7 y31 +backgroundtrans, Main Settings
Gui, Font, s9 norm w700 
Gui, Add, GroupBox, x5 y60 w160 h150 vHostConnectBox, Setup Host
Gui, Font, cDefault norm s9, Tahoma
Gui, Add, Text, x10 y80 +BackgroundTrans vHostText, Host:
Gui, Add, Edit, x10 y100 w140 h20 r1 vHostIP, localhost
Gui, Add, Text, x10 y130 +BackgroundTrans vHostPortText, Port (min 4 characters):
Gui, Add, Edit, x10 y150 w140 h20 r1 vHostPort, 6969
Gui, Add, Button, x10 y170 w140 h20 vHostBind, Bind
;Groupbox Functions Host
Gui, Font, s9 w700
Gui, Add, GroupBox, x170 y60 w325 h150 vHostFunctionBox, Options
Gui, Font, s9
Gui, Add, Checkbox, x175 y80 vGatherOnMain gGatherOnMain, Gather On Main When No Vicous
Gui, Add, Text, x175 y110 +BackgroundTrans, Gathering Field:
Gui, Add, DropDownList,% " x275 y107 w60 vField1 " (GatherOnMain = 1 ? "" : "disabled"), %Field1%||None|Bamboo|Blue Flower|Cactus|Clover|Coconut|Dandelion|Mountain Top|Mushroom|Pepper|Pine Tree|Pineapple|Pumpkin|Rose|Spider|Strawberry|Stump|Sunflower
Gui, Add, Checkbox, x175 y140 vBugRunOnMain, Bug Run On Main When No Vicous
Gui, Add, Checkbox, x175 y170 vHostFunctionsVicious disabled, Placeholder for future(Mondo...)
Gui, Add, Text, x10 y210 +BackgroundTrans cred, Note: This Feature Is For More Advanced Users. `nIf You Struggle To Extract a Folder, This Might Not Be The Best For You.
Gui, Font, s10
;status tab
Gui, Tab, Status
Gui, Font, cDefault w700 s13 underline, Tahoma
Gui, Add, Text, x9 y31 +backgroundtrans, Status
Gui, Font, s9 norm w700 
Gui, Add, GroupBox, x7 y60 w200 h150 vWebhookFunctionBox, Webhook
Gui, Font, cDefault norm s9, Tahoma
Gui, Add, Checkbox, % "x10 y80 vWebhookCheck gWebhookCheck " (WebhookCheck ? "checked" : ""), Enable Webhook
Gui, Add, Text, x10 y100, WebhookURL:
Gui, Add, Edit,% "x10 y115 w190 h19 r1 vWebhookURL " (WebhookCheck ? "" : "disabled"), %WebhookURL%
Gui, Add, Text, x10 y145, User Ping ID:
Gui, Add, Edit,% "x10 y160 w190 h19 r1 vUserID " (WebhookCheck ? "" : "disabled"), %UserID%
Gui, Add, CheckBox,% "x10 y185 w140 h19 vScreenShots " (WebhookCheck ? "" : "disabled ")(ScreenShots ? "checked ":""), ScreenShots
Gui, Font, s9 norm w700 
Gui, Add, GroupBox, x220 y60 w270 h150 vStatsFunctionBox, Stats
gui, Add, Button, x225 y170 vShowLogs, Show Logs
Gui, Font, cDefault norm s9, Tahoma
stats := Stats()
Gui, Add, Text, x225 y85 vstats, %stats%
;Settings Tab
Gui, Tab, Settings
Gui, Font, cDefault w700 s13 underline, Tahoma
Gui, Add, Text, x9 y31 +backgroundtrans, Settings
Gui, Font, s9 norm w700 
Gui, Add, GroupBox, x7 y60 w480 h170 vSettingsFunctionBox, Main Settings
Gui, Font, cDefault norm s9, Tahoma
Gui, Add, Text, x14 y80 +backgroundtrans, MoveSpeed: 
Gui, Add, Edit,% " x97 y77 w43 r1 limit5 vMoveSpeedNum gmoveSpeed ", %MoveSpeedNum%
Gui, Add, CheckBox,% " x180 y77 vAlwaysOnTop gAlwaysOnTop ", Always On Top
Gui, Add, Text, x180 y97 +backgroundtrans, Theme Select
Gui, Add, DropDownlist, x180 y112 w90 vGuiTheme gThemeSelect, %StylesList%
Gui, Add, Text, x280 y97 +backgroundtrans, Transparency:
Gui, Add, Edit, x280 y112 w90 +backgroundtrans
Gui, Add, UpDown, w60 vGuiTransparency gguiTransparencySet range0-100, %GuiTransparency%
Gui, Add, Text, x400 y97 w90 +backgroundtrans, KeyDelay
Gui, Add, Edit,% " x400 y112 w50 vKeyDelay ", %KeyDelay%
Gui, Add, Text, x14 y115 +backgroundtrans, HiveSlot(6-1): 
Gui, Add, DropDownList,% " x98 y112 w40 vHiveSlot ", %HiveSlot% ||1|2|3|4|5|6
Gui, Add, Text, x14 y145 +backgroundtrans, Main Server (0 Fails): 
Gui, Add, Text, x14 y175 +backgroundtrans, Backup Server (3 Fails): 
Gui, Add, Text, x14 y205 +backgroundtrans, Backup Server (6 Fails): 
Gui, Add, Edit,% "x180 y143 w190 h15 r1 vMainLink"
Gui, Add, Edit,% "x180 y173 w190 h15 r1 vBackupLink1 gSettingsCheck " (FallbackServers ? "" : "disabled")
Gui, Add, Edit,% "x180 y203 w190 h15 r1 vBackupLink2 " (BackupLink1 ? "" : "disabled")
Gui, Add, Checkbox, % "x350 y77 vFallbackServers gFallBackCheck " (FallbackServers ? "checked":"") , Fallback Servers
Gui, show, w500 h285, VicHop Macro
return

Hotkey, F1, startup
startup(){
   GuiControlGet, GatherOnMain
	GuiControlGet, Field1
	GuiControlGet, BugRunOnMain
	GuiControlGet, WebhookCheck
	GuiControlGet, WebhookURL
	GuiControlGet, UserID
	GuiControlGet, ScreenShots
	GuiControlGet, KeyDelay
	GuiControlGet, HiveSlot
	GuiControlGet, MainLink
	GuiControlGet, BackupLink1
	GuiControlGet, BackupLink2
	GuiControlGet, FallbackServers

    SetKeyDelay, KeyDelay
    
}
F2::
GuiControlGet, WebhookURL
setStatus("Testing", "Ayaan's mom at midnight")
Return
F3::
GuiControlGet, WebhookURL
IniWrite, %WebhookURL%, settings/config.ini, Settings, WebhookURL
MsgBox, % WebhookURL
Return
GuiClose:
GetOut()
Return
