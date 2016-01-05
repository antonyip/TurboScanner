#include <File.au3>
#include <Date.au3>
#include <WinApi.au3>
#include "NomadMemory2.au3"

Global $address = 0x00C64F74;
Global $MemoryErrorFile
Global $SearchString = '\"EURUSD\",\"value\"'
Global $pid = 0x1564

;Bit amount nuber
Global $BidPosX = 938
Global $BidPosY = 254

;Call Button
Global $CallPosX = 917
Global $CallPosY = 396

;Put Button
Global $PutPosX = 917
Global $PutPosY = 470

;To Actually Click Call and Put Buttons
Global $RealMoneyMode = false
Global $TakeInput = false

Global $Values[60*60*24*7]
Global $MinValues[60*60*24*7]
Global $MinCounter = 0
Global $BetReady = False;

Global $FIFTYFOUR = 14
Global $TWOFIFTYSIX = 52
Global $TWENTY = 20
Global $SMA54 = 0
Global $SMA256 = 0
Global $SMA20 = 0

Global $BB20Upper
Global $BB20Lower
Global $BB20Upper30Sec
Global $BB20Lower30Sec
Global $diffSquared
Global $diff

Global $Counter = 0
Global $Counter2 = 0
Global $Average = 0
Global $Average30Sec = 0
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
Global $dataError = false;
Global $dataTime
Global $dataLocalTime
Global $prevLocalTime = 0
Global $profit
Global $buymode
Global $Minute30Trend
Global $BoughtDelay = 0 ; to delay a put / sell after winning

Global $profitcounter = 0
Global $lostcounter = 0

Global $BidAmount = 1

Global $ToResetBid = 0
Global $ToDoubleBid = 0

;~ Global $Logger
Global $Logger2
Global $RawDataLog

Global $InChain = False
Global $ExitTime = "5"
Global $memoryExtract;

Global Const $BidAmountArray[20] = [1.14,2.43,5.19,11.08,23.67,50.57,108.04,230.80,400,1,1,1,1,1,1,1,1,1]

;~ If $Logger = "" Then
;~    $Logger = @ScriptDir & "\Logger.txt"
;~ EndIf

;Log file for data parsing
Local $day
Local $time
_DateTimeSplit(_Now(),$day,$time)
Local $RawDataLogFilename = @ScriptDir & "\rawdata\" &  "RawData" & "-" & StringFormat("%.2i",$day[1]) & StringFormat("%.2i",$day[2]) & StringFormat("%.4i",$day[3]) & "-" & StringFormat("%.2i",$time[1]) & StringFormat("%.2i",$time[2]) & StringFormat("%.2i",$time[3]) &".txt"
OpenStreamUsingFilename($RawDataLogFilename,$RawDataLog)

; Memory Parsing Log
OpenStreamUsingFilename("MemoryError.Log",$MemoryErrorFile)

; Buy Sell Log
OpenStreamUsingFilename("BuySell.Log",$Logger2)

; Start of Loop of Actual Program
While(True)
   ReadMemoryIntoMemoryExtract()
   $data = ExtractValue($memoryExtract)
   $prevLocalTime = $dataLocalTime
   $dataLocalTime = _NowTime(5)
   ;$dataLocalTime = StringStripWS($dataLocaltime,0x8)

   ; Error Checking for Timing and MisReading of Information Start
   If ($prevLocalTime == $dataLocalTime And $dataError == False) Then
	  Sleep(50)
	  ContinueLoop
   EndIf

   $dataError = False;

   ; If LifeTime Timer is up
   If $InChain == False And StringSplit($dataLocalTime,":")[1] == $ExitTime Then
	  Exit
   EndIf

   If StringLen($SMA20) > 1 Then
	  If Number($data) < $SMA20 - 0.5 Or Number($data > $SMA20 + 0.5) Then
		 FileWriteLine($MemoryErrorFile,$memoryExtract)
		 $dataError = True;
		 ContinueLoop
	  EndIf
   EndIf

   If Number($data) < 0.1 Then
	  $dataError = True;
	  ContinueLoop
   EndIf

   ; Error Checking for Timing and MisReading of Information End
   If (StringSplit($dataLocalTime,":")[3] == "00" or StringSplit($dataLocalTime,":")[3] == "30") Then
	  $MinValues[$MinCounter] = $data
	  $MinCounter += 1
	  If $MinCounter > 1 Then
		 $Minute30Trend = $MinValues[$MinCounter-1] - $MinValues[$MinCounter-2]
	  EndIf
   EndIf

