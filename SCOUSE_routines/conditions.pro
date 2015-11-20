;+
;
; PROGRAM NAME:
;   PRIMARY CONDITIONS
;
; PURPOSE:
;   This program tests the current best-fitting solution against various 
;   conditions, the tolerance levels of which are supplied by the user. 
;
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-

FUNCTION CONDITIONS, parameter_estimates, SolnArr, parameter_estimates_initial, tolerances
Compile_Opt idl2

;------------------------------------------------------------------------------;
; TESTING CONDITIONS
;------------------------------------------------------------------------------;

; The first three conditions involve the peak, width, and location of the new
; best fitting solutions. Whether or not each component satisfies these 
; conditions is controlled by a number of tolerance levels. 

conditional_array = REPLICATE(1d0, 3); Create a conditional array
conditional_array = CONDITION_RMS(parameter_estimates, SolnArr, tolerances, conditional_array) ; FIRST CONDITION                                                           
IF conditional_array[0] NE -1.0 THEN BEGIN
  IF conditional_array[0] EQ 0.0 THEN BEGIN 
    conditional_array = CONDITION_FWHM( parameter_estimates, SolnArr, parameter_estimates_initial, tolerances, conditional_array ) ; SECOND CONDITION                                                                
    IF conditional_array[0] NE -1.0 THEN BEGIN
      IF conditional_array[1] EQ 0.0 THEN BEGIN
        conditional_array = CONDITION_VELOLOC(parameter_estimates, SolnArr, parameter_estimates_initial, tolerances, conditional_array) ; THIRD CONDITION                                                            
      ENDIF
    ENDIF
  ENDIF
ENDIF

; The final condition is implemented if there are multiple spectral components
; identified. 

IF TOTAL(parameter_estimates) EQ 0.0 THEN parameter_estimates = 0.0
IF TOTAL(conditional_array) EQ 0.0 AND N_ELEMENTS(parameter_estimates)/3 GT 1 THEN BEGIN
   parameter_estimates = CONDITION_VELDIFF( parameter_estimates, SolnArr, tolerances ) ; FOURTH CONDITION
ENDIF 

;------------------------------------------------------------------------------;
RETURN, parameter_estimates

END