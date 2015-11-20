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

FUNCTION CONDITION_RMS, parameter_estimates, SolnArr, tolerances, conditional_array
Compile_Opt idl2

;-----------------------------------------------------------------------------;
;
;-----------------------------------------------------------------------------;

FOR i = 0, (N_ELEMENTS(parameter_estimates)/3)-1 DO BEGIN
  IF SolnArr[i,3] LT Tolerances[0]*SolnArr[i,9] OR SolnArr[i,3] LT Tolerances[0]*SolnArr[i,4] THEN BEGIN
    parameter_estimates[(i*3)]   = 0.0
    parameter_estimates[(i*3)+1] = 0.0
    parameter_estimates[(i*3)+2] = 0.0
  ENDIF ELSE BEGIN
    parameter_estimates[(i*3)]   = parameter_estimates[(i*3)]
    parameter_estimates[(i*3)+1] = parameter_estimates[(i*3)+1]
    parameter_estimates[(i*3)+2] = parameter_estimates[(i*3)+2]
  ENDELSE
ENDFOR

ID_REJECT = WHERE(parameter_estimates EQ 0.0, c)

IF (c NE 0.0) THEN BEGIN
  IF TOTAL(parameter_estimates) EQ 0.0 THEN BEGIN
    conditional_array = -1.0
  ENDIF ELSE BEGIN
    parameter_estimates = parameter_estimates[WHERE(parameter_estimates ne 0.0)]
  ENDELSE
ENDIF ELSE BEGIN
  conditional_array[0] = 0.0
ENDELSE

;-----------------------------------------------------------------------------;
RETURN, conditional_array

END