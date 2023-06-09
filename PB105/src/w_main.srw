$PBExportHeader$w_main.srw
forward
global type w_main from window
end type
type cb_library from commandbutton within w_main
end type
type cb_1 from commandbutton within w_main
end type
type dw_columns from datawindow within w_main
end type
type dw_datawindows from datawindow within w_main
end type
type st_text from statictext within w_main
end type
end forward

global type w_main from window
integer width = 2158
integer height = 1840
boolean titlebar = true
string title = "DataWindow Column Width Checker"
boolean controlmenu = true
boolean minbox = true
boolean maxbox = true
boolean resizable = true
long backcolor = 67108864
string icon = "AppIcon!"
boolean center = true
cb_library cb_library
cb_1 cb_1
dw_columns dw_columns
dw_datawindows dw_datawindows
st_text st_text
end type
global w_main w_main

type prototypes
Protected:

Function ULong GetDC(ULong hWnd) Library "USER32.DLL"
Function Long ReleaseDC(ULong hWnd, ULong hdcr) Library "USER32.DLL"
Function ULong SelectObject(ULong hdc, ULong hWnd) Library "GDI32.DLL"
Function Boolean GetTextExtentPoint32A(ULong hdcr, String lpString, Long nCount, Ref str_size size) Library "GDI32.DLL" Alias For "GetTextExtentPoint32A;Ansi"


end prototypes

type variables
protected:

string	is_libraryname

end variables

forward prototypes
protected function integer of_getdatawindows ()
protected function integer of_getcolumns (string as_datawindowname)
protected function integer of_getcolumnwidth (string as_fontname, integer ai_len, integer ai_fontsize, integer ai_weight, boolean ab_italic, boolean ab_underline)
end prototypes

protected function integer of_getdatawindows ();//====================================================================
// Function: w_main.of_getdatawindows()
//--------------------------------------------------------------------
// Description:
//--------------------------------------------------------------------
// Arguments:
//--------------------------------------------------------------------
// Returns:  integer
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2023/03/12
//--------------------------------------------------------------------
// Usage: w_main.of_getdatawindows ( )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

String	ls_filename, ls_datawindows

If GetFileOpenName ( "Select a PBL", is_libraryname, ls_filename, 'PBL', 'PowerBuilder Library (*.pbl),*.pbl;PowerBuilder Dynamic Library (*.pbd),*.pbd;All files (*.*),*.*' ) < 1 Then Return -1

dw_datawindows.Reset()
dw_columns.Reset()
ls_datawindows = LibraryDirectory ( is_libraryname, DirDataWindow! )
dw_datawindows.ImportString ( ls_datawindows )

Return 1

end function

protected function integer of_getcolumns (string as_datawindowname);//====================================================================
// Function: w_main.of_getcolumns()
//--------------------------------------------------------------------
// Description:
//--------------------------------------------------------------------
// Arguments:
// 	string	as_datawindowname	
//--------------------------------------------------------------------
// Returns:  integer
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2023/03/12
//--------------------------------------------------------------------
// Usage: w_main.of_getcolumns ( string as_datawindowname )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

Boolean		lb_underline, lb_italic
Integer		li_index, li_count, li_fontsize, li_fontweight
Integer		li_actualwidth, li_desiredwidth, li_row, li_len
String		ls_syntax, ls_errors, ls_columnname, ls_fontname, ls_datatype
datastore	lds_temp

ls_syntax = LibraryExport ( is_libraryname, as_datawindowname, ExportDataWindow! )

dw_columns.Reset()

lds_temp = Create datastore
lds_temp.Create ( ls_syntax, ls_errors )

If lds_temp.Object.DataWindow.Units <> '0' Then
	MessageBox ( "Warning", "This utility only works for DataWindows that are stored in PBU Units" )
End If