;~ Not sure, some calculation for timing
   $TimeLeft -= 1

   $Values[$Counter] = $data
   AutoItLog()

;~    SMA20 Calculation
   CalculateSMA20()
;~    SMA54 Calculation
   CalculateSMA54()
;~    SMA256 Calculation
   CalculateSMA256()
;~    BolingerBand Calculation
   CalculateBB()

;~ Old buysell
   If ($Counter > $TWOFIFTYSIX) Then
	  If ($data > $BB20Upper And $BB20Upper - $BB20Lower > $BBOverlimit) Then
		MyCall()
	  EndIf

	  If ($data < $BB20Lower And $BB20Upper - $BB20Lower > $BBOverlimit) Then
		 MyPut()
	  EndIf
   EndIf

;~    If $MinCounter > 3 Then
;~ 	  $BetReady = true
;~ 	  $numbers = $MinCounter
;~ 	  If $numbers > 14 Then
;~ 		 $numbers = 14
;~ 	  Else
;~ 		 $numbers = $MinCounter
;~ 	  EndIf
;~ 	  $Average30Sec = 0
;~ 	  $sum = 0
;~ 	  $Counter2 = 0
;~ 	  While($Counter2 < $numbers)
;~ 		 $sum += $MinValues[$MinCounter - $Counter2];
;~ 		 $Counter2 += 1
;~ 	  WEnd

;~ 	  $Average30Sec = $sum / ($Counter2-1);
;~ 	  ConsoleWrite("Sense1: " & $Average30Sec & " " & $numbers & @CRLF)
;~ 	  $Counter2 = 0
;~ 	  $sum = 0
;~ 	  While($Counter2 < $numbers)
;~ 		 $diff = $Values[$MinCounter - $Counter2] - $Average30Sec
;~ 		 $diffSquared = $diff * $diff
;~ 		 $sum += $diffSquared
;~ 		 $Counter2 += 1
;~ 	  WEnd
;~ 	  $diff = $sum / ($Counter2-1)
;~ 	  $diff = Sqrt($diff)
;~ 	  ;ConsoleWrite("Sense2: " & $diff & " " & $sum & @CRLF)

;~ 	  $BB20Upper30Sec = $Average30Sec + $diff
;~ 	  $BB20Lower30Sec = $Average30Sec - $diff

;~ 	  If ($data > $BB20Upper30Sec And $BB20Upper30Sec - $BB20Lower30Sec > $BBOverlimit) Then
;~ 	  If $data > $BB20Upper30Sec Then
;~ 		MyPut()
;~ 	  EndIf

;~ 	  If ($data < $BB20Lower30Sec And $BB20Upper30Sec - $BB20Lower30Sec > $BBOverlimit) Then
;~ 	  If ($data < $BB20Lower30Sec ) Then
;~ 		 MyCall()
;~ 	  EndIf
;~    EndIf



;~    Check for expiry if we are betting
   CheckExpire()

   $BoughtDelay += 1
   $Counter += 1

   Sleep(50)
WEnd

Func AutoItLog()
   ConsoleWrite("tick: " & $dataLocalTime & " - " & StringFormat("%.6f",$data) & " 14MA: " & StringFormat("%.6f",$SMA54) & " BBUp30: " & StringFormat("%.6f",$BB20Upper)  & " BBDown30: " & StringFormat("%.6f",$BB20Lower)& " p/l: " &  $profitcounter  & ":"  & $lostcounter)

   If ($Bought == True) Then
	  ConsoleWrite(" " &$buymode &" "& $BoughtPrice & " @ " & $ExpectedSellTime)

	  If ($buymode == "put") Then
		 If ($BoughtPrice > $data) Then
			ConsoleWrite(" " & "Winning")
		 Else
			ConsoleWrite(" " & "Losing")
		 EndIf
	  Else
		 If Not ($BoughtPrice > $data) Then
			ConsoleWrite(" " & "Winning")
		 Else
			ConsoleWrite(" " & "Losing")
		 EndIf
	  EndIf

   EndIf
	  ConsoleWrite(@CRLF)

	  FileWriteLine($RawDataLog, $dataLocalTime & " " & StringFormat("%.6f",$data) & @CRLF)
EndFunc

