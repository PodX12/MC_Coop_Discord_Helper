#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.
#SingleInstance, Force

;###################### SETTTINGS #################################

global name := "PodX12" ; Name that messages will show at the top
global discordWebhook := "{YOUR_WEBHOOK_HERE}" ; Discord webhook

;###################### END SETTINGS ################################

#Persistent
    OnClipboardChange("ClipChanged")
return

ClipChanged(){
    if WinActive("Minecraft"){
        clipboardText := Clipboard

        message := name " @ " A_Hour ":" A_Min
        if InStr(clipboardText, "/execute in"){
            coords := ParseCoords(clipboardText)
            message := message "`r`r" coords.Dimension "`rBlock: " coords.X " " coords.Y " " coords.Z "`rChunk: " coords.XChunk " " coords.ZChunk "`rAngle: " coords.Angle
        }else if InStr(clipboardText, "/setblock") {
            target := ParseBlockInformation(clipboardText)
            message := message "`r`r" target.BlockType " " target.X " " target.Y " " target.Z
        }

        message := message "`r`r" clipboardText "`r----"
        ; MsgBoX % message
        message :=  StrReplace(StrReplace(StrReplace(message, "\", "\\"), """", "\"""), "`r", "\n")
        Http := ComObjCreate("WinHTTP.WinHTTPRequest.5.1")
        Http.Open("POST", discordWebhook)
        Http.SetRequestHeader("Content-Type", "application/json")
        Http.Send("{""content"": """ message """}")
    }
}

ParseCoords(cmd){
    cmdSplit := StrSplit(cmd, A_Space)
    xCoord := cmdSplit[7]
    yCoord := cmdSplit[8]
    zCoord := cmdSplit[9]
    oAngle := cmdSplit[10]
    dimension := InStr(cmd, "minecraft:overworld") ? "Overworld" : "Nether"

        if(oAngle > 180){
            while oAngle > 180
                oAngle := oAngle - 360
        }else if (oAngle < -180){
            while oAngle < -180
                oAngle := oAngle + 360
        }
        oAngle := Round(oAngle, 2)

    return { X: Floor(xCoord), Z: Floor(zCoord), Y: Floor(yCoord), Angle: oAngle, XChunk: Floor(xCoord/16), ZChunk: Floor(zCoord/16), Dimension: dimension }
}

ParseBlockInformation(cmd){
    cmdSplit := StrSplit(cmd, A_Space)
    xCoord := cmdSplit[2]
    yCoord := cmdSplit[3]
    zCoord := cmdSplit[4]
    blockType := cmdSplit[5]

    return { X: xCoord, Y: yCoord, Z: zCoord, BlockType: blockType }
}
