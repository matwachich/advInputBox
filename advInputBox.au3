#include-once

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

; #CURRENT# ==========================================================================================================
; advInputBox: Just like InputBox, but with more controls and customisation possiblities
; ====================================================================================================================

; #INTERNAL_USE_ONLY#=================================================================================================
; __advInputBox_stringSize
; __advInputBox_objGet
; ====================================================================================================================

#include <Array.au3>
#include <GuiComboBox.au3>
#include <GUIConstantsEx.au3>
#include <String.au3>

#include "Json.au3"
#include "StringSize.au3"
#include "GUIScrollbars_Ex.au3"

#cs
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
			id:    "name" (must be unique)
			label: "label text"

			optionals:
			----------
			value: "initial value"
			margin
			style, exstyle, color, bkcolor, font
			labelStyle, labelExStyle, labelColor, labelBkColor, labelFont
			>
		}
		{
			type:  "edit"
			id:    "name" (must be unique)
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
			id:    "name" (must be unique)
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
			id:    "name" (must be unique)
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
#ce

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
;                                            - $oCtrlIDs:       JSON object containing the control IDs of the input controls
;                                                               (inputs, dates, combo boxes, edits, check boxes), keyed by "id"s.
;                                            - $oLabelsCtrlIDs: JSON object containing the control IDs of the labels associated
;                                                               with each input control, keyed by "id"s.
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
Func advInputBox($sJSON, $fnValidation = Null, $vUserData = Null, $hParentGUI = Null)
	Local $oJSON = Json_Decode($sJSON)
	If @error Then Return SetError(-1, 0, Null)

	Local $vTmp ; just a dummy temporary useful variable

	; get main Dialog variables
	Local $sDlgTitle = __advInputBox_objGet($oJSON, "title", "Advanced InputBox")
	Local $iLabelsMaxWidth = __advInputBox_objGet($oJSON, "labelsMaxWidth", 180)
	Local $iInputsWidth = __advInputBox_objGet($oJSON, "inputsWidth", 250)
	Local $iInputLabelPadding = __advInputBox_objGet($oJSON, "inputLabelPadding", 2)
	Local $iMaxHeight = __advInputBox_objGet($oJSON, "maxHeight", 600)
	Local $iMargin = __advInputBox_objGet($oJSON, "margin", 8)
	Local $aDefaultFont = __advInputBox_objGet($oJSON, "font", Null)

	Local $aControls = __advInputBox_objGet($oJSON, "controls", Null)
	If $aControls == Null Or Not IsArray($aControls) Or UBound($aControls) <= 0 Then Return SetError(-1, 0, Null)

	; add inputs labels and calculate max labels width
	Local $i = 0, $sType, $oLabel, $iMaxCalculatedLabelsWidth = 0
	Do
		$sType = StringLower(Json_ObjGet($aControls[$i], "type"))
		If $sType <> "separator" And $sType <> "label" And $sType <> "inputLabel" And $sType <> "inputBtn" Then
			; a label is mendatory for all input controls
			If Not Json_ObjExists($aControls[$i], "label") Or Json_ObjGet($aControls[$i], "label") == "" Then
				Json_ObjPut($aControls[$i], "label", Json_ObjGet($aControls[$i], "type") & ":" & Json_ObjGet($aControls[$i], "id"))
			EndIf

			; calculate input label width
			$vTmp = __advInputBox_stringSize(Json_ObjGet($aControls[$i], "label"), __advInputBox_objGet($aControls[$i], "labelFont", $aDefaultFont), $iLabelsMaxWidth)[2]
			If $vTmp > $iMaxCalculatedLabelsWidth Then $iMaxCalculatedLabelsWidth = $vTmp

			; add inputLabel just befor the input control
			$oLabel = Json_ObjCreate()
			Json_ObjPut($oLabel, "type", "inputLabel")
			Json_ObjPut($oLabel, "text", Json_ObjGet($aControls[$i], "label"))

			If Json_ObjExists($aControls[$i], "margin") Then Json_ObjPut($oLabel, "margin", Json_ObjGet($aControls[$i], "margin"))
			If Json_ObjExists($aControls[$i], "labelStyle") Then Json_ObjPut($oLabel, "style", Json_ObjGet($aControls[$i], "labelStyle"))
			If Json_ObjExists($aControls[$i], "labelExStyle") Then Json_ObjPut($oLabel, "exstyle", Json_ObjGet($aControls[$i], "labelExStyle"))
			If Json_ObjExists($aControls[$i], "labelColor") Then Json_ObjPut($oLabel, "color", Json_ObjGet($aControls[$i], "labelColor"))
			If Json_ObjExists($aControls[$i], "labelBkColor") Then Json_ObjPut($oLabel, "bkcolor", Json_ObjGet($aControls[$i], "labelBkColor"))
			If Json_ObjExists($aControls[$i], "labelFont") Then Json_ObjPut($oLabel, "font", Json_ObjGet($aControls[$i], "labelFont"))

			; input label default style is right aligned
			If Not Json_ObjExists($oLabel, "style") Then Json_ObjPut($oLabel, "style", 2)

			_ArrayInsert($aControls, $i, $oLabel)
			$i += 1
		EndIf
		$i += 1
	Until $i >= UBound($aControls)

	Local $iMaxLabelsAndInputsWidth = $iMaxCalculatedLabelsWidth + $iMargin + $iInputsWidth

	; calculate controls position and size
	Local $iNextHeight = $iMargin, $iInputLabelNextHeight = $iMargin, $aSZ

	For $i = 0 To UBound($aControls) - 1
		$sType = StringLower(Json_ObjGet($aControls[$i], "type"))
		Switch $sType
			Case "separator"
				Json_ObjPut($aControls[$i], "_x", $iMargin)
				Json_ObjPut($aControls[$i], "_y", $iNextHeight)
				Json_ObjPut($aControls[$i], "_w", $iMaxLabelsAndInputsWidth)
				Json_ObjPut($aControls[$i], "_h", 1)

				$iNextHeight += __advInputBox_objGet($aControls[$i], "margin", $iMargin) + 1
			; ---
			Case "label"
				$aSZ = __advInputBox_stringSize( _
					Json_ObjGet($aControls[$i], "text"), _
					__advInputBox_objGet($aControls[$i], "font", $aDefaultFont), _
					$iMaxLabelsAndInputsWidth _
				)

				Json_ObjPut($aControls[$i], "_x", $iMargin)
				Json_ObjPut($aControls[$i], "_y", $iNextHeight)
				Json_ObjPut($aControls[$i], "_w", $iMaxLabelsAndInputsWidth)
				Json_ObjPut($aControls[$i], "_h", $aSZ[3])

				$iNextHeight += $aSZ[3] + __advInputBox_objGet($aControls[$i], "margin", $iMargin)
			; ---
			Case "inputLabel"
				$aSZ = __advInputBox_stringSize( _
					Json_ObjGet($aControls[$i], "text"), _
					__advInputBox_objGet($aControls[$i], "font", $aDefaultFont), _
					$iMaxCalculatedLabelsWidth _
				)

				Json_ObjPut($aControls[$i], "_x", $iMargin)
				Json_ObjPut($aControls[$i], "_y", $iNextHeight + $iInputLabelPadding)
				Json_ObjPut($aControls[$i], "_w", $iMaxCalculatedLabelsWidth)
				Json_ObjPut($aControls[$i], "_h", $aSZ[3])

				$iInputLabelNextHeight = $iNextHeight + $aSZ[3] + __advInputBox_objGet($aControls[$i], "margin", $iMargin)
			; ---
			Case "input", "date", "combo"
				$aSZ = __advInputBox_stringSize("A", __advInputBox_objGet($aControls[$i], "font", $aDefaultFont), $iInputsWidth)

				Json_ObjPut($aControls[$i], "_x", $iMaxCalculatedLabelsWidth + (2 * $iMargin))
				Json_ObjPut($aControls[$i], "_y", $iNextHeight)
				Json_ObjPut($aControls[$i], "_w", $iInputsWidth)
				Json_ObjPut($aControls[$i], "_h", $aSZ[3] + 4)

				$iNextHeight += $aSZ[3] + 4 + __advInputBox_objGet($aControls[$i], "margin", $iMargin)
				If $iInputLabelNextHeight > $iNextHeight Then $iNextHeight = $iInputLabelNextHeight
			; ---
			Case "edit"
				$vTmp = Int(__advInputBox_objGet($aControls[$i], "lines", 3))
				$aSZ = __advInputBox_stringSize( _
					_StringRepeat("Line" & @CRLF, $vTmp - 1), _
					__advInputBox_objGet($aControls[$i], "font", $aDefaultFont) _
				)

				Json_ObjPut($aControls[$i], "_x", $iMaxCalculatedLabelsWidth + (2 * $iMargin))
				Json_ObjPut($aControls[$i], "_y", $iNextHeight)
				Json_ObjPut($aControls[$i], "_w", $iInputsWidth)
				Json_ObjPut($aControls[$i], "_h", $aSZ[3] + 21 + $vTmp)

				$iNextHeight += $aSZ[3] + 21 + 4 + __advInputBox_objGet($aControls[$i], "margin", $iMargin)
				If $iInputLabelNextHeight > $iNextHeight Then $iNextHeight = $iInputLabelNextHeight
			; ---
			Case "check"
				$aSZ = __advInputBox_stringSize("A", __advInputBox_objGet($aControls[$i], "font", $aDefaultFont), $iInputsWidth)

				Json_ObjPut($aControls[$i], "_x", $iMaxCalculatedLabelsWidth + (2 * $iMargin))
				Json_ObjPut($aControls[$i], "_y", $iNextHeight)
				Json_ObjPut($aControls[$i], "_w", $iInputsWidth)
				Json_ObjPut($aControls[$i], "_h", $aSZ[3])

				If $i < UBound($aControls) - 2 And StringLower(Json_ObjGet($aControls[$i + 2], "type")) == "check" Then
					$iNextHeight += $aSZ[3]
				Else
					$iNextHeight += $aSZ[3] + __advInputBox_objGet($aControls[$i], "margin", $iMargin)
					If $iInputLabelNextHeight > $iNextHeight Then $iNextHeight = $iInputLabelNextHeight
				EndIf
			; ---
;~ 			Case "file"
;~ 			Case "color"
;~ 			Case "font"
		EndSwitch
	Next

	; build Dialog
	Local $hGUI
	Local $iGUIWidth = $iMaxLabelsAndInputsWidth + (2 * $iMargin)
	Local $iGUIHeight = $iNextHeight + $iMargin + 25

	If $iGUIHeight > $iMaxHeight Then
		Local $iScrollBarWidth = _WinAPI_GetSystemMetrics($SM_CXVSCROLL)
		$hGUI = GUICreate($sDlgTitle, $iGUIWidth + $iScrollBarWidth, $iMaxHeight, -1, -1, __advInputBox_objGet($oJSON, "style", -1), __advInputBox_objGet($oJSON, "exstyle", -1), $hParentGUI)
		_GUIScrollbars_Generate($hGUI, $iGUIWidth, $iGUIHeight)
	Else
		$hGUI = GUICreate($sDlgTitle, $iGUIWidth, $iGUIHeight, -1, -1, __advInputBox_objGet($oJSON, "style", -1), __advInputBox_objGet($oJSON, "exstyle", -1), $hParentGUI)
	EndIf

	If Json_ObjExists($oJSON, "bkcolor") Then GUISetBkColor(Json_ObjGet($oJSON, "bkcolor"), $hGUI)
	If $aDefaultFont <> Null Then GUISetFont($aDefaultFont[0], $aDefaultFont[1], $aDefaultFont[2], $aDefaultFont[3])

	For $i = 0 To UBound($aControls) - 1
		$sType = StringLower(Json_ObjGet($aControls[$i], "type"))
		Switch $sType
			Case "separator"
				Json_ObjPut($aControls[$i], "_ctrlID", GUICtrlCreateLabel("", _
					Json_ObjGet($aControls[$i], "_x"), Json_ObjGet($aControls[$i], "_y"), _
					Json_ObjGet($aControls[$i], "_w"), Json_ObjGet($aControls[$i], "_h"), _
					__advInputBox_objGet($aControls[$i], "style", -1), __advInputBox_objGet($aControls[$i], "exstyle", -1) _
				))
				GUICtrlSetBkColor(-1, __advInputBox_objGet($aControls[$i], "color", 0x00000000))
			Case "label", "inputLabel"
				Json_ObjPut($aControls[$i], "_ctrlID", GUICtrlCreateLabel( _
					Json_ObjGet($aControls[$i], "text"), _
					Json_ObjGet($aControls[$i], "_x"), Json_ObjGet($aControls[$i], "_y"), _
					Json_ObjGet($aControls[$i], "_w"), Json_ObjGet($aControls[$i], "_h"), _
					__advInputBox_objGet($aControls[$i], "style", -1), __advInputBox_objGet($aControls[$i], "exstyle", -1) _
				))
			Case "input"
				Json_ObjPut($aControls[$i], "_ctrlID", GUICtrlCreateInput( _
					Json_ObjGet($aControls[$i], "value"), _
					Json_ObjGet($aControls[$i], "_x"), Json_ObjGet($aControls[$i], "_y"), _
					Json_ObjGet($aControls[$i], "_w"), Json_ObjGet($aControls[$i], "_h"), _
					__advInputBox_objGet($aControls[$i], "style", -1), __advInputBox_objGet($aControls[$i], "exstyle", -1) _
				))
			Case "date"
				Json_ObjPut($aControls[$i], "_ctrlID", GUICtrlCreateDate( _
					Json_ObjGet($aControls[$i], "value"), _
					Json_ObjGet($aControls[$i], "_x"), Json_ObjGet($aControls[$i], "_y"), _
					Json_ObjGet($aControls[$i], "_w"), Json_ObjGet($aControls[$i], "_h"), _
					__advInputBox_objGet($aControls[$i], "style", -1), __advInputBox_objGet($aControls[$i], "exstyle", -1) _
				))
			Case "combo"
				Json_ObjPut($aControls[$i], "_ctrlID", GUICtrlCreateCombo( _
					Json_ObjGet($aControls[$i], "value"), _
					Json_ObjGet($aControls[$i], "_x"), Json_ObjGet($aControls[$i], "_y"), _
					Json_ObjGet($aControls[$i], "_w"), Json_ObjGet($aControls[$i], "_h"), _
					__advInputBox_objGet($aControls[$i], "style", -1), __advInputBox_objGet($aControls[$i], "exstyle", -1) _
				))
				GUICtrlSetData(-1, _ArrayToString(__advInputBox_objGet($aControls[$i], "options", ""), Opt("GUIDataSeparatorChar")))
				_GUICtrlComboBox_SetCurSel(GUICtrlGetHandle(-1), __advInputBox_objGet($aControls[$i], "selected", -1))
			Case "edit"
				Json_ObjPut($aControls[$i], "_ctrlID", GUICtrlCreateEdit( _
					Json_ObjGet($aControls[$i], "value"), _
					Json_ObjGet($aControls[$i], "_x"), Json_ObjGet($aControls[$i], "_y"), _
					Json_ObjGet($aControls[$i], "_w"), Json_ObjGet($aControls[$i], "_h"), _
					__advInputBox_objGet($aControls[$i], "style", -1), __advInputBox_objGet($aControls[$i], "exstyle", -1) _
				))
			Case "check"
				Json_ObjPut($aControls[$i], "_ctrlID", GUICtrlCreateCheckbox("", _
					Json_ObjGet($aControls[$i], "_x"), Json_ObjGet($aControls[$i], "_y"), _
					Json_ObjGet($aControls[$i], "_w"), Json_ObjGet($aControls[$i], "_h"), _
					__advInputBox_objGet($aControls[$i], "style", -1), __advInputBox_objGet($aControls[$i], "exstyle", -1) _
				))
				GUICtrlSetState(-1, Json_ObjGet($aControls[$i], "value") ? 1 : 4) ; $GUI_CHECKED, $GUI_UNCHECKED
		EndSwitch

		If $sType <> "separator" Then
			If Json_ObjExists($aControls[$i], "color") Then GUICtrlSetColor(-1, Json_ObjGet($aControls[$i], "color"))
			If Json_ObjExists($aControls[$i], "bkcolor") Then GUICtrlSetBKColor(-1, Json_ObjGet($aControls[$i], "bkcolor"))
			If Json_ObjExists($aControls[$i], "font") Then
				$vTmp = Json_ObjGet($aControls[$i], "font")
				GUICtrlSetFont(-1, $vTmp[0], $vTmp[1], $vTmp[2], $vTmp[3])
			EndIf
		EndIf
	Next

	; validation button
	Local $iBtnOK = GUICtrlCreateButton(__advInputBox_objGet($oJSON, "btnText", "OK"), $iMargin, $iNextHeight, $iMaxLabelsAndInputsWidth, 25, 1) ; $BS_DEFPUSHBUTTON
	If Json_ObjExists($oJSON, "btnColor") Then GUICtrlSetColor(-1, Json_ObjGet($oJSON, "btnColor"))
	If Json_ObjExists($oJSON, "btnBkColor") Then GUICtrlSetColor(-1, Json_ObjGet($oJSON, "btnBkColor"))

	; enter dialog loop
	$vTmp = Opt("GUICloseOnEsc", 1)
	GUISetState(@SW_SHOW, $hGUI)

	Local $oRet = Json_ObjCreate(), $oLabelsIDs = Json_ObjCreate(), $oCtrlIDs = Json_ObjCreate()
	While 1
		$aMsg = GUIGetMsg(1)
		If $aMsg[1] == $hGUI Then
			Switch $aMsg[0]
				Case $GUI_EVENT_MINIMIZE
					_GUIScrollbars_Minimize($hGUI)
				Case $GUI_EVENT_RESTORE
					_GUIScrollbars_Restore($hGUI)
				; ---
				Case $GUI_EVENT_CLOSE
					GUIDelete($hGUI)
					Opt("GUICloseOnEsc", $vTmp)
					Return SetError(1, 0, Null)
				; ---
				Case $iBtnOK
					For $i = 0 To Ubound($aControls) - 1
						If Json_ObjExists($aControls[$i], "id") And Json_ObjExists($aControls[$i], "_ctrlID") Then
							Json_ObjPut($oCtrlIDs, Json_ObjGet($aControls[$i], "id"), Json_ObjGet($aControls[$i], "_ctrlID"))
							Json_ObjPut($oLabelsIDs, Json_ObjGet($aControls[$i], "id"), Json_ObjGet($aControls[$i - 1], "_ctrlID")) ; WARNING: this implies that an input control MUST ALWAYS BE PRECEEDED by an input label
							Switch StringLower(Json_ObjGet($aControls[$i], "type"))
								Case "check"
									Json_ObjPut($oRet, Json_ObjGet($aControls[$i], "id"), GUICtrlRead(Json_ObjGet($aControls[$i], "_ctrlID")) == $GUI_CHECKED)
								Case Else
									Json_ObjPut($oRet, Json_ObjGet($aControls[$i], "id"), GUICtrlRead(Json_ObjGet($aControls[$i], "_ctrlID")))
							EndSwitch
						EndIf
					Next
					If Not IsFunc($fnValidation) Or $fnValidation($hGUI, $oRet, $oCtrlIDs, $oLabelsIDs, $vUserData) Then
						GUIDelete($hGUI)
						Opt("GUICloseOnEsc", $vTmp)
						Return $oRet
					EndIf
			EndSwitch
		EndIf
	WEnd
EndFunc

; -------------------------------------------------------------------------------------------------
; internals

Func __advInputBox_stringSize($sText, $aFont = Null, $iMaxWidth = 0)
	Local $aRet
	If IsArray($aFont) And UBound($aFont) == 4 Then
		$aRet = _StringSize($sText, Number($aFont[0]), Number($aFont[1]), Number($aFont[2]), String($aFont[3]), Number($iMaxWidth))
	Else
		$aRet = _StringSize($sText, Default, Default, Default, Default, Number($iMaxWidth))
	EndIf
	Return SetError(@error, @extended, $aRet)
EndFunc

Func __advInputBox_objGet($oObj, $sKey, $vDefault = Null)
	$sKey = String($sKey)
	If Not IsObj($oObj) Or Not $oObj.Exists($sKey) Then Return $vDefault
	Return $oObj.Item($sKey)
EndFunc
