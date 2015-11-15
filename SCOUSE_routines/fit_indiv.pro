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

FUNCTION FIT_INDIV, x, y, err_y, xloc, yloc, SaaSoln, Tolerances, $
                    ResArr=ResArr
Compile_Opt idl2

;------------------------------------------------------------------------------;
; FITTING
;------------------------------------------------------------------------------;

IF SaaSoln[0,0] EQ 0.0 THEN BEGIN
  ; If no best-fitting solution is available for the SAA then populate SolnArr
  ; manually
  
  SolnArr = [[0.0],$
            [xloc],[yloc],$
            [0.0],[0.0],$
            [0.0],[0.0],$
            [0.0],[0.0],$
            [err_y[0]],$
            [STDDEV(y)],$
            [1000.0],[n_elements(x)-3.0], [1000.0], [1000.0]]

  ResArr = y
  
ENDIF ELSE BEGIN  
  ; Find best-fitting solution
  
  ; Create an initial parameter estimate array. If this is the first iteration
  ; the SAA solution will populate the array
  
  param_estimates = REPLICATE(0.0, N_ELEMENTS(SaaSoln[*,0])*3)
  
  FOR i = 0, N_ELEMENTS(SaaSoln[*,0])-1 DO BEGIN
    param_estimates[(i*3.0)]     = SaaSoln[i,3]
    param_estimates[(i*3.0)+1.0] = SaaSoln[i,5]
    param_estimates[(i*3.0)+2.0] = SaaSoln[i,7]
  ENDFOR
  
  ; Now begin the fitting process
  
  WHILE TOTAL(param_estimates) NE 0.0 DO BEGIN
    
    SolnArr = 0.0    
    param_estimates = param_estimates[WHERE(param_estimates NE 0.0)]
    
    ; Send parameter estimates to FIT_SPECTRUM_INDIV
    
    SolnArr = FIT_SPECTRUM_INDIV( x, y, err_y, xloc, yloc, $
                                  param_estimates, $
                                  ResArr=ResArr, result=result )
    
    ; Update the parameter estimate array to reflect the new fit result
                                  
    param_estimates = result
    
    ; Test the new best-fitting solutions against a number of conditions the
    ; tolerance levels of which are user-defined
    
    param_estimates = CONDITIONS( param_estimates, SolnArr, SaaSoln, Tolerances )

    ; If none of the components satisfy the conditions then no solution has 
    ; been found. If the components satisfy the conditions, retain the current
    ; SolnArr. If some but not all satisfy the conditions, the while loop will
    ; continue until either none or all conditions are accepted. 

    IF TOTAL(param_estimates) EQ 0.0 THEN BEGIN
      SolnArr = [[0.0],$
                 [SolnArr[0,1]],[SolnArr[0,2]],$
                 [0.0],[0.0],$
                 [0.0],[0.0],$
                 [0.0],[0.0],$
                 [SolnArr[0,9]],$
                 [SolnArr[0,10]],$
                 [1000.0],[SolnArr[0,12]], [1000.0], [1000.0]]
                 
    ENDIF ELSE BEGIN
      IF (N_ELEMENTS(SolnArr[*,0]) EQ N_ELEMENTS(param_estimates)/3) THEN $
          param_estimates = 0.0    
    ENDELSE
       
  ENDWHILE
ENDELSE


;-----------------------------------------------------------------------------;
RETURN, SolnArr

END