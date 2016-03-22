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

FUNCTION CONDITION_FWHM, parameter_estimates, SolnArr, parameter_estimates_initial, tolerances, conditional_array
Compile_Opt idl2

;------------------------------------------------------------------------------;
;
;------------------------------------------------------------------------------;

n       = N_ELEMENTS(parameter_estimates)/3
nSAA    = N_ELEMENTS(parameter_estimates_initial)/3

FOR i = 0, n-1 DO BEGIN 
  
  DiffArr = REPLICATE(0.0, nSAA)
  
  FOR j = 0, nSAA-1 DO BEGIN
    DiffArr[j] = SQRT( ((parameter_estimates_initial[(j*3.0)]-SolnArr[i,3])^2.0) + $
                       ((parameter_estimates_initial[(j*3.0)+1.0]-SolnArr[i,5])^2.0) + $
                       (((parameter_estimates_initial[(j*3.0)+2.0]*(2.0*SQRT(2.0*ALOG(2.0))))-SolnArr[i,7])^2.0) )
  ENDFOR
  
  ; The closest matching component is the one with the smallest difference in 
  ; parameters
  
  ID_minimum = WHERE(DiffArr EQ MIN(DiffArr))

  ; Now check to see if the components satisfy the conditions

  IF SolnArr[i,7] GT (parameter_estimates_initial[(ID_minimum[0]*3.0)+2.0]*(2.0*SQRT(2.0*ALOG(2.0)))) THEN $
     FWHMDIFF=(SolnArr[i,7]/(parameter_estimates_initial[(ID_minimum[0]*3.0)+2.0]*(2.0*SQRT(2.0*ALOG(2.0))))) ELSE $
     FWHMDIFF=((parameter_estimates_initial[(ID_minimum[0]*3.0)+2.0]*(2.0*SQRT(2.0*ALOG(2.0))) )/SolnArr[i,7])
  
  
  IF (SolnArr[i,7] GT Tolerances[1]*Tolerances[5]) AND (FWHMDIFF LT Tolerances[2]) THEN BEGIN

    parameter_estimates[(i*3)]   = parameter_estimates[(i*3)]
    parameter_estimates[(i*3)+1] = parameter_estimates[(i*3)+1]
    parameter_estimates[(i*3)+2] = parameter_estimates[(i*3)+2]

  ENDIF ELSE BEGIN

    parameter_estimates[(i*3)]   = 0.0
    parameter_estimates[(i*3)+1] = 0.0
    parameter_estimates[(i*3)+2] = 0.0

  ENDELSE
ENDFOR

ID_REJECT = WHERE(parameter_estimates EQ 0.0, c)

IF (c NE 0.0) THEN BEGIN
  IF TOTAL(parameter_estimates) EQ 0.0 THEN BEGIN
    conditional_array = -1.0
  ENDIF ELSE BEGIN
    parameter_estimates = parameter_estimates[WHERE(parameter_estimates NE 0.0)]
  ENDELSE
ENDIF ELSE BEGIN
  conditional_array[1] = 0.0
ENDELSE

;------------------------------------------------------------------------------;
RETURN, conditional_array

END
