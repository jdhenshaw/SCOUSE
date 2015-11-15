;+
;
; PROGRAM NAME:
;   PRIMARY CONDITIONS
;
; PURPOSE:
;   This program tests the current best-fitting solution against three primary
;   conditions: RMS, FWHM, VELO LOC. See Henshaw+ 2015 for details
;
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-

FUNCTION CONDITIONS, param_estimates, SolnArr, SaaSoln, tolerances
Compile_Opt idl2

;------------------------------------------------------------------------------;
; TESTING CONDITIONS
;------------------------------------------------------------------------------;

; Create a conditional array 

conditional_array = REPLICATE(1.0, 3)

; FIRST CONDITION: 
; Test the rms of all components

conditional_array = CONDITION_RMS(param_estimates, SolnArr, tolerances, $
                                  conditional_array)
                                                               
IF conditional_array[0] NE -1.0 THEN BEGIN
  IF conditional_array[0] EQ 0.0 THEN BEGIN
    
    ; SECOND CONDITION:
    ; Test the FWHM of all components. Compare against the velocity resolution
    ; and how similar the new components are to the closest matching component
    ; in the SAA fit.
    
    conditional_array = CONDITION_FWHM( param_estimates, SolnArr, SaaSoln, $
                                        tolerances, conditional_array )                             
    IF conditional_array[0] NE -1.0 THEN BEGIN
      IF conditional_array[1] EQ 0.0 THEN BEGIN

        ; THIRD CONDITION:
        ; Test the velocity of all components. Compare against how similar the 
        ; new components are to the closest matching component in the SAA fit.
        
        conditional_array = CONDITION_VELOLOC(param_estimates, SolnArr, SaaSoln, $
                                              tolerances, conditional_array)                           
      ENDIF
    ENDIF
  ENDIF
ENDIF

; If no components satisfy the conditions then set the param estimates to 0.0.

IF TOTAL(param_estimates) EQ 0.0 THEN param_estimates = 0.0

; If all components satisfy the first three conditions, and there are multiple
; components, then impose the final conditional check. Else the fitting process
; is complete.

IF TOTAL(conditional_array) EQ 0.0 AND $
   N_ELEMENTS(param_estimates)/3 GT 1 THEN BEGIN
   param_estimates = CONDITION_VELDIFF( param_estimates, SolnArr, SaaSoln, $
                                        tolerances )
ENDIF 


;------------------------------------------------------------------------------;
RETURN, param_estimates

END