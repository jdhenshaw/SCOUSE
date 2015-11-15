;+
;
; PROGRAM NAME:
;   CONDITION FWHM
;
; PURPOSE:
;   Check the current solution against the user defined tolerance level 
;   DVTOLRES and DVTOLDIFF
;
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-

FUNCTION CONDITION_FWHM, param_estimates,SolnArr,SaaSoln,tolerances,conditional_array
Compile_Opt idl2

;------------------------------------------------------------------------------;
;
;------------------------------------------------------------------------------;

n       = N_ELEMENTS(param_estimates)/3
nSAA    = N_ELEMENTS(SaaSoln[*,0])

DiffArr = REPLICATE(0.0, nSAA)

FOR i = 0, n-1 DO BEGIN 
  FOR j = 0, nSAA-1 DO BEGIN
    DiffArr[j] = SQRT( ((SaaSoln[j,3]-SolnArr[i,3])^2.0) + $
                       ((SaaSoln[j,5]-SolnArr[i,5])^2.0) + $
                       ((SaaSoln[j,7]-SolnArr[i,7])^2.0) )
  ENDFOR
  
  ; The closest matching component is the one with the smallest difference in 
  ; parameters
  
  ID_minimum = WHERE(DiffArr EQ MIN(DiffArr))

  ; Now check to see if the components satisfy the conditions
  
  IF (SolnArr[i,7] GT Tolerances[1]*Tolerances[5]) AND $
     (SolnArr[i,7] LT Tolerances[2]*SaaSoln[ID_minimum[0],7]) THEN BEGIN

    param_estimates[(i*3)]   = param_estimates[(i*3)]
    param_estimates[(i*3)+1] = param_estimates[(i*3)+1]
    param_estimates[(i*3)+2] = param_estimates[(i*3)+2]

  ENDIF ELSE BEGIN

    param_estimates[(i*3)]   = 0.0
    param_estimates[(i*3)+1] = 0.0
    param_estimates[(i*3)+2] = 0.0

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
  ; based condition
  conditional_array[1] = 0.0
ENDELSE

;------------------------------------------------------------------------------;
RETURN, conditional_array

END
