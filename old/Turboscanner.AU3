#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.10.2
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
#include <File.au3>
#include <WinApi.au3>
#include "NomadMemory2.au3"

Global $address = 0x00F57834;
Global $filename = "Run.Log"
Global $pid = 1096

Global $Left = 360
Global $Top = 289
Global $Right = 488
Global $Bottom = 314

Global $TimeLeft = 313
Global $TimeTop = 417
Global $TimeRight = 644
Global $TimeBottom = 438

Global $LTimeLeft = 75
Global $LTimeTop = 649
Global $LTimeRight = 137
Global $LTimeBottom = 665

Global $BidPosX = 134
Global $BidPosY = 790

Global $WinPosX = 533
Global $WinPosY = 735

Global $ClearPosX = 599
Global $ClearPosY = 750

Global $Values[60*60*24*7]
Global $MinValues[60*60*24*7]
Global $MinCounter = 0

Global $LIFETIME = 60 * 60 * 24

Global $FIFTYFOUR = 14
Global $TWOFIFTYSIX = 52
Global $TWENTY = 20
Global $SMA54 = 0
Global $SMA256 = 0
Global $SMA20 = 0

Global  $BB20Upper
Global  $BB20Lower
Global  $diffSquared
Global  $diff

Global $Counter = 0
Global $Counter2 = 0
Global $Average = 0
Global $sum = 0
Global $numbers = 0
Global $TimeLeft
Global $DownTrend = 3; 1 is downtrend, 2 is upthread, 3 is dont care
Global $Overlimit = 2.5e-005
Global $BBOverlimit = 2.0e-004

Global $timeToExpire = 0
Global $Bought = False
Global $BoughtPrice = 0.00015
Global $BoughtTime
Global $ExpectedSellTime

Global $data
Global $dataTime
Global $dataLocalTime
Global $prevLocalTime = 0
Global $profit
Global $buymode
Global $Minute30Trend
Global $BoughtDelay = 0

Global $profitcounter = 0
Global $lostcounter = 0

Global $BidAmount = 1

Global $ToResetBid = 0
Global $ToDoubleBid = 0

Global $Logger
Global $Logger2

Global $InChain = false
Global $ExitTime = "5"

Global Const $BidAmountArray[10] = [1.14,2.43,5.19,11.08,23.67,50.57,108.04,230.80]

SetPrivilege("SeDebugPrivilege", 1)

If $Logger = "" Then
   $Logger = @ScriptDir & "\Logger.txt"
EndIf

If $Logger2 = "" Then
   $Logger2 = @ScriptDir & "\Logger2.txt"
EndIf

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


Func _NewMemRead($Addr1, $Proc1, $type1)
If $type1 = "int" Then ;I only used int, if you use uint or any other integer representation, add them in here
Return (Dec(Hex(StringRegExpReplace(_MemoryRead($Addr1, $Proc1, $type1), "00000000", "", 1))))
Else
Return _MemoryRead($Addr1, $Proc1, $type1)
EndIf
EndFunc


Func ExtractValue($memoryStrip)
   Local $length = StringSplit($memoryStrip,":")[0]
   If ($length > 5) Then
   Return StringSplit(StringSplit($memoryStrip,":")[4],",")[1]
   EndIf
   Return ""
EndFunc

While($Counter < $LIFETIME)

   Local $Process = _MemoryOpen($pid);
   Local $BaseAddress = _MemoryGetBaseAddress($Process, 0)
   If @error Then
	  FileWriteLine($filehandle,"Base Address Error" & " " & @error & @CRLF);
   EndIf

   FileWriteLine($filehandle,"Base addresss: " & $BaseAddress);
   SetError(0);
   Local $memoryExtract = ""
   If Not @error Then
	  FileWriteLine($filehandle,"Writing Memory" & @CRLF);
	  For $i = 0 to 100 Step 1
	  $Vaalue = _NewMemRead($address+$i,$Process,'byte');
		 If Not @error Then
			;FileWrite($filehandle,Chr(($Vaalue)));
			$memoryExtract = $memoryExtract & Chr($Vaalue)
		 ;Else
			;FileWriteLine($filehandle,"Error Reading Memory" & " " & @error & @CRLF);
		 EndIf
	  Next
	  ;FileWriteLine($filehandle,@CRLF);
   Else
   ;FileWriteLine($filehandle,"Error Opening Memory" & " " & @error & @CRLF);
   EndIf

   $data = ExtractValue($memoryExtract)

   ;$data = _OCR($Left, $Top, $Right, $Bottom,0x000000,60,"OCRFontData100.txt","")
   ;$data = StringStripWS($data,0x8)

   $prevLocalTime = $dataLocalTime
   ;$dataLocalTime = _OCR($LTimeLeft, $LTimeTop, $LTimeRight, $LTimeBottom,0x000000,100,"OCRFontDataLTime2.txt","")
   ;$dataLocalTime = StringStripWS($dataLocaltime,0x8)

