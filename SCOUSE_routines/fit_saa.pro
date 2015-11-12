FUNCTION FIT_SAA, y, y_rms, x, x_rms, err_y, rms_window_val, $
                  xpos, ypos, n, temp_file, ResArr=ResArr
;------------------------------------------------------------------------------;
; PROGRAM NAME:
;   FIT RSAA
;
; PURPOSE:
;   Fitting the spatially averaged spectra
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;------------------------------------------------------------------------------;
Compile_Opt idl2
;------------------------------------------------------------------------------;
; GAUSSIAN FITTING                                                                                                                    
;------------------------------------------------------------------------------;

happy = 'no'

WHILE happy NE 'yes' DO BEGIN
  
  windowpos = PREPARE_PLOT_PAGE( x, y, xpos, ypos, err_y[0] ) 
  
  ; Begin user-interactive fitting procedure
  
  param_estimates = ENTER_PARAM_ESTIMATES( x, y, xpos, ypos, err_y[0], n = n )

  IF n NE 0.0 THEN BEGIN
    SolnArr = FIT_SPECTRUM_SAA( x, y, err_y, xpos, ypos, $
                                n, param_estimates, $
                                ResArr=ResArr )                                                             
    
    SolnArr[*,12] = rms_window_val[0]
    SolnArr[*,13] = rms_window_val[1]
                                                                 
  ENDIF ELSE BEGIN

    SolnArr = [[n],$
               [xpos],[ypos],$
               [param_estimates[0]],[0.0],$
               [param_estimates[1]],[0.0],$
               [param_estimates[2]],[0.0],$
               [err_y[0]],[1000.0],[stddev(y_rms)],$
               [rms_window_val[0]], [rms_window_val[1]]]

    resarray = y
    
  ENDELSE
  
  print, ' '
  print, 'Reduced chi-Squared value: ', SolnArr[0,10]
  print, ' '

  ; Print out the result of the individual fits

  FOR i = 0, n-1 DO BEGIN
    PRINT, ''
    PRINT, 'Intensity: ', STRING(SolnArr[i,3], format = '(F10.3)'), ' +/-', $
                          STRING(SolnArr[i,4], format = '(F10.3)')
    PRINT, 'Centroid:  ', STRING(SolnArr[i,5], format = '(F10.3)'), ' +/-', $
                          STRING(SolnArr[i,6], format = '(F10.3)')
    PRINT, 'Linewidth: ', STRING(SolnArr[i,7], format = '(F10.3)'),' +/-', $
                          STRING(SolnArr[i,8], format = '(F10.3)')
    PRINT, ''
  ENDFOR
  
  plot_soln = OVERPLOT_SOLUTION_SAA( x, y, SolnArr, ResArr, windowpos )

  happy = ''
  PRINT, ''
  READ, happy, prompt = 'Happy? (yes/no): '
ENDWHILE

;------------------------------------------------------------------------------;
; END PROCESS
;------------------------------------------------------------------------------;
RETURN, SolnArr

END
