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
#Include lib/Detection.ahk
#Include, Alts/Search.ahk
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
	FileAppend, [Socket]`nHost=localhost`nPort=6969`n[GUI]`nTheme=MacLion3`n[Planter]`n`n[Settings]`nPrivServer=`nWebhookCheck=`nWebhookURL=`nUserID=`nscreenshots=`nBackupLink1=`nBackupLink2=`nMainLink=`nFallbackServers=`nFallBackCheck=`nKeyDelay=20`nGuiTransparency=0`nAlwaysOnTop=1`nHiveSlot=6`nMoveSpeedNum=28, Settings/config.ini
}
if (!FileExist(A_ScriptDir . "\Styles\USkin.dll"))
	MsgBox, dll file not exist

;create ini values obj
IniValues:={"Host":"Socket", "Port":"Socket", "Theme":"GUI", "PrivServer":"Settings", "WebhookCheck":"Settings", "WebhookURL":"Settings", "UserID":"Settings", "Screenshots":"Settings", "BackupLink1":"Settings", "BackupLink2":"Settings", "MainLink":"Settings", "GuiTransparency":"Settings","HiveSlot":"Settings", "FallbackCheck":"Settings", "FallbackServers":"Settings", "KeyDelay":"Settings", "MoveSpeedNum":"Settings"}
;read ini values from iniValues obj
for k,v in IniValues
{
	IniRead, %k%, Settings/config.ini, %v%, %k%
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
Gui +border +hwndhGUI +OwnDialogs
; Footer
Gui, Add, Button, x5 y260 w65 h20 -Wrap vStartButton, % " Start (F1)"
Gui, Add, Button, x75  y260 w65 h20 -Wrap vPauseButton, % " Pause (F2)"
Gui, Add, Button, x145 y260 w65 h20 -Wrap vStopButton, % " Stop (F3)"
Gui, Add, Text, x5 y243 w100 h15 +Border +BackgroundTrans, % " Connections: " (clients.maxindex() ? clients.maxindex() : 0)
Gui, Add, Text, x110 y243 w100 h15 +Border +BackgroundTrans, % " Hourly Stingers: " HourlyStingers
Gui, Font, w700
Gui, Add, Text, x435 y256 , BETAv1
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
Gui, Add, Checkbox, x10 y80 vWebhookCheck gWebhookCheck, Enable Webhook
Gui, Add, Text, x10 y100, WebhookURL:
Gui, Add, Edit,% "x10 y115 w190 h19 r1 vWebhookURL " (WebhookCheck ? "" : "disabled")
Gui, Add, Text, x10 y145, User Ping ID:
Gui, Add, Edit,% "x10 y160 w190 h19 r1 vUserID " (WebhookCheck ? "" : "disabled")
Gui, Add, CheckBox,% "x10 y185 w140 h19 vScreenShots " (WebhookCheck ? "" : "disabled"), ScreenShots
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
Gui, Add, DropDownlist, x180 y112 w90 vGuiTheme gThemeSelect disabled, Allure|Ayofe|BluePaper|Concaved|Core|Cosmo|Fanta|GrayGray|Hana|Invoice|Lakrits|Luminous|MacLion3|Minimal|Museo|Panther|PaperAGV|PINK|Relapse|Simplex3|SNAS|Stomp|VS7|WhiteGray|Woodwork
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
Gui, Add, Edit,% "x180 y143 w190 h15 r1 vMainLink ", 
Gui, Add, Edit,% "x180 y173 w190 h15 r1 vBackupLink1 gSettingsCheck " (FallbackServers ? "" : "disabled")
Gui, Add, Edit,% "x180 y203 w190 h15 r1 vBackupLink2 " (BackupLink1 ? "" : "disabled")
Gui, Add, Checkbox, x350 y77 vFallbackServers gFallBackCheck, FallBack Servers
Gui, show, w500 h285, VicHop Macro
return

f1::
save()
BugRun()
return

save(){
	GuiControlGet, HostIP
	GuiControlGet, HostPort
	GuiControlGet, GatherOnMain
	GuiControlGet, Field1
	GuiControlGet, BugRunOnMain
	GuiControlGet, WebhookCheck
	GuiControlGet, WebhookURL
	GuiControlGet, UserID
	GuiControlGet, ScreenShots
	GuiControlGet, ShowLogs
	GuiControlGet, AlwaysOnTop
	GuiControlGet, GuiTheme
	GuiControlGet, guiTransparencySet
	GuiControlGet, KeyDelay
	GuiControlGet, HiveSlot
	GuiControlGet, MainLink
	GuiControlGet, BackupLink1
	GuiControlGet, BackupLink2
	GuiControlGet, FallbackServers
	IniWrite, %HostIP%, settings/config.ini, Settings, HostIP
	IniWrite, %HostPort%, settings/config.ini, Settings, HostPort
	IniWrite, %GatherOnMain%, settings/config.ini, Settings, GatherOnMain
	IniWrite, %Field1%, settings/config.ini, Settings, Field1
	IniWrite, %BugRunOnMain%, settings/config.ini, Settings, BugRunOnMain
	IniWrite, %WebhookCheck%, settings/config.ini, Settings, WebhookCheck
	IniWrite, %UserID%, settings/config.ini, Settings, UserID
	IniWrite, %WebhookURL%, settings/config.ini, Settings, WebhookURL
	IniWrite, %ScreenShots%, settings/config.ini, Settings, ScreenShots
	IniWrite, %ShowLogs%, settings/config.ini, Settings, ShowLogs
	IniWrite, %AlwaysOnTop%, settings/config.ini, Settings, AlwaysOnTop
	IniWrite, %GuiTheme%, settings/config.ini, Settings, GuiTheme
	IniWrite, %guiTransparencySet%, settings/config.ini, Settings, guiTransparencySet
	IniWrite, %KeyDelay%, settings/config.ini, Settings, KeyDelay
	IniWrite, %HiveSlot%, settings/config.ini, Settings, HiveSlot
	IniWrite, %MainLink%, settings/config.ini, Settings, MainLink
	IniWrite, %BackupLink1%, settings/config.ini, Settings, BackupLink1
	IniWrite, %BackupLink2%, settings/config.ini, Settings, BackupLink2
	IniWrite, %FallbackServers%, settings/config.ini, Settings, FallbackServersD
}

GotoStrawberry(){
	reset()
	gotoramp()
	gotocannon()
	send e
	hypersleep(775)
	send {s down}{d down}
	sendspace()
	sendspace()
	hypersleep(1200)
	send {s up}
	hypersleep(700)
	send {d up}
	sendspace()
	hypersleep(2000)
	send {. 4}
}

GotoSpider(){
	reset()
	gotoramp()
	gotocannon()
	send {e}{. 4}
	hypersleep(900)
	send {Shift}
	sendSpace()
    sendSpace()
    send {Shift}
    Hypersleep(300)
    sendSpace()
    Hypersleep(3000)
}

BugRun(){
	LadyBug:=300, Rhino:=300, Scorpian:=300, Mantis:=300, Spider:=1800, Wolf:=3600 ;cooldown in minutes
	;ladybugs
	IniRead, LadyBugTimer, settings/config.ini, Bugs, LadyBugTimer
	if (toUnix_() - LadyBugTimer > LadyBug){
		GotoStrawberry()
		KillMob()
		walk(8, "s", "d")
		loop 2 {
			walk(9, "w")
			walk(1.5, "a")
			walk(9, "s")
			walk(1.5, "a")
		}
		loop 2 {
			walk(9, "w")
			walk(1.5, "d")
			walk(9, "s")
			walk(1.5, "d")
		}
		walk(15, "a")
		walk(13, "s")
		walk(22, "d")
		walk(20, "s", "d")
		KillMob()
		loop 2 {
			walk(9, "w")
			walk(1.5, "a")
			walk(9, "s")
			walk(1.5, "a")
		}
		loop 2 {
			walk(9, "w")
			walk(1.5, "d")
			walk(9, "s")
			walk(1.5, "d")
		}
		LadyBugTimer := toUnix_()
		IniWrite, %LadyBugTimer%, settings/config.ini, Bugs, LadyBugTimer
	}
	;Spider
	IniRead, SpiderTimer, settings/config.ini, Bugs, SpiderTimer
	if (toUnix_() - SpiderTimer > Spider){
		GotoSpider()
		KillMob()
		walk(2, "s","d")
		loop 3 {
			walk(12, "w")
			walk(1.5, "a")
			walk(12, "s")
			walk(1.5, "a")
		}
		SpiderTimer := toUnix_()
		IniWrite, %SpiderTimer%, settings/config.ini, Bugs, SpiderTimer
	}
	IniRead, RhinoTimer, settings/config.ini, Bugs, RhinoTimer
	if (toUnix_() - RhinoTimer > Rhino){
			send {. 2}
			walk(45, "w")
			KillMob()
			walk(2, "s","d")
			loop 3 {
				walk(12, "w")
				walk(1.5, "a")
				walk(12, "s")
				walk(1.5, "a")
			}
		RhinoTimer := toUnix_()
		IniWrite, %RhinoTimer%, settings/config.ini, Bugs, RhinoTimer
	}
}

GotoRamp(){
	IniRead, HiveSlot, settings/config.ini, Settings, HiveSlot
	walk(6, "w")
	walk(8.35*2+1, "d")
}

GotoCannon(){
	cannonstart:
	send {d down}
	sendspace()
	walk_(12)
	send {d up}
	sleep 500
		If (imagesearch("e_button.png",30,"high")[1] = 0){
			goto, cannonEnd
		} else If (imagesearch("e_button.png",30,"high")[1] = 1){
			reset()
			gotoramp()
			goto, cannonstart
		}
cannonEnd:
}

KillMob(){
    WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
    send 1
    starttime := toUnix_()
    loop 10 {
        ImageSearch, FoundX, FoundY, windowWidth/2, windowHeight/2, windowWidth, windowHeight, *30 images\deadmob.png
		if (errorlevel = 0)
        {
            break
        }
        if (toUnix_() - starttime > 10){ ;10 seconds
           	break
        }
		hypersleep(1000)
		click
    }
	Gdip_DisposeImage(GdipBitmap)
}

WinGetClientPos(ByRef X:="", ByRef Y:="", ByRef Width:="", ByRef Height:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local hWnd, RECT
    hWnd := WinExist(WinTitle, WinText, ExcludeTitle, ExcludeText)
    VarSetCapacity(RECT, 16, 0)
    DllCall("GetClientRect", "UPtr",hWnd, "Ptr",&RECT)
    DllCall("ClientToScreen", "UPtr",hWnd, "Ptr",&RECT)
    X := NumGet(&RECT, 0, "Int"), Y := NumGet(&RECT, 4, "Int")
    Width := NumGet(&RECT, 8, "Int"), Height := NumGet(&RECT, 12, "Int")
}

reset(loops:=1){
confirmedhive := 0
	;bees, click on x - get useless stuff out the way
	WinGetPos , windowX, windowY, windowWidth, windowHeight, Roblox
	xPos := imagesearch("x.png",30,"high")
	        If (xpos[1] = 0){
	            MouseMove, (xPos[2]+5), (xPos[3]+6)
	            Click
	            sleep, 1000
	        }
	;planter
	;click on the no
	        noPos := imagesearch("no.png",30)
	        If (noPos[1] = 0){
	            MouseMove, (noPos[2] + 10), (noPos[3] + 10)
	            Click
	            sleep, 1000
	        }
	;chat
	CPos := imagesearch("chat.png",30)
	        If (CPos[1] = 0){
	            MouseMove, (CPos[2]+5), (CPos[3]+6)
	            Click
 	           	sleep, 1000
	        }
		while (A_Index<=4) {
			;reset
		loop, %loops% {
			setkeydelay, 100
			send {esc}
			send r
			send {enter}
			sleep,8000
		}
		SetKeyDelay, 20
		sendinput {PgUp 4}
		loop 6 {
			send o
			sleep, 20
		}
		sleep,1000
			Loop 4 {
				If ((ImageSearch("hive4.png",20,"hive")[1] = 0) || (ImageSearch("hive_honeystorm.png",20,"hive")[1] = 0) || (ImageSearch("hive_snowstorm.png",20,"hive")[1] = 0)){
					sendinput {. 4}{PgDn 4}
					confirmedHive := 1
					goto, resetender
    					break
			}
	sendinput {. 4}
	sleep, 270
	   }
	if (A_Index >=4){
	    ;reconect here
	    }
	}
resetender:
sleep, 700
{
    WinGetPos , windowX, windowY, windowWidth, windowHeight, Roblox
	searchRet := imagesearch("e_button.png",30,"high")
	If (searchRet[1] = 0) {
		ImageSearch, FoundX, FoundY, 0, 0, windowWidth, windowHeight/2, *100 *Trans0xF7FFF9 images\make.png
		If (ErrorLevel = 0) {
			send e
			loop 1800 {
				searchRet := imagesearch("e_button.png",30,"high")
				If (searchRet[1] != 0)
					break
				}
				sleep, 500
				}
			}
		}
}

ImageSearch(NameOfFile,v,aim := "fullscreen"){
    WinGetPos , windowX, windowY, windowWidth, windowHeight, Roblox
    xi := 0
    yi := 0
    if (windowWidth){
        ww := windowWidth
        wh := windowHeight
        if (aim = "low")
            yi := windowHeight / 2
        if (aim = "high")
            wh := windowHeight / 2
        if (aim = "lowright") {
            yi := windowHeight / 2
            xi := windowWidth / 2
		}
        if (aim = "lowleft") {
            yi := windowHeight/2
		ww := windowWidth/2
		}
		if (aim = "left"){
			ww := windowWidth / 2
		}
		if (aim = "right"){
			xi := windowWidth / 2
		}
        if (aim = "highleft") {
            wh := windowHeight/2
		ww := windowWidth/2
		}
        if (aim = "topright") {
            xi := windowWidth/2
		wh := windowHeight/2
		}
        if (aim = "abovebuff") {
		wh := 30
		ww := windowWidth-100
		}
        if (aim = "hive") {
            xi := windowWidth/4
		yi := (windowHeight/4)*3
		ww := xi*3
		}
        if (aim = "upper") {
            wh := windowHeight/2
		}
		if (aim = "Pollen"){
			wh := windowHeight/8
		}
        if (aim = "inventory") {
            ww := windowWidth/4
		}
        if (aim = "center") {
		xi := windowWidth / 4
		yi := windowHeight / 4
		ww := xi*3
		wh := yi*3
		}
	}
	IfExist, %A_ScriptDir%\images\
{
ImageSearch, FoundX, FoundY, xi, yi, ww, wh, *%v% images\%NameOfFile%
    if (ErrorLevel = 2){
		Sleep, 5000
		Process, Close, % DllCall("GetCurrentProcessId")
    }
    return [ErrorLevel,FoundX,FoundY]
	} else {
		MsgBox Folder location cannot be found:`n%A_ScriptDir%\images\
		return 3, 0, 0
	}
}

toUnix_(){
    Time := A_NowUTC
    EnvSub, Time, 19700101000000, Seconds
    return Time
}

glide(){
	loop 3 {
		send {space down}
		sleep, 100
		send {space up}
	}
}

sendspace(){
	send {space down}
	sleep, 100
	send {space up}
}

moveSpeed(hMS){
	global MoveSpeedNum
	ControlGet, p, CurrentCol, , , ahk_id %hMS%
	GuiControlGet, NewMoveSpeed, , %hMS%
	StrReplace(NewMoveSpeed, ".", , n)

    if (NewMoveSpeed ~= "[^\d\.]" || (n > 1)) ; contains char other than digit or dpt, or more than 1 dpt
	{
        GuiControl, , %hMS%, %MoveSpeedNum%
        SendMessage, 0xB1, % p-2, % p-2, , ahk_id %hMS%
    }
    else
	{
		MoveSpeedNum := NewMoveSpeed
		MoveSpeedFactor:=round(18/MoveSpeedNum, 2)
		IniWrite, %MoveSpeedNum%, settings/config.ini, Settings, MoveSpeedNum
		IniWrite, %MoveSpeedFactor%, settings/config.ini, Settings, MoveSpeedFactor
	}
}

walk(tiles, dir:="w", dir2:="none"){
	send {%dir% down}
	if (dir2 != "none"){
		send {%dir2% down}
	}
	walk_(tiles)
	send {%dir% up}
	if (dir2 != "none"){
		send {%dir2% up}
	}
}

GatherOnMain(){
	GuiControlGet, GatherOnMain
	GuiControl, % (GatherOnMain ? "enable" : "disable"), Field1
}

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
	IniWrite, %BackupLink1%, settings/config.ini, settings, BackupLink1
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
	GuiControlGet, WebhookCheck
    GuiControl, % (WebhookCheck ? "enable" : "disable"), WebhookURL
	GuiControl, % (WebhookCheck ? "enable" : "disable"), UserID
	GuiControl, % (WebhookCheck ? "enable" : "disable"), ScreenShots
	IniWrite, %WebhookCheck%, settings/config.ini, Settings, WebhookCheck
	IniWrite, %UserID%, settings/config.ini, Settings, UserID
	IniWrite, %WebhookURL%, settings/config.ini, Settings, WebhookURL
	IniWrite, %ScreenShots%, settings/config.ini, Settings, ScreenShots
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
	save()
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
save()
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