Func ReadMemoryIntoMemoryExtract()
   Local $Process = _MemoryOpen($pid);

   $memoryExtract = ""
   If Not @error Then
	  ;FileWriteLine($MemoryErrorLog,"Writing Memory" & @CRLF);
	  For $i = 0 to 100 Step 1
	  $Vaalue = _NewMemRead($address+$i,$Process,'byte');
		 If Not @error Then
			;FileWrite($filehandle,Chr(($Vaalue)));
			$memoryExtract = $memoryExtract & Chr($Vaalue)
		 Else
			FileWriteLine($MemoryErrorLog,"Error Reading Memory" & " " & @error & @CRLF);
		 EndIf
	  Next
	  ;FileWriteLine($filehandle,@CRLF);
   Else
   FileWriteLine($MemoryErrorLog,"Error Opening Memory" & " " & @error & @CRLF);
   EndIf
EndFunc

Func CalculateSMA20()
   If ($Counter > $TWENTY) Then
	  $numbers = $Counter
	  $sum = 0
	  $Counter2 = 0
	  While($Counter2 < $TWENTY)
		 $sum += $Values[$numbers - $Counter2];
		 $Counter2 += 1
	  WEnd
	  $Average = $sum / ($TWENTY);
	  $SMA20 = $Average
	  ;ConsoleWrite("256 MA: " & $Average & @LF)
   EndIf
EndFunc

Func CalculateSMA54()
      If ($Counter > $FIFTYFOUR) Then
	  $numbers = $Counter
	  $sum = 0
	  $Counter2 = 0
	  While($Counter2 < $FIFTYFOUR)
		 $sum += $Values[$numbers - $Counter2];
		 $Counter2 += 1
	  WEnd
	  $Average = $sum / ($FIFTYFOUR);
	  $SMA54 = $Average
	  ;ConsoleWrite("54 MA: " & $Average & @LF)
   EndIf
   EndFunc

Func CalculateSMA256()
      If ($Counter > $TWOFIFTYSIX) Then
	  $numbers = $Counter
	  $sum = 0
	  $Counter2 = 0
	  While($Counter2 < $TWOFIFTYSIX)
		 $sum += $Values[$numbers - $Counter2];
		 $Counter2 += 1
	  WEnd
	  $Average = $sum / ($TWOFIFTYSIX);
	  $SMA256 = $Average
	  ;ConsoleWrite("256 MA: " & $Average & @LF)
   EndIf
EndFunc

Func CalculateBB()
   If ($Counter > $TWOFIFTYSIX) Then
	  $numbers = $TWOFIFTYSIX

	  $sum = 0
	  $Counter2 = 0
	  While($Counter2 < $TWOFIFTYSIX)
		 $diff = $Values[$numbers - $Counter2] - $SMA256
		 $diffSquared = $diff * $diff
		 $sum += $diffSquared
		 $Counter2 += 1
	  WEnd
	  $Average = $sum / $TWOFIFTYSIX;
	  $Average = Sqrt($Average)
	  $BB20Upper = $SMA256 + $Average
	  $BB20Lower = $SMA256 - $Average
   ;ConsoleWrite("256 MA: " & $Average & @LF)
   EndIf
EndFunc

Func CheckExpire()
      If ($Bought == True) Then
	  CheckErrorExpireTime()
	  If ($dataLocalTime == $ExpectedSellTime) Then
		 $profit = $data - $BoughtPrice
		 $Bought = False
		 $BoughtDelay = 0
		 ConsoleWrite(@LF)
		 If ($buymode == "call") Then
			If ($BoughtPrice < $data) Then
			   $profitcounter += 1
			   ConsoleWrite("profit " & $buymode &@CRLF)
			   ConsoleWrite($buymode & " : " & $BoughtPrice & " expire : " & $data & @CRLF)
			   FileWriteLine($Logger2, "profit" & " : " & $BoughtPrice & " expire : " & $data & @CRLF)
			   ResetBid()
			Else
			   $lostcounter += 1
			   ConsoleWrite("lost " & $buymode &@CRLF)
			   ConsoleWrite($buymode & " : " & $BoughtPrice & " expire : " & $data & @CRLF)
			   FileWriteLine($Logger2, "lost" & " : " & $BoughtPrice & " expire : " & $data & @CRLF)
			   DoubleBid()
			   ;If $Minute30Trend > 0 Then
			   ;MyCall()
			   ;Else
			   ;MyPut()
			   ;EndIf
    	    EndIf
		 Else
			If ($BoughtPrice > $data) Then
			   $profitcounter += 1
			   ConsoleWrite("profit " & $buymode &@LF)
			   ConsoleWrite($buymode & " : " & $BoughtPrice & " expire : " & $data & @LF)
			   FileWriteLine($Logger2, "profit" & " : " & $BoughtPrice & " expire : " & $data & @LF)
			   ResetBid()
			Else
			   $lostcounter += 1
			   ConsoleWrite("lost " & $buymode &@LF)
			   ConsoleWrite($buymode & " : " & $BoughtPrice & " expire : " & $data & @LF)
			   FileWriteLine($Logger2, "lost" & " : " & $BoughtPrice & " expire : " & $data & @LF)
			   DoubleBid()
			   ;If $Minute30Trend > 0 Then
			   ;MyCall()
			   ;Else
			   ;MyPut()
			   ;EndIf
    	    EndIf
		 EndIf
	  EndIf
   EndIf
