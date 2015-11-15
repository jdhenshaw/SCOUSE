;+
;
; PROGRAM NAME:
;   CONDITION RMS
;
; PURPOSE:
;   Check the current solution against the user defined tolerance level ITOL
;
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-

FUNCTION CONDITION_RMS, param_estimates,SolnArr,tolerances,conditional_array
Compile_Opt idl2

;-----------------------------------------------------------------------------;
;
;-----------------------------------------------------------------------------;

FOR i = 0, (N_ELEMENTS(param_estimates)/3)-1 DO BEGIN
  IF SolnArr[i,3] LT Tolerances[0]*SolnArr[i,9] OR $
     SolnArr[i,3] LT SolnArr[i,4] THEN BEGIN
    param_estimates[(i*3)]   = 0.0
    param_estimates[(i*3)+1] = 0.0
    param_estimates[(i*3)+2] = 0.0
  ENDIF ELSE BEGIN
    param_estimates[(i*3)]   = param_estimates[(i*3)]
    param_estimates[(i*3)+1] = param_estimates[(i*3)+1]
    param_estimates[(i*3)+2] = param_estimates[(i*3)+2]
  ENDELSE
ENDFOR

ID_REJECT = WHERE(param_estimates EQ 0.0, c)

IF (c NE 0.0) THEN BEGIN
  IF TOTAL(param_estimates) EQ 0.0 THEN BEGIN
    ; if no values satisfy the condition - reject completely
    conditional_array = -1.0
  ENDIF ELSE BEGIN
    ; if some values satisfy, but others do not, remove those that violate the
    ; condition
    param_estimates = param_estimates[WHERE(param_estimates ne 0.0)]
  ENDELSE
ENDIF ELSE BEGIN
  ; Otherwise continue
  conditional_array[0] = 0.0
ENDELSE

;-----------------------------------------------------------------------------;
RETURN, conditional_array

END