li_count = Integer ( lds_temp.Object.DataWindow.Column.Count )
For li_index = 1 To li_count
	//Get column info
	ls_columnname = lds_temp.Describe ( '#' + String ( li_index ) + '.name' )
	ls_fontname = lds_temp.Describe ( '#' + String ( li_index ) + '.Font.Face'	)
	If ls_fontname = '!' Then Continue //Not shown on datawindow
	ls_datatype = lds_temp.Describe ( '#' + String ( li_index ) + '.Coltype' )
	If Left ( Lower ( ls_datatype ), 4 ) <> 'char' Then Continue //Not a string datatype
	li_len = Integer ( Mid ( ls_datatype, 6, Len ( ls_datatype ) - 6 ) )
	li_fontsize = Integer ( lds_temp.Describe ( '#' + String ( li_index ) + '.Font.Height'	) )
	li_fontweight = Integer ( lds_temp.Describe ( '#' + String ( li_index ) + '.Font.Weight' ) )
	lb_italic = ( Lower ( lds_temp.Describe ( '#' + String ( li_index ) + '.Font.Italic' ) ) = 'yes' )
	lb_underline = ( Lower ( lds_temp.Describe ( '#' + String ( li_index ) + '.Font.Underline' ) ) = 'yes' )
	li_actualwidth = Integer ( lds_temp.Describe ( '#' + String ( li_index ) + '.Width' ) )
	li_desiredwidth = PixelsToUnits ( of_getcolumnwidth( ls_fontname, li_len, li_fontsize, li_fontweight, lb_italic, lb_underline ), XPixelsToUnits! )
	//Add it to the datawindow
	li_row = dw_columns.InsertRow ( 0 )
	dw_columns.Object.columnname[li_row] = ls_columnname
	dw_columns.Object.actualwidth[li_row] = li_actualwidth
	dw_columns.Object.desiredwidth[li_row] = li_desiredwidth
Next

Destroy lds_temp

Return 1

end function

protected function integer of_getcolumnwidth (string as_fontname, integer ai_len, integer ai_fontsize, integer ai_weight, boolean ab_italic, boolean ab_underline);//====================================================================
// Function: w_main.of_getcolumnwidth()
//--------------------------------------------------------------------
// Description:
//--------------------------------------------------------------------
// Arguments:
// 	string 	as_fontname 	
// 	integer	ai_len      	
// 	integer	ai_fontsize 	
// 	integer	ai_weight   	
// 	boolean	ab_italic   	
// 	boolean	ab_underline	
//--------------------------------------------------------------------
// Returns:  integer
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2023/03/12
//--------------------------------------------------------------------
// Usage: w_main.of_getcolumnwidth ( string as_fontname, integer ai_len, integer ai_fontsize, integer ai_weight, boolean ab_italic, boolean ab_underline )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

Constant	Integer WM_GETFONT = 49 //  hex 0x0031

String			ls_text
ULong          lul_Hdc, lul_Handle, lul_hFont
str_size       lstr_Size

st_text.FaceName = as_fontname
st_text.TextSize = -ai_FontSize
st_text.Weight = ai_weight
st_text.Italic = ab_Italic
st_text.Underline = ab_Underline

lul_Handle = Handle(st_text)
lul_Hdc    = GetDC(lul_Handle)

lul_hFont = Send(lul_Handle, WM_GETFONT, 0, 0)

SelectObject(lul_Hdc, lul_hFont)

//Let's use Ws, they're pretty wide
ls_text = Fill ( 'W', ai_len )

If Not GetTextExtentpoint32A(lul_Hdc, ls_text, ai_len, lstr_Size ) Then
	ReleaseDC(lul_Handle, lul_Hdc)
	Return -1
End If

ReleaseDC(lul_Handle, lul_Hdc)

Return lstr_Size.cx

end function

on w_main.create
this.cb_library=create cb_library
this.cb_1=create cb_1
this.dw_columns=create dw_columns
this.dw_datawindows=create dw_datawindows
this.st_text=create st_text
this.Control[]={this.cb_library,&
this.cb_1,&
this.dw_columns,&
this.dw_datawindows,&
this.st_text}
end on

