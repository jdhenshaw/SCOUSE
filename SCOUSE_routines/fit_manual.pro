;+
;
; PROGRAM NAME:
;   FIT RSAA
;
; PURPOSE:
;   Manual fitting of a spectrum. User-interactive. The user must input the
;   parameter estimates. The process will repeat until user is happy with
;   the best-fitting solution.
;   
; CALLING SEQUENCE:
; 
;   solution = FIT_MANUAL( x_axis_trim, x_axis_fill, y_axis_trim, err_y_trim, $
;                          xposition, yposition )
;   
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-

FUNCTION FIT_MANUAL, x, x_rms, y, y_rms, err_y, x_location, y_location, residual_array=residual_array
Compile_Opt idl2

;------------------------------------------------------------------------------;
; GAUSSIAN FITTING                                                                                                                    
;------------------------------------------------------------------------------;

happy = 'no'
WHILE happy NE 'yes' DO BEGIN  
  windowpos        = PREPARE_PLOT_PAGE( x, y, x_location, y_location, err_y[0] ) 
  param_estimates  = ENTER_PARAM_ESTIMATES()
  IF TOTAL(param_estimates) NE 0.0 THEN BEGIN   
    SolnArr        = FIT_SPECTRUM( x, y, err_y, x_location, y_location, param_estimates, residual_array=residual_array, result=result )                                                                      
  ENDIF ELSE BEGIN
    SolnArr        = [[0],[x_location],[y_location],[param_estimates[0]],[0.0],[param_estimates[1]],[0.0],[param_estimates[2]],[0.0],[err_y[0]],[STDDEV(y_rms)],[1000.0],[N_ELEMENTS(x)-3.0],[1000.0],[1000.0]]
    residual_array = y     
  ENDELSE
  ; Print out some useful information 
  print, ' '
  print, 'Reduced chi-Squared value: ', SolnArr[0,13]
  print, 'AIC value:                 ', SolnArr[0,14]
  print, ' '
  ; Print out the result of the individual fits
  FOR i = 0, N_ELEMENTS(SolnArr[*,0])-1 DO BEGIN
    PRINT, ''
    PRINT, 'Intensity: ', STRING(SolnArr[i,3], format = '(F10.3)'), ' +/-', $
                          STRING(SolnArr[i,4], format = '(F10.3)')
    PRINT, 'Centroid:  ', STRING(SolnArr[i,5], format = '(F10.3)'), ' +/-', $
                          STRING(SolnArr[i,6], format = '(F10.3)')
    PRINT, 'Linewidth: ', STRING(SolnArr[i,7], format = '(F10.3)'),' +/-', $
                          STRING(SolnArr[i,8], format = '(F10.3)')
    PRINT, ''
  ENDFOR  
  OVERPLOT_SOLUTION, x, y, SolnArr, residual_array, windowpos  
  happy = ''
  PRINT, ''
  READ, happy, prompt = 'Happy? (yes/no): '
ENDWHILE

;------------------------------------------------------------------------------;
RETURN, SolnArr

END
