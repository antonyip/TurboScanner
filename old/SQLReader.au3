#RequireAdmin
#include <File.au3>
#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include <WinAPIFiles.au3>
#include "SQLite.au3"
#include "SQLite.dll.au3"

Local $filepath = "C:\Users\AntonWin10\AppData\Local\Google\Chrome\User Data\Default\Local Storage"
Local $filepathLog = "C:\Users\AntonWin10\Desktop"
Local $filename = "https_iqoption.com_0.localstorage"
Local $filenameLog = "log.txt"
Local $keyname = "feed.turbo.76"
Local $hQuery = ""
Local $sMsg = ""
Local $aRow = ""
Local $aNames
Local $hQuery = ""
Global $logfile
Local Const $sFilePath = _WinAPI_GetTempFileName(@TempDir)
Local $dFile = FileOpen($filepath & "\" & $filename,$FO_READ)

OpenLog()
Local $ss = FileRead($dFile)
Local $KilledStr = ""

For $i=1 To StringLen($ss)
    ;If BinaryMid($ss,$i,1)=Binary(BinaryMid(0,1,1)) Then
        ;$ss=BinaryMid($ss,1,$i-1)&BinaryMid($ss,$i+1)
        ;$i-=1
    ;EndIf
	;Local $out = StringFormat("%2s",StringMid($ss,$i,2))
	Local $char = BinaryMid($ss,$i,2)
	Local $out = _HexToString($char)
    WriteLog("h" & $out)
Next

;$data=BinaryToString($ss)
;$split=StringSplit($data,@CRLF,1)
;_ArrayDisplay($split)

;WriteLog($ss)
;Local $sSQliteDll = _SQLite_Startup()

;Local $hDB = _SQLite_Open($dFile)

;_SQLite_Query($hDB, "Select * from ItemTables;", $hQuery)
;_SQLite_FetchNames($hQuery, $aNames)
;WriteLog("names: "&$aNames[0]);

#cs
If @error Then
    MsgBox($MB_SYSTEMMODAL, "SQLite Error", "SQLite3.dll Can't be Loaded!" & @CRLF & @CRLF & _
            "Not FOUND in @SystemDir, @WindowsDir, @ScriptDir, @WorkingDir, @LocalAppDataDir\AutoIt v3\SQLite")
    Exit -1
EndIf

WriteLog("hw2")
WriteLog("_SQLite_LibVersion=" & _SQLite_LibVersion() & @CRLF)

Local $hDB = _SQLite_Open($filepath & "\" & $filename)

If @error Then
   WriteLog("_SQLite_Open Error" & @error)
EndIf

_SQLite_Query($hDB, "Select * from ItemTables;", $hQuery)

_SQLite_FetchNames($hQuery, $aNames)

WriteLog("names: "&$aNames);

If @error Then
   WriteLog("_SQLite_Query Error" & @error)
EndIf

;WriteLog($hQuery)
While _SQLite_FetchData($hQuery, $aRow) == $SQLITE_OK ; Read Out the next Row
    ConsoleWrite("line:" & $aRow[0] & @CRLF)
 WEnd

WriteLog("hw2.5")

If @error Then
   WriteLog("_SQLite_FetchData Error" & @error)
EndIf

WriteLog("hw3")
_SQLite_Close()
_SQLite_Shutdown()
WriteLog("hw4")

If @error Then
   WriteLog("_SQLite_FetchData Error" & @error)
EndIf

#ce
CloseLog()

Func OpenLog()
   $logfile = FileOpen($filepathLog & "\" & $filenameLog,$FO_OVERWRITE+$FO_CREATEPATH)
EndFunc

Func CloseLog()
   FileClose($logfile)
   EndFunc

Func WriteLog($text)
   FileWriteLine($sFilePath,$text)
   FileWriteLine($logfile,$text)
   ConsoleWrite($text)
   EndFunc