;   If ($prevLocalTime == $dataLocalTime) Then
;	  Sleep(200)
;	  ContinueLoop
;   EndIf

   ;If $InChain == False And StringSplit($dataLocalTime,":")[1] == $ExitTime Then
	;  Exit
   ;EndIf

   ;If($data == 0)Then
	  ;ConsoleWrite("Error In Data" & @LF)
	  ;Sleep(200)
	  ;ContinueLoop
   ;EndIf

;   If (StringSplit($dataLocalTime,":")[3] == "00" or StringSplit($dataLocalTime,":")[3] == "30") Then
;	  $MinValues[$MinCounter] = $data
;	  $MinCounter += 1
;	  If $MinCounter > 1 Then
;		 $Minute30Trend = $MinValues[$MinCounter-1] - $MinValues[$MinCounter-2]
;	  EndIf
;	  FileWriteLine($Logger,$dataLocalTime & @TAB & $data & @TAB & $SMA54 & @TAB & $SMA256 & @TAB & $Minute30Trend & @CRLF)
;   EndIf




   ;If ($dataTime == "") Then
	  ;$TimeLeft -= 1
   ;Else
	  ;$TimeLeft = StringSplit($dataTime,":")[1];
   ;EndIf


   $Values[$Counter] = $data
   ConsoleWrite($prevLocalTime & " " & $dataLocalTime & " - " & $data & " 14MA: " & Round($SMA54,6) & " BBUp: " & Round($BB20Upper,6)  & " BBDown: " & Round($BB20Lower,6)& " p/l: " &  $profitcounter  & ":"  & $lostcounter)


   If ($Counter > $TWENTY) Then
	  $numbers = $Counter
	  $sum = 0
	  $Counter2 = 0
	  While($Counter2 < $TWENTY)
		 $sum += $Values[$numbers - $Counter2];
		 $Counter2 += 1
	  WEnd
	  $Average = $sum / $TWENTY;
	  $SMA20 = $Average
	  ;ConsoleWrite("256 MA: " & $Average & @LF)
   EndIf

   If ($Counter > $TWENTY) Then
	  $numbers = $Counter
	  $sum = 0
	  $Counter2 = 0
	  While($Counter2 < $TWENTY)
		 $diff = $Values[$numbers - $Counter2] - $SMA20
		 $diffSquared = $diff * $diff
		 $sum += $diffSquared
		 $Counter2 += 1
	  WEnd
	  $Average = $sum / $TWENTY;
	  $Average = Sqrt($Average)
	  $BB20Upper = $SMA20 + $Average + $Average
	  $BB20Lower = $SMA20 - $Average - $Average
	  ;ConsoleWrite("256 MA: " & $Average & @LF)

	  If ($data > $BB20Upper And $BB20Upper - $BB20Lower > $BBOverlimit) Then
		; ConsoleWrite(" -- Data Broke BBUpper")
		;MyPut()
	  EndIf

	  If ($data < $BB20Lower And $BB20Upper - $BB20Lower > $BBOverlimit) Then
		 ;ConsoleWrite(" -- Data Broke BBLower")
		 ;MyCall()
	  EndIf


   EndIf

   If ($Counter > $FIFTYFOUR) Then
	  $numbers = $Counter
	  $sum = 0
	  $Counter2 = 0
	  While($Counter2 < $FIFTYFOUR)
		 $sum += $Values[$numbers - $Counter2];
		 $Counter2 += 1
	  WEnd
	  $Average = $sum / $FIFTYFOUR;
	  $SMA54 = $Average
	  ;ConsoleWrite("54 MA: " & $Average & @LF)
   EndIf

   If ($Counter > $TWOFIFTYSIX) Then
	  $numbers = $Counter
	  $sum = 0
	  $Counter2 = 0
	  While($Counter2 < $TWOFIFTYSIX)
		 $sum += $Values[$numbers - $Counter2];
		 $Counter2 += 1
	  WEnd
	  $Average = $sum / $TWOFIFTYSIX;
	  $SMA256 = $Average
	  ;ConsoleWrite("256 MA: " & $Average & @LF)
   EndIf

   ;buying and selling
   If ($Counter >54 And $BoughtDelay > 10) Then
   ;ConsoleWrite("Difference: " & $data - ($SMA54 + $Overlimit) & @LF)
	  If ($DownTrend == 1 Or $DownTrend == 3) Then
		 If ($data > $SMA54 + $Overlimit) Then
			;MyCall()
		 EndIf
	  EndIf

	  If ($DownTrend == 2 Or $DownTrend == 3) Then
		 If ($data < $SMA54 - $Overlimit) Then
			;MyPut()
		 EndIf
	  EndIf
   EndIf

   If ($Bought == True) Then
	  CheckErrorExpireTime()
	  ConsoleWrite(" " &$buymode &" "&$BoughtPrice & " @ " & $ExpectedSellTime)
	  If ($dataLocalTime == $ExpectedSellTime) Then
		 $profit = $data - $BoughtPrice
		 $Bought = False
		 $BoughtDelay = 0
		 ConsoleWrite(@LF)
		 If ($buymode == "call") Then
			If ($BoughtPrice < $data) Then
			   $profitcounter += 1
			   ConsoleWrite("profit " & $buymode &@LF)
			   ConsoleWrite($buymode & " : " & $BoughtPrice & " expire : " & $data & @LF)
			   FileWriteLine($Logger2, "profit " & " : " & $BoughtPrice & " expire : " & $data & @LF)
			   ResetBid()
			Else
			   $lostcounter += 1
			   ConsoleWrite("lost " & $buymode &@LF)
			   ConsoleWrite($buymode & " : " & $BoughtPrice & " expire : " & $data & @LF)
			   FileWriteLine($Logger2, "lost " & " : " & $BoughtPrice & " expire : " & $data & @LF)
			   DoubleBid()
			   If $Minute30Trend > 0 Then
			   MyCall()
			   Else
			   MyPut()
			   EndIf
    	    EndIf
		 Else
			If ($BoughtPrice > $data) Then
			   $profitcounter += 1
			   ConsoleWrite("profit " & $buymode &@LF)
			   ConsoleWrite($buymode & " : " & $BoughtPrice & " expire : " & $data & @LF)
			   FileWriteLine($Logger2, "profit " & " : " & $BoughtPrice & " expire : " & $data & @LF)
			   ResetBid()
			Else
			   $lostcounter += 1
			   ConsoleWrite("lost " & $buymode &@LF)
			   ConsoleWrite($buymode & " : " & $BoughtPrice & " expire : " & $data & @LF)
			   FileWriteLine($Logger2, "lost " & " : " & $BoughtPrice & " expire : " & $data & @LF)
			   DoubleBid()
			   If $Minute30Trend > 0 Then
			   MyCall()
			   Else
			   MyPut()
			   EndIf
    	    EndIf
		 EndIf
	  EndIf
   EndIf

   $BoughtDelay += 1
   $Counter += 1

   If Mod($Counter,30) == 0 Then
	  ;ConsoleWrite("alive " & $Counter &@LF)
   EndIf

   ConsoleWrite(@LF)
   Sleep(200)