EndFunc

Func MyPut()
   If $Bought == False And $BetReady == True Then
	  $Bought = True;
	  $BoughtPrice = $data
	  $BoughtTime = $dataLocalTime
	  $ExpectedSellTime = GetExpireTime($BoughtTime)
	  $timeToExpire = $TimeLeft + 30
	  $buymode = "put";
	  ConsoleWrite("put at: " & $BoughtPrice & " @ " & $BidAmountArray[$BidAmount-1] & " time: " & $BoughtTime &@CRLF)
	  FileWriteLine($Logger2, "put at: " & $BoughtPrice & " @ " & $BidAmountArray[$BidAmount-1] & " time: " & $BoughtTime &@CRLF)
	  Sleep(200)
	  If $RealMoneyMode == True Then
		 MouseClick("Left",$PutPosX,$PutPosY,1)
	  EndIf
   EndIf
EndFunc

Func MyCall()
   If $Bought == False And $BetReady == True Then
	  $Bought = True;
	  $BoughtPrice = $data
	  $BoughtTime = $dataLocalTime
	  $ExpectedSellTime = GetExpireTime($BoughtTime)
	  $timeToExpire = $TimeLeft + 30
	  $buymode = "call";
	  ConsoleWrite("call at: " & $BoughtPrice & " @ " & $BidAmountArray[$BidAmount-1] & " time: " & $BoughtTime &@CRLF)
	  FileWriteLine($Logger2, "call at: " & $BoughtPrice & " @ " & $BidAmountArray[$BidAmount-1] & " time: " & $BoughtTime &@CRLF)
	  Sleep(200)
	  If $RealMoneyMode == True Then
		 MouseClick("Left",$CallPosX,$CallPosY,1)
	  EndIf
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
   If $TakeInput == True Then
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
   EndIf
   $BidAmount = 1
   $ToResetBid = False
   Sleep(50)
EndFunc

Func DoubleBid()
   $ToDoubleBid = True
   ActualDoubleBid()
EndFunc

Func ActualDoubleBid()
   $InChain = True
   If $TakeInput == True Then
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
EndIf
   $BidAmount += 1
   $ToDoubleBid = False
   Sleep(50)
EndFunc

Func _NewMemRead($Addr1, $Proc1, $type1)
If $type1 = "int" Then ;I only used int, if you use uint or any other integer representation, add them in here
Return (Dec(Hex(StringRegExpReplace(_MemoryRead($Addr1, $Proc1, $type1), "00000000", "", 1))))
Else
Return _MemoryRead($Addr1, $Proc1, $type1)
EndIf
EndFunc

Func ExtractValue($memoryStrip)
   Local $theString = StringSplit($memoryStrip,":")
   If ($theString[0] > 5) Then
	  If StringCompare($theString[3],$SearchString) == 0 Then
		 Return StringSplit($theString[4],",")[1]
	  Else
		 ConsoleWrite($theString[4])
	  EndIf
   EndIf
   Return 0
EndFunc

Func OpenStreamUsingFilename($filepath, ByRef $file)
If FileExists($filepath) then
   $file = FileOpen($filepath, $FO_OVERWRITE)
Else
   _FileCreate($filepath)
   $file = FileOpen($filepath, $FO_OVERWRITE)
EndIf

If @error Then
	MsgBox($MB_SYSTEMMODAL, "", "An error occurred when reading the file.")
 EndIf

EndFunc