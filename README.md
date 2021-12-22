# Deprecated
Use https://github.com/matwachich/autoit-guiutils

# Advanced InputBox
Advanced InputBox for AutoIt3, with :

* Many controls types (Input, Edit, Combo, Date and Checkboxes)
* Simple GUI definition markup based on non-strict JSON
* Automatic positioning and sizing
* Validation callback function

# Documentation
```
; #INDEX# ============================================================================================================
; Title .........: advInputBox
; AutoIt Version : Developped with 3.3.14.1 (should work with previous, not very old versions!)
; Language ......: Neutral
; Description ...: An advanced, flexible and highly cutomizable InputBox, that supports Input, Edit, Combo boxe,
;                  Date, and Checkbox controls. And that returns the data as a JSON associative array (object).
; Remarks .......: This UDFs extensively uses JavaScript Object Notation (JSON).
; Note ..........:
; Author(s) .....: matwachich at gmail dot com
; Credits .......: thanks to:
;                  - Ward and Jos for the excellent Json.au3
;                  - Melba23 for the excellent StringSize.au3 and GUIScrollbars_Ex.au3
; ====================================================================================================================
```

```
; #FUNCTION# ====================================================================================================================
; Name ..........: advInputBox
; Description ...: Just like InputBox, but with more controls and customisation possiblities
; Syntax ........: advInputBox($sJSON[, $fnValidation = Null[, $hParentGUI = Null]])
; Parameters ....: $sJSON               - a JSON string used to configure all aspects of the Dialog (see documentation above and
;                                         examples to understand).
;                  $fnValidation        - [optional] data validation function. If provided, it is called on OK button press.
;                                         It must be of the form _validation($hInputBoxHGUI, $oData, $oCtrlIDs, $oLabelsCtrlIDs).
;                                            - $hInputBoxHGUI:  handle to the InputBox Dialog.
;                                            - $oData:          JSON object containing the data entered in the AdvInputBox, keyed
;                                                               by "id"s (see controls definitions).
;                                            - $oCtrlIDs:       JSON object containing the control IDs of the input and label
;                                                               controls, keyed by "id"s.
;                                                               { "id": [labelID, inputCtrlID], ... }
;                                            - $vUserData:      user data
;                                         If the function returns True, the advInputBox call will return the same $oData object.
;                                         Otherwise, nothing happens (the InputBox stays opened).
;                                         Default is Null (no callback, the functions returns immediatly on OK button press).
;                  $vUserData           - [optional] user data passed to $fnValidation. Default is Null.
;                  $hParentGUI          - [optional] a handle to the parent GUI. Default is Null.
; Return values .: - On OK button press, if no validation callback is provided or if it returns True : the function returns a JSON
;                    object containing the data entered in the AdvInputBox, keyed by "id"s (see control definitions in the
;                    documentation above).
;                  - On cancel (dialog close or Esc is pressed) : the return value is Null and @error is set to 1.
;                  - On error: returns Null and set @error to -1 if the JSON string provided is invalid
; Author ........: matwachich at gmail dot com
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
```

```
JSON definition {
// all these values are optionals
	title: "Window Title"
	labelsMaxWidth: max width of labels column (left)
	inputsWidth: max width of inputs column (right)
	maxHeight: max Dialog height (if exceeded, it will use scroll boxes)
	margin: default vertical and horizontal margin between controls and dialog borders
	inputLabelPadding: vertical bias of the inputLabel according to it's control (default 2)
	style: GUI style
	exstyle: GUI extended style
	bkcolor: GUISetBKColor
	btnText: OK button text
	btnColor: OK button color
	btnBkColor: OK button BK color
	font: [size, weight, style, name]

// the only necessary one is this (note that in each control type, the values between <> are optionals)
	controls: [
		{
			type: "separator"

			optionals:
			----------
			color: separator color (default: 0x000000)
		}
		{
			type: "label"
			text: "Label text"

			optionals:
			----------
			margin
			style, exstyle, color, bkcolor, font
		}
		{
			type:  "input"
			id:    "name" (must be unique, without spaces)
			label: "label text"

			optionals:
			----------
			value: "initial value"
			margin
			style, exstyle, color, bkcolor, font
			labelStyle, labelExStyle, labelColor, labelBkColor, labelFont
		}
		{
			type:  "edit"
			id:    "name" (must be unique, without spaces)
			label: "label text"
			lines: linesCount (default is 3)

			optionals:
			----------
			value: "initial value"
			margin
			style, exstyle, color, bkcolor, font
			labelStyle, labelExStyle, labelColor, labelBkColor, labelFont
		}
		{
			type:  "date"
			id:    "name" (must be unique, without spaces)
			label: "label text"

			optionals:
			----------
			value: "initial value"
			margin
			style, exstyle, color, bkcolor, font
			labelStyle, labelExStyle, labelColor, labelBkColor, labelFont
		}
		{
			type:  "combo"
			id:    "name" (must be unique, without spaces)
			label: "label text"

			optionals:
			----------
			options: ["option0", "option1" ...]
			selected: 0|1|...|N OR "option0"|"option1"|...|"optionN"
			margin
			style, exstyle, color, bkcolor, font
			labelStyle, labelExStyle, labelColor, labelBkColor, labelFont
		}
	]
}
```