WEnd

ConsoleWrite("profitcount: " & $profitcounter & " lostcount: " & $lostcounter );

Func MyPut()
   If $Bought == False Then
	  $Bought = True;
	  $BoughtPrice = $data
	  $BoughtTime = $dataLocalTime
	  $ExpectedSellTime = GetExpireTime($BoughtTime)
	  $timeToExpire = $TimeLeft + 30
	  $buymode = "put";
	  ConsoleWrite(@LF)
	  ConsoleWrite("put at: " & $BoughtPrice & " @ " & $BidAmountArray[$BidAmount-1] & @LF)
	  FileWriteLine($Logger2, "put at: " & $BoughtPrice & " @ " & $BidAmountArray[$BidAmount-1] & @LF)
	  Sleep(200)
	  MouseClick("Left",$ClearPosX,$ClearPosY,1)
   EndIf
EndFunc

Func MyCall()
   If $Bought == False Then
	  $Bought = True;
	  $BoughtPrice = $data
	  $BoughtTime = $dataLocalTime
	  $ExpectedSellTime = GetExpireTime($BoughtTime)
	  $timeToExpire = $TimeLeft + 30
	  $buymode = "call";
	  ConsoleWrite(@LF)
	  ConsoleWrite("call at: " & $BoughtPrice & " @ " & $BidAmountArray[$BidAmount-1]& @LF)
	  FileWriteLine($Logger2, "call at: " & $BoughtPrice & " @ " & $BidAmountArray[$BidAmount-1]& @LF)
	  Sleep(200)
	  MouseClick("Left",$ClearPosX,$ClearPosY,1)
   EndIf
