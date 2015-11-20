;+
;
; PROGRAM NAME:
;   FIT INDIV
;
; PURPOSE:
;   Fitting individual spectra associated with each SAA
;   
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-

FUNCTION FIT_AUTO, x, y, err_y, x_location, y_location, parameter_estimates_initial, Tolerances, residual_array=residual_array
Compile_Opt idl2

;------------------------------------------------------------------------------;
; FITTING
;------------------------------------------------------------------------------;

IF TOTAL(parameter_estimates_initial) EQ 0.0 THEN BEGIN  
  SolnArr = [[0.0],[x_location],[y_location],[0.0],[0.0],[0.0],[0.0],[0.0],[0.0],[err_y[0]],[STDDEV(y)],[1000.0],[n_elements(x)-3.0], [1000.0], [1000.0]]
  residual_array = y 
ENDIF ELSE BEGIN    
  parameter_estimates = parameter_estimates_initial  
  WHILE TOTAL(parameter_estimates) NE 0.0 DO BEGIN    
    SolnArr             = 0.0    
    parameter_estimates = parameter_estimates[WHERE(parameter_estimates NE 0.0)]
    parameter_estimates = FLOAT(ROUND(parameter_estimates*1000.0)/1000.0)   
    SolnArr             = FIT_SPECTRUM( x, y, err_y, x_location, y_location, parameter_estimates, residual_array=residual_array, result=result ) 
                                
    parameter_estimates = result
    parameter_estimates = CONDITIONS( parameter_estimates, SolnArr, parameter_estimates_initial, Tolerances )

    ; If none of the components satisfy the conditions then no solution has 
    ; been found. If the components satisfy the conditions, retain the current
    ; SolnArr. If some but not all satisfy the conditions, the while loop will
    ; continue until either none or all conditions are accepted. 

    IF TOTAL(parameter_estimates) EQ 0.0 THEN BEGIN
      SolnArr = [[0.0],[SolnArr[0,1]],[SolnArr[0,2]],[0.0],[0.0],[0.0],[0.0],[0.0],[0.0],[SolnArr[0,9]],[SolnArr[0,10]],[1000.0],[SolnArr[0,12]], [1000.0], [1000.0]]                
    ENDIF ELSE BEGIN
      IF (N_ELEMENTS(SolnArr[*,0]) EQ N_ELEMENTS(parameter_estimates)/3) THEN parameter_estimates = 0.0    
    ENDELSE
  ENDWHILE
ENDELSE

;-----------------------------------------------------------------------------;
RETURN, SolnArr

END