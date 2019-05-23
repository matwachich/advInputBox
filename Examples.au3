#NoTrayIcon
#include <EditConstants.au3>

#include "advInputBox.au3"

For $i = 1 To 5
	Call("Example" & $i)
Next

; Simple login box
Func Example1()
	; thanks to the non-strictness of the JSON UDF, we can use non-strict JSON notation! (see NON-STRICT MODE in https://zserge.com/jsmn.html)
	Local $sJSON = '{ title:"Login" controls:[' & _
		'{type:"label", text:"Use this form to login to your account"}' & _
		'{type:"input", id:"username", label:"Username"}' & _
		'{type:"input", id:"password", label:"Password", style:"' & BitOR($GUI_SS_DEFAULT_INPUT,$ES_PASSWORD) & '"}' & _
		'{type:"check", id:"remember", label:"Remember me", value:true}' & _
	']}'

	Local $oRet = advInputBox($sJSON)
	If @error Then
		MsgBox(64, "Example1", "Dialog canceled")
	Else
		MsgBox(64, "Example1", "Return: " & Json_Encode($oRet, 128))
		; you can access individual values by ids:
		; Json_ObjGet($oRet, "username")
		; Json_ObjGet($oRet, "password")
		; Json_ObjGet($oRet, "remember")
	EndIf
EndFunc

; All controls
Func Example2()
	Local $sJSON = '{ title:"Showcase" font:[10, 600, 0, "Calibri"] controls:[' & _
		'{type:"label", text:"Enter you personal informations (please :p)"},' & _
		'{type:"input", id:"firstname", label:"First name"},' & _
		'{type:"input", id:"lastname", label:"Last name"},' & _
		'{type:"combo", id:"sexe", label:"Sexe", options:["Male", "Female"], selected:-1},' & _ ; selected = 0 for male, = 1 for female ; or you can use the exact same string as in options "Male" or "Female"
		'{type:"date", id:"dob", label:"Date of birth", value:"2000/01/01", style:0},' & _ ; $DTS_SHORTDATEFORMAT
		'{type:"separator"},' & _
		'{type:"edit", id:"address", label:"Address", lines:5},' & _
		'{type:"list", id:"options", label:"Options", options:["First", "Second", "Third"], selected:["First"]}' & _
		'{type:"check", id:"agree", label:"I agree to share my personnal informations with big brother", value:true}' & _
	']}'

	Local $oRet = advInputBox($sJSON)
	If @error Then
		MsgBox(64, "Example1", "Dialog canceled")
	Else
		MsgBox(64, "Example1", "Return: " & Json_Encode($oRet, 128))
	EndIf
EndFunc

; Validation function
Func Example3()
	Local $sJSON = '{ title:"Login" font:[10, 400, 0, "Consolas"] controls:[' & _
		'{type:"label", text:"Use this form to login to your account", style:' & $ES_CENTER & ', font:[14, 600, 0, "Consolas"]}' & _
		'{type:"input", id:"username", label:"Username"}' & _
		'{type:"input", id:"password", label:"Password", style:"' & BitOR($GUI_SS_DEFAULT_INPUT,$ES_PASSWORD) & '"}' & _
		'{type:"check", id:"remember", label:"Remember me", value:true}' & _
	']}'

	Local $oRet = advInputBox($sJSON, _validationFunc)
	If @error Then
		MsgBox(64, "Example1", "Dialog canceled")
	Else
		MsgBox(64, "Example1", "Return: " & Json_Encode($oRet, 128))
	EndIf
EndFunc

Func _validationFunc($hGUI, $oData, $oCtrlIDs, $vUserData)
	Local $sUser = Json_ObjGet($oData, "username"), $sPass = Json_ObjGet($oData, "password")
	If $sUser == "admin" And $sPass == "password" Then Return True

	GUICtrlSetBkColor(Json_ObjGet($oCtrlIDs, "username")[1], 0xFFCCCC)
	GUICtrlSetBkColor(Json_ObjGet($oCtrlIDs, "password")[1], 0xFFCCCC)
	GUICtrlSetData(Json_ObjGet($oCtrlIDs, "password"), "")
	Return False
EndFunc

Func Example4()
	Local $sJSON = '{ title:"ListBox test", font:[10, 400, 0, "Consolas"], controls:[' & _
		'{type:"list", id:"options", label:"You can use the \"list\" control to select multiple options", options:["First", "Second", "Third", "Fourth"], selected:["Third"]}' & _
	']}'

	Local $oRet = advInputBox($sJSON)
	If @error Then
		MsgBox(64, "Example1", "Dialog canceled")
	Else
		MsgBox(64, "Example1", "Return: " & Json_Encode($oRet, 128))
	EndIf
EndFunc

Func Example5()
	Local $sJSON = '{ title:"Accelerators test" font:[10,400,0,"Consolas"] controls:[' & _
		'{type:"label" text:"You can use hotkeys to fire custom events\r\nTry: F1, F2, Ctrl+S"}' & _
		'{type:"input" id:"input" label:"Some inputBox"}' & _
	'] accels:[' & _
		'{hotkey:"{F1}" id:"action_F1"}' & _
		'{hotkey:"{F2}" id:"action_F2"}' & _
		'{hotkey:"^s" id:"action_Ctrl_S"}' & _
	']}'

	Local $oRet = advInputBox($sJSON, Null, _example5_accelsCallback)
	If @error Then
		MsgBox(64, "Example1", "Dialog canceled")
	Else
		MsgBox(64, "Example1", "Return: " & Json_Encode($oRet, 128))
	EndIf
EndFunc
Func _example5_accelsCallback($hGUI, $sActionID, $oData, $oCtrlIDs, $vUserData)
	Switch $sActionID
		Case "action_F1", "action_F2", "action_Ctrl_S"
			MsgBox(64, "Accelerators", "Event fired: " & $sActionID)
			GUICtrlSetData(Json_Get($oCtrlIDs, ".input[1]"), "Accel: " & $sActionID)
	EndSwitch
EndFunc
