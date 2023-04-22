; numerical functions

;===============================================================================
;=======================================
NextPermutation(a, cmp:=false)
;  Update array a to its next lexicographic permutation.
;  Return false if there is none (and a will be reset to the 
;  first lexicographic permutation); true otherwise.
;  If cmp is not provided, then a must contain elements that 
;  can be compared lexographically with <, >.
;  If cmp is provided, it is used as the lexicographic compare function
;  (see CmpScalar below for an example).
; 
{
	n := a.Length()
	if ( n <= 1 ) {
		return false
	}

	if (!cmp) {
		cmp := Func("CmpScalar")
	}

	i := n-1
	;while ( i > 0 and a[i] > a[i+1] ){
	while ( i > 0 and %cmp%(a[i],a[i+1]) > 0 ){
		i -= 1
	}
	Reverse(a, i+1, n)
	if ( i == 0 ){
		ret := false
	} else {
		j := i + 1
		;while ( a[j] < a[i] ){
		while ( %cmp%(a[j],a[i]) < 0 ){
			j += 1
		}
		Swap(a, i, j)
		ret := true
	}
	return ret
}

;=======================================
Swap(a, i, j)
; Swap elements i & j within array a.
{
	tmp := a[i]
	a[i] := a[j]
	a[j] := tmp
}

;=======================================
Reverse(a, i, j)
; Reverse the part of array a between indexes i and j (inclusive).
{
	while (i < j) {
		Swap(a, i, j)
		i += 1
		j -= 1
	}
}

;========================================
CmpScalar(a, b)
; Compare two scalars.
{
	if ( a > b) {
		return 1
	} else if ( a < b ) {
		return -1
	} else if ( a == b ) {
		return 0
	}
	Dbg("INTERNAL:CmpScalar({},{}) does not compare!", a, b)
}
;========================================
CmpObject(a, b)
; Compare two objects lexicographically by name (i.e. a.name).
{
	if ( a.name > b.name ) {
		return 1
	} else if ( a.name < b.name ) {
		return -1
	} else if ( a.name == b.name ) {
		return 0
	}
	Dbg("INTERNAL:CmpObject({},{}) does not compare!", a.name, b.name)
}