on w_main.destroy
destroy(this.cb_library)
destroy(this.cb_1)
destroy(this.dw_columns)
destroy(this.dw_datawindows)
destroy(this.st_text)
end on

type cb_library from commandbutton within w_main
integer x = 1627
integer y = 792
integer width = 411
integer height = 112
integer taborder = 40
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Select Library"
end type

event clicked;of_getdatawindows()
end event

type cb_1 from commandbutton within w_main
integer x = 50
integer y = 788
integer width = 626
integer height = 112
integer taborder = 30
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Get With DataWindow"
end type

event clicked;Boolean		lb_underline, lb_italic
Integer		li_index, li_count, li_fontsize, li_fontweight
Integer		li_actualwidth, li_desiredwidth, li_row, li_len
String		ls_syntax, ls_errors, ls_columnname, ls_fontname, ls_datatype
datawindow	lds_temp

dw_columns.Reset()

lds_temp = dw_datawindows
//lds_temp.Create ( ls_syntax, ls_errors )

If lds_temp.Object.DataWindow.Units <> '0' Then
	MessageBox ( "Warning", "This utility only works for DataWindows that are stored in PBU Units" )
End If

li_count = Integer ( lds_temp.Object.DataWindow.Column.Count )
For li_index = 1 To li_count
	//Get column info
	ls_columnname = lds_temp.Describe ( '#' + String ( li_index ) + '.name' )
	ls_fontname = lds_temp.Describe ( '#' + String ( li_index ) + '.Font.Face'	)
	If ls_fontname = '!' Then Continue //Not shown on datawindow
	ls_datatype = lds_temp.Describe ( '#' + String ( li_index ) + '.Coltype' )
	If Left ( Lower ( ls_datatype ), 4 ) <> 'char' Then Continue //Not a string datatype
	li_len = Integer ( Mid ( ls_datatype, 6, Len ( ls_datatype ) - 6 ) )
	li_fontsize = Integer ( lds_temp.Describe ( '#' + String ( li_index ) + '.Font.Height'	) )
	li_fontweight = Integer ( lds_temp.Describe ( '#' + String ( li_index ) + '.Font.Weight' ) )
	lb_italic = ( Lower ( lds_temp.Describe ( '#' + String ( li_index ) + '.Font.Italic' ) ) = 'yes' )
	lb_underline = ( Lower ( lds_temp.Describe ( '#' + String ( li_index ) + '.Font.Underline' ) ) = 'yes' )
	li_actualwidth = Integer ( lds_temp.Describe ( '#' + String ( li_index ) + '.Width' ) )
	li_desiredwidth = PixelsToUnits ( of_getcolumnwidth( ls_fontname, li_len, li_fontsize, li_fontweight, lb_italic, lb_underline ), XPixelsToUnits! )
	//Add it to the datawindow
	li_row = dw_columns.InsertRow ( 0 )
	dw_columns.Object.columnname[li_row] = ls_columnname
	dw_columns.Object.actualwidth[li_row] = li_actualwidth
	dw_columns.Object.desiredwidth[li_row] = li_desiredwidth
Next

//Destroy lds_temp

Return 1

end event

type dw_columns from datawindow within w_main
integer x = 32
integer y = 944
integer width = 2048
integer height = 736
integer taborder = 10
string dataobject = "d_columns"
boolean hscrollbar = true
boolean vscrollbar = true
borderstyle borderstyle = stylelowered!
end type

type dw_datawindows from datawindow within w_main
integer x = 18
integer y = 16
integer width = 2048
integer height = 736
integer taborder = 10
string dataobject = "d_datawindows"
boolean hscrollbar = true
boolean vscrollbar = true
borderstyle borderstyle = stylelowered!
end type

event doubleclicked;string	ls_datawindowname

IF row > 0 THEN
	ls_datawindowname = this.object.datawindowname[row]
	of_getcolumns ( ls_datawindowname )
END IF
end event

type st_text from statictext within w_main
boolean visible = false
integer x = 2121
integer y = 240
integer width = 402
integer height = 64
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
boolean focusrectangle = false
end type

