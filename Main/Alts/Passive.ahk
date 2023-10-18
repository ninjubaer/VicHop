#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%\..
#Include, %A_ScriptDir%\..\lib\Library.ahk
pToken := Gdip_Startup()
RunWith(32)
importStyles()
SkinForm(Apply, A_ScriptDir . "\..\Styles\USkin.dll" , A_ScriptDir . "\..\Styles\MacLion3.msstyles")
OnExit("GetOut")
Hotkey := "^h"
CoordMode, Mouse, Screen
windowDict := {}
windowCountDict := {}
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
Menu, Tray,Icon, Images/logo.ico
Gui, main:+Border +HwndhGui +OwnDialogs

Gui,main:Add, Button, x5 y253 w65 h20 -Wrap vStartButton gCycleDetection, % " Start (F1)"
Gui,main:Add, Button, x75  y253 w65 h20 -Wrap vPauseButton, % " Pause (F2)"
Gui,main:Add, Button, x145 y253 w65 h20 -Wrap vStopButton, % " Stop (F3)"
Gui,main:Add, Picture,  x220 y248 gGithubLink, images/github.png
Gui,main:Font, w700
Gui,main:Add, Text, x435 y256 +BackgroundTrans, BETAv1
Gui,main:Font, norm
Gui, main:Add, Tab, x0 y0 w502 h240 -Wrap hwndhTab vTab, Main|Status|Hwnd
SendMessage, 0x1331, 0, 124, , ahk_id %hTab% ; set minimum tab width
Gui,main:Tab, Main
Gui,main:Font, cDefault w700 s13 underline, Tahoma
Gui,main:Add, Text, x7 y31 +backgroundtrans, Passive Settings
Gui,main:Add, Text, x178 y31 +backgroundtrans, Capture Window
Gui,main:Font, s9 norm w700 
Gui,main:Add, GroupBox, x5 y60 w160 h150 vHostConnectBox, Setup Client
Gui,main:Add, GroupBox, x175 y60 w315 h150 vClientCaptureBox, Setup Client
Gui,main:Font, cDefault norm s9, Tahoma
Gui,main:Add, Text, x10 y80 +BackgroundTrans vClientText, Host:
Gui,main:Add, Edit, x10 y100 w140 h20 r1 vClientIP, localhost
Gui,main:Add, Text, x10 y130 +BackgroundTrans vClientPortText, Port (min 4 characters):
Gui,main:Add, Edit, x10 y150 w140 h20 r1 vClientPort, 6969
Gui,main:Add, Button, x10 y170 w140 h20 vClientConnect, Connect
;Capmain:ure Settings 
Gui,main:Font, cDefault norm s9, Tahoma
Gui,main:Add, Text, x180 y80 +BackgroundTrans vCaptureCountText, Window Count:
MaxCount := (A_ScreenWidth//400) * (A_ScreenHeight//300)
Gui, main:Add, Edit,x300 y77 Number
Gui, main:Add, UpDown,vCaptureCount Range1-%MaxCount%, 8
Gui, main:Add, Text, x180 y100 +BackgroundTrans vCHT, Capture Hotkey:
Gui, main:Add, Hotkey, x300 y97 vHotkeyNew gHotkey, %Hotkey%
Gui, main:Add, Text, x180 y120 +BackgroundTrans, Auto Align Windows:
Gui, main:Add, DropDownList, x300 y117,% "True||False"
windowCount := 0
Gui, main:Add, Text, x180 y190 +BackgroundTrans vCapturedWindowsText, % "Captured Windows: " windowCount

;status tab

Gui, main:Tab, Status
Gui,main:Font, cDefault w700 s13 underline, Tahoma
Gui,main:Add, Text, x7 y31 +backgroundtrans, Status
Gui,main:Font, cDefault norm s9, Tahoma
Gui,main:Add, GroupBox, x5 y60 w315 h150 vStatusBox



Gui, main:show, w500 h285, Passive VicHop Macro

Hotkey, %Hotkey%, Capture
Return

Hotkey(){
    global Hotkey
    GuiControlGet, HotkeyNew
    if (StrLen(HotkeyNew) >1){
        Hotkey, %Hotkey%, Off
        Hotkey, %HotkeyNew%, Capture, On
        Hotkey := HotkeyNew
        GuiControl, Focus, CHT
    }
}
Capture(){
    global
    WinGet, id,, A
    Gui, input:Destroy
    Gui, input:+Border +HwndGUI +OwnDialogs
    Gui, input:Font, cDefault norm s9, Tahoma
    Gui, input:Add, Text,, Input UserID of Roblox account:
    Gui, input:Add, Edit, vUID w380,
    Gui, input:add, Text,, PS Link?
    Gui, input:Add, Edit, vPSLink w380,
    Gui, input:Add, Button,gCaptureVerify, Submit
    Gui, input:add, Button,x+280, Cancel
    Gui, input:Show, w400 h140, % "userID of window " id%windowCount%
    Return
    
    
}

CaptureVerify(){
    global
    GuiControlGet, UID,input:
    GuiControlGet, PSLink,input:
    if (RegExMatch(UID, "^[0-9]{3,}$")){
        windowCount++
        windowDict[id] := UID
        windowCountDict[UID] := windowCount 
        Gui, input:Destroy
        Sleep, 100
        GuiControl, main:Text, CapturedWindowsText, % "Captured Windows: " windowCount
    }
    Else{
        MsgBox, Invalid UserID!`nTo find your UserID go to Roblox.com -> click on your profile`nAnd copy the number in the URL
        Return
    }
    if (RegExMatch(PSLink, "i)(?<=privateServerLinkCode=)(.{32})", linkCode))
        linkCode := linkCode
    Else
        linkCode := ""
    
}


CycleDetection(){
    global windowDict
    for k,v in windowDict
    {
        disconnectCheck(k, v)
        WinActivate, % "ahk_id " k
        Sleep, 500
        WinGetClientPos(windowX,windowY,windowW,windowH,"ahk_id " k)
        y := Round(windowY+(windowH/2))
        x := Round(windowX+(windowW/2))
        Click,%x% %y%
        if (PixelSearch,,, windowX, windowY, windowX + windowW, windowY + windowH/3, 0x000000)
        {
            ;found
        }
    }
}
disconnectCheck(hwnd, UID){
    global windowCountDict, windowDict
    ;local linkCodes
    WinGetClientPos(windowX,windowY,windowW,windowH,"ahk_id " hwnd)
    loop 1{
        if (!WinExist("ahk_id " hwnd))
            Break
        If (ImageSearch,,, windowX, windowY, windowW, windowH, "ahk_id " hwnd)
            Break
        Else
            Return 1            
    }
    WinActivate, "ahk_id " hwnd
    SetKeyDelay, A_KeyDelay+250
	send {Esc}l{Enter}
	SetKeyDelay, A_KeyDelay-250
    WinClose, "ahk_id " hwnd
    Sleep, 1000
    Try Run, % "roblox://placeID=1537690962" (server ? ("&linkCode=" linkCodes[server]) : "")
}
F1::CycleDetection()