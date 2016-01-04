#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
#include <File.au3>
#include <WinApi.au3>
#include "NomadMemory2.au3"
#RequireAdmin
SetPrivilege("SeDebugPrivilege", 1)

;Global $address = 0x39F021E64A8;
Global $address = 0x00FC9E34;
Global $filename = "Run.Log"
Global $pid = 9176
;Local Const $sFilePath = _WinAPI_GetTempFileName(@TempDir)
;Global $address = 0x21E64A8;

;While 1

If FileExists($filename) then
   $filehandle = FileOpen($filename, $FO_OVERWRITE)
Else
   ;FileCreate($filename)
   $filehandle = _FileCreate($filename)
EndIf

    If $filehandle = -1 Then
        MsgBox($MB_SYSTEMMODAL, "", "An error occurred when reading the file.")
        Return False
	 EndIf

FileWriteLine($filehandle,"helloworld");


   Local $Process = _MemoryOpen($pid);
   Local $BaseAddress = _MemoryGetBaseAddress($Process, 0)
   If Not @error Then
			FileWriteLine($filehandle,"Base Address: " & $BaseAddress);
		 Else
			FileWriteLine($filehandle,"Base Address Error" & " " & @error & @CRLF);
		 EndIf

   FileWriteLine($filehandle,"Base addresss: " & $BaseAddress);
   SetError(0);
   If Not @error Then
	  FileWriteLine($filehandle,"Writing Memory" & @CRLF);
	  For $i = 0 to 255 Step 1
	  $Vaalue = _NewMemRead($address+$i,$Process,'byte');
		 If Not @error Then
			FileWrite($filehandle,Chr(($Vaalue)));
		 Else
			FileWriteLine($filehandle,"Error Reading Memory" & " " & @error & @CRLF);
		 EndIf
	  Next
	  FileWriteLine($filehandle,@CRLF);
   Else
   FileWriteLine($filehandle,"Error Opening Memory" & " " & @error & @CRLF);
   EndIf
   Sleep(100)
   ;WEnd

Func _NewMemRead($Addr1, $Proc1, $type1)
If $type1 = "int" Then ;I only used int, if you use uint or any other integer representation, add them in here
Return (Dec(Hex(StringRegExpReplace(_MemoryRead($Addr1, $Proc1, $type1), "00000000", "", 1))))
Else
Return _MemoryRead($Addr1, $Proc1, $type1)
EndIf
EndFunc ;==>_NewMemRead