EndFunc

Func GetExpireTime($timeNow)
   local $ExpireTime = $timeNow
   Local $H = StringSplit($timeNow,":")[1]
   Local $M = StringSplit($timeNow,":")[2]
   Local $S = StringSplit($timeNow,":")[3]

   ;ConsoleWrite($H & " " & $M & " " & $S & @LF)

   If ($S > 30) Then

	  if ($M == 58) Then
		 Return StringFormat("%02d",$H+1) & ":" & "00" & ":" & "00"
	  EndIf

	  if ($M == 59) Then
		 Return StringFormat("%02d",$H+1) & ":" & "01" & ":" & "00"
	  EndIf

	  Return StringFormat("%02d",$H) & ":" & StringFormat("%02d",$M+2) & ":" & "00"
   Else
	  if ($M == 59) Then
		 Return StringFormat("%02d",$H+1) & ":" & "00" & ":" & "00"
	  EndIf

	  Return StringFormat("%02d",$H) & ":" & StringFormat("%02d",$M+1) & ":" & "00"
   EndIf
EndFunc

Func CheckErrorExpireTime()

   Local $H = StringSplit($ExpectedSellTime,":")[1] * 60
   Local $M = StringSplit($ExpectedSellTime,":")[2] + $H

   Local $H2 = StringSplit($dataLocalTime,":")[1] * 60
   Local $M2 = StringSplit($dataLocalTime,":")[2] + $H2

   ;ConsoleWrite($H & " " & $M & " " & $S & @LF)

   If ($M2 - $M > 2 Or $M2 - $M < -2) Then
	 $Bought = False;
	 ConsoleWrite("Error Saved")
   EndIf
EndFunc

Func ResetBid()
   $ToResetBid = True
   ActualResetBid()
EndFunc

Func ActualResetBid()
   $InChain = False
   MouseClick("left",$BidPosX,$BidPosY,1)
   Send("{BACKSPACE}")
   Send("{BACKSPACE}")
   Send("{BACKSPACE}")
   Send("{BACKSPACE}")
   Send("{BACKSPACE}")
   Send("{BACKSPACE}")
   Send("{BACKSPACE}")
   Send("{BACKSPACE}")
   Send($BidAmountArray[0])
   $BidAmount = 1
   $ToResetBid = False
   Sleep(100)
EndFunc

Func DoubleBid()
   $ToDoubleBid = True
   ActualDoubleBid()
EndFunc

Func ActualDoubleBid()
   $InChain = True
   MouseClick("left",$BidPosX,$BidPosY,1)
   Send("{BACKSPACE}")
   Send("{BACKSPACE}")
   Send("{BACKSPACE}")
   Send("{BACKSPACE}")
   Send("{BACKSPACE}")
   Send("{BACKSPACE}")
   Send("{BACKSPACE}")
   Send("{BACKSPACE}")
   Send($BidAmountArray[$BidAmount])
   $BidAmount += 1
   $ToDoubleBid = False
   Sleep(100)
EndFunc

