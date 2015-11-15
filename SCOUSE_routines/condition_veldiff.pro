;+
;
; PROGRAM NAME:
;   CONDITION VELDIFF
;
; PURPOSE:
;   Check the current solution against the user defined tolerance level VELDIFF
;
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-

FUNCTION CONDITION_VELDIFF, param_estimates,SolnArr,SaaSoln,tolerances
Compile_Opt idl2

;-----------------------------------------------------------------------------;
;
;-----------------------------------------------------------------------------;

n          = N_ELEMENTS(param_estimates)/3
param_temp = replicate(0.0, n)
DiffArr    = replicate(0.0, n)


FOR i = 0, n-1 DO BEGIN
  
  IF param_temp[i] ne -1.0 THEN BEGIN
    
    FOR j = 0, n-1 DO BEGIN 
      DiffArr[j] = abs(SolnArr[i,5]-SolnArr[j,5])     
    ENDFOR
    
    ; Where the diffarr = 0.0 set to 1000.0
    DiffArr[where(DiffArr eq 0.0)] = 1000.0 
    
    ; Find the index of the minimum
    ID_minimum = WHERE(DiffArr EQ MIN(DiffArr))
    
    ; Create an array of the FWHM line width of the current component and 
    ; the most closely related (in velocity)
    
    FWHMarr = [SolnArr[i,7], SolnArr[ID_minimum[0],7]] 
    
    IF (ABS(SolnArr[i,5]-SolnArr[ID_minimum[0],5]) GT Tolerances[4]*MIN(FWHMarr)) THEN BEGIN
      
      IF param_temp[ID_minimum[0]] NE -1 THEN BEGIN
        
        param_temp[i] = 0.0
        param_temp[ID_minimum[0]] = 0.0
        
        param_estimates[(i*3)]   = param_estimates[(i*3)]
        param_estimates[(i*3)+1] = param_estimates[(i*3)+1]
        param_estimates[(i*3)+2] = param_estimates[(i*3)+2]
        
        param_estimates[(ID_minimum[0]*3)]   = param_estimates[(ID_minimum[0]*3)]
        param_estimates[(ID_minimum[0]*3)+1] = param_estimates[(ID_minimum[0]*3)+1]
        param_estimates[(ID_minimum[0]*3)+2] = param_estimates[(ID_minimum[0]*3)+2]
        
      ENDIF ELSE BEGIN
        
        param_temp[i] = 0.0
        param_temp[ID_minimum[0]] = -1.0
        
        param_estimates[(i*3)]   = param_estimates[(i*3)]
        param_estimates[(i*3)+1] = param_estimates[(i*3)+1]
        param_estimates[(i*3)+2] = param_estimates[(i*3)+2]
        
        param_estimates[(ID_minimum[0]*3)]   = 0.0
        param_estimates[(ID_minimum[0]*3)+1] = 0.0
        param_estimates[(ID_minimum[0]*3)+2] = 0.0
        
      ENDELSE
          
    ENDIF ELSE BEGIN
      
      param_temp[i] = 0.0
      param_temp[ID_minimum[0]] = -1.0

      param_estimates[(i*3)]   = MEAN([SaaSoln[i,3],SaaSoln[ID_minimum[0],3]])
      param_estimates[(i*3)+1] = MEAN([SaaSoln[i,5],SaaSoln[ID_minimum[0],5]])
      param_estimates[(i*3)+2] = MEAN([SaaSoln[i,7],SaaSoln[ID_minimum[0],7]])

      param_estimates[(ID_minimum[0]*3)]   = 0.0
      param_estimates[(ID_minimum[0]*3)+1] = 0.0
      param_estimates[(ID_minimum[0]*3)+2] = 0.0

    ENDELSE
  ENDIF
ENDFOR

ID_REJECT = WHERE(param_estimates EQ 0.0, c)

IF (c NE 0.0) AND TOTAL(param_estimates) NE 0.0 THEN BEGIN
  param_estimates = param_estimates[WHERE(param_estimates ne 0.0)]
ENDIF

;------------------------------------------------------------------------------;
RETURN, param_estimates

END