CheckBox(str) {
	if MsgBox(str,, "YesNo") == "No"
		return False
	return True
}
GetMonitorIndexFromWindow(windowHandle) {
	; Starts with 1.
	monitorIndex := 1

	VarSetCapacity(monitorInfo, 40)
	NumPut(40, monitorInfo)
	
	if (monitorHandle := DllCall("MonitorFromWindow", "uint", windowHandle, "uint", 0x2)) 
		&& DllCall("GetMonitorInfo", "uint", monitorHandle, "uint", &monitorInfo) 
	{
		monitorLeft   := NumGet(monitorInfo,  4, "Int")
		monitorTop    := NumGet(monitorInfo,  8, "Int")
		monitorRight  := NumGet(monitorInfo, 12, "Int")
		monitorBottom := NumGet(monitorInfo, 16, "Int")
		workLeft      := NumGet(monitorInfo, 20, "Int")
		workTop       := NumGet(monitorInfo, 24, "Int")
		workRight     := NumGet(monitorInfo, 28, "Int")
		workBottom    := NumGet(monitorInfo, 32, "Int")
		isPrimary     := NumGet(monitorInfo, 36, "Int") & 1

		;MsgBox(
		;"monitorLeft   " monitorLeft  
		;"`nmonitorTop    " monitorTop   
		;"`nmonitorRight  " monitorRight 
		;"`nmonitorBottom " monitorBottom
		;"`nworkLeft      " workLeft     
		;"`nworkTop       " workTop      
		;"`nworkRight     " workRight    
		;"`nworkBottom    " workBottom)
		
		monitorCount := MonitorGetCount()

		Loop monitorCount
		{
			MonitorGet(A_Index, left, top, right, bottom)

			; Compare location to determine the monitor index.
			if ((monitorLeft = left) and (monitorTop = top) and (monitorRight = right) and (monitorBottom = bottom))
			{
				monitorIndex := A_Index
				break
			}
		}
	}
	
	return monitorIndex
}

class MonitorStats
{
	width := 0
	height := 0
}
^+Left::
^+Right::
monitorCount := MonitorGetCount()
monitors := []

monitorWidth := 1600
omitTitles := "Program Manager"
list := WinGetList(,, omitTitles)

; Get all monitors
Loop monitorCount {
	if MonitorGet(A_Index, left, top, right, bottom) {
		;MsgBox "Left: " Left " -- Top: " Top " -- Right: " Right " -- Bottom: " Bottom
		newMonitor := new MonitorStats()
		newMonitor.width := (right + left)
		newMonitor.height := (top - bottom)
		monitors.Push(newMonitor)
	}
}

; Get all programs and switch them
Loop list.Count() {
	id := list[A_Index]
	monitorIdx := GetMonitorIndexFromWindow(id)
	windowTitle := WinGetTitle("ahk_id " id)
	
	if windowTitle == "" {
		continue
	}
	WinGetPos x, y, width, height, windowTitle
	
	;if !CheckBox("Id: " id "`n" "Title: " windowTitle "`nMonitor: " monitorIdx
	;"`nx: " x "`ny: " y "`nwidth: " width "`nheight: " height) {
	;	break
	;}
	currentMonitorWidth := monitors[monitorIdx].width

	offsetX := 1 - (x / currentMonitorWidth)
	
	targetMonitorIdx := Mod(monitorIdx, monitorCount) + 1
	targetMonitorWidth := monitors[targetMonitorIdx].width

	newX := offsetX * targetMonitorWidth
	;MsgBox("OffsetX: " offsetX "`nnewX: " newX)
	
	WinMove newX, y,,, windowTitle
}