# Examples
A simple login box:
```AutoIt
#include <EditConstants.au3>
#include "advInputBox.au3"

Dim $sJSON = '{ title:"Login" controls:[' & _
  '{type:"label", value:"Use this form to login to your account"}' & _
  '{type:"input", id:"username", label:"Username"}' & _
  '{type:"input", id:"password", label:"Password", style:"' & BitOR($GUI_SS_DEFAULT_INPUT,$ES_PASSWORD) & '"}' & _
  '{type:"check", id:"remember", label:"Remember me", value:true}' & _
']}'

Dim $oRet = advInputBox($sJSON)
If @error Then
  MsgBox(64, "Example1", "Dialog canceled")
Else
  MsgBox(64, "Example1", "Return: " & Json_Encode($oRet, 128))
  ; you can access individual values by ids:
  ; Json_ObjGet($oRet, "username")
  ; Json_ObjGet($oRet, "password")
  ; Json_ObjGet($oRet, "remember")
EndIf
```

![Example1](/screens/example1.PNG)

Controls showcase:
```AutoIt
#include "advInputBox.au3"

Local $sJSON = '{ title:"Showcase" font:[10, 600, 0, "Cambria"] controls:[' & _
  '{type:"label", value:"Enter you personal informations (please :p)"},' & _
  '{type:"input", id:"firstname", label:"First name"},' & _
  '{type:"input", id:"lastname", label:"Last name"},' & _
  '{type:"combo", id:"sexe", label:"Sexe", options:["Male", "Female"], selected:-1},' & _ ; selected = 0 for male, = 1 for female
  '{type:"date", id:"dob", label:"Date of birth", value:"2000/01/01", style:0},' & _ ; $DTS_SHORTDATEFORMAT
  '{type:"separator"},' & _
  '{type:"edit", id:"address", label:"Address", lines:5},' & _
  '{type:"check", id:"agree", label:"I agree to share my personnal informations with big brother", value:true}' & _
']}'

Local $oRet = advInputBox($sJSON)
If @error Then
  MsgBox(64, "Example1", "Dialog canceled")
Else
  MsgBox(64, "Example1", "Return: " & Json_Encode($oRet, 128))
EndIf
```

![Example2](/screens/example2.PNG)

Login box with validation function:
```AutoIt
#include <EditConstants.au3>
#include "advInputBox.au3"

Local $sJSON = '{ title:"Login" font:[10, 400, 0, "Consolas"] controls:[' & _
  '{type:"label", value:"Use this form to login to your account", font:[14, 600, 0, "Consolas"]}' & _
  '{type:"input", id:"username", label:"Username"}' & _
  '{type:"input", id:"password", label:"Password", style:"' & BitOR($GUI_SS_DEFAULT_INPUT,$ES_PASSWORD) & '"}' & _
  '{type:"check", id:"remember", label:"Remember me", value:true}' & _
']}'

Local $oRet = advInputBox($sJSON, _validationFunc, "some user data...")
If @error Then
  MsgBox(64, "Example1", "Dialog canceled")
Else
  MsgBox(64, "Example1", "Return: " & Json_Encode($oRet, 128))
EndIf

Func _validationFunc($hGUI, $oData, $oCtrlIDs, $vUserData)
	Local $sUser = Json_ObjGet($oData, "username"), $sPass = Json_ObjGet($oData, "password")
	If $sUser == "admin" And $sPass == "password" Then Return True

	GUICtrlSetBkColor(Json_ObjGet($oCtrlIDs, "username"), 0xFFCCCC)
	GUICtrlSetBkColor(Json_ObjGet($oCtrlIDs, "password"), 0xFFCCCC)
	GUICtrlSetData(Json_ObjGet($oCtrlIDs, "password"), "")
	Return False
EndFunc
```

![Example3](/screens/example3.PNG)
