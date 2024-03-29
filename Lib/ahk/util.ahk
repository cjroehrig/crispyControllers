; Utility Functions

;===============================================================================
; General Utility Functions

LineLength := 80			; for dump output
DbgTimestamp := true
DbgStartTime := A_TickCount	

;=======================================
Dbg(fmt, args*)
; Format and print fmt to stdout with a newline and timestamp.
{
	global DbgTimestamp, DbgStartTime
	if ( DbgTimestamp ) {
		ts := Format("{:9.3f}: ", (A_TickCount-DbgStartTime) / 1000.0)
		fmt := ts . fmt
	}
	Dbgn(fmt . "`n", args*)
}

;=======================================
Dbgnt(fmt, args*)
; Format and print fmt to stdout with a newline and no timestamp.
{
	Dbgn(fmt . "`n", args*)
}

;=======================================
Dbgn(fmt, args*)
; Format and print fmt to stdout with no newline or timestamp.
{
	str := Format(fmt, args*)
	FileAppend %str%, *
}
;=======================================
IsPrefix(prefix, fullstr)
; Returns true if fullstr begins with prefix; false otherwise
{
	if ( SubStr(fullstr, 1, StrLen(prefix))  == prefix ) {
		return true
	} else {
		return false
	}
}

;=======================================
Sleep(ms)
; Sleep for ms milliseconds
{
	Sleep, %ms%
}

;=======================================
IndexOf(arr, val)
; Returns the index (offset 1) of 'val' in array 'arr',
; or false if it doesn't exist. 
{
	for i, v in arr {
		if ( v == val ) { 
			return i
		}
	}
	return false
}

;=======================================
IsArray(var)
;  Returns true if var is an array.
;  NB: traverses the array -- use sparingly.
{
	if ( !IsObject(var) ){
		return false
	}
	i := 1
	for key, v in var {
		if ( key != i ) {
			return false
		}
		i++
	} 
	return true
}

;=======================================
IsInteger(var)
;  Returns true if var is a (decimal) integer
{
	if var is integer
		return true
	else
		return false
}

;=======================================
ExpandHotKey(str)
; Expands str into a string that can be used in SendWin().
; str is a value of A_ThisHotKey.
{
	base := ""
	mods := ""
	i := 1
	while ( i <= StrLen(str) ) {
		c := SubStr(str,i,1)
		if ( c == "!" || c == "#" || c == "^" || c == "+" ) {
			; collect modifiers
			mods .= c
		} else if ( c != "$" && c != "*" && c != "~" ) {
			; collect base key name (skip/ignore meta chars $ * ~)
			base .= c
		}
		i++
	}
	return mods . "{" . base . "}"
	;return ExpandKeys(mods . "{" . base . "}")
}

;=======================================
ExpandKeys(str)
; Expands str into a string that can be used in SendWin()
; The following expansions are done:
;     ^x		-> {Ctrl down}x{Ctrl up}
;     +x		-> {Shift down}x{Shift up}
;     !x		-> {Alt down}x{Alt up}
; Here x can be any ordinary letter, any string enclosed in {}, 
; and may be itself be preceded by any combination of ^+! which
; will then get expanded.
{
	out := ""
	modstack := []
	in_braces := false

	i := 1
	while ( i <= StrLen(str) ) {
		c := SubStr(str,i,1)
		if ( in_braces ) {
			out .= c
			if ( c == "}" ) {
				in_braces := false
				out .= _close_modstack(modstack)
			}
		} else {
			if ( c == "+" ) {
				out .= "{Shift down}"
				modstack.Push( "+" )
			} else if ( c == "^" ) {
				out .= "{Ctrl down}"
				modstack.Push( "^" )
			} else if ( c == "!" ) {
				out .= "{Alt down}"
				modstack.Push( "!" )
			} else if ( c == "{" ) {
				out .= c
				in_braces := true
			} else {
				; ordinary char
				out .= c
				; close any modifiers
				out .= _close_modstack(modstack)
			}
		}
		i++
	}
	; this will only happen if a string ends in a modifier
	out .= _close_modstack(modstack)

	return out
}

_close_modstack(modstack)
{
	out := ""
	while ( modstack.Length() ) {
		c := modstack.Pop()
		if ( c == "+" ) {
			out .= "{Shift up}"
		} else if ( c == "^" ) {
			out .= "{Ctrl up}"
		} else if ( c == "!" ) {
			out .= "{Alt up}"
		} else {
			Dbg("INTERNAL: bad modstack value: {}", c)
		}
	}
	return out
}

;==============================================================================
;  Dump

;=======================================
IndentStr(indent:=0)
; Return a string of spaces for indent level 'indent'
{
	str := ""
	while ( indent > 0 ){
		str .= "  "		; 2 spaces per indent
		indent--
	}
	return str
}

;=======================================
Dump(var, indent:=0)
;  Dumps 'var' using Dbgnt with indent.
{
	ind := IndentStr(indent)
	if ( IsObject(var) ){
		Dbgnt("{")
		for key, val in var {
			Dbgn( ind . "[{}] = ", key )
			Dump(val, indent+1)
		}
		Dbgnt(ind . "}")
	} else {
		if var is number 
			Dbgnt("{}" , var)
		else
			Dbgnt("'{}'" , var)
	}

}

;=======================================
StrObjNames(objlist)
; Return the list of the names (obj.name) of objects in objlist, 
; in string form.
{
	if ( not objlist ){
		str := "0"
	} else {
		str := "["
		first := true
		for i, obj in objlist {
			if ( first ){
				first := false
			} else {
				str .= ", "
			}
			str .= """" . obj.name . """"
		}
		str .= "]"
	}
	return str
}

;=======================================
Repr(var, indent:=0, col:=0)
;  Returns a compact string representation of var,
;  at 'indent' indent level, assuming it starts at column 'col'.
;  If it is longer than LineLength, it will be multi-line.
{
	global LineLength
	str := ""
	isarr := IsArray(var)
	if ( IsObject(var) ){
		str .= isarr ? "[" : "{"
		first := true
		for key, val in var {
			if (first){
				first := false
			} else {
				str .= ", "
			}
			; recurse
			valstr := Repr(val)
			if ( isarr ) {
				str .= Format("{}", valstr)
			} else {
				str .= Format("{}:{}", key, valstr)
			}
		}
		str .= isarr ? "]" : "}"
	} else {
		if var is number
			str .= Format("{}", var)
		else
			str .= Format("""{}""", var)
	}
	return str
}

