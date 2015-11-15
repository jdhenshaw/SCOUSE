;+
;
; PROGRAM NAME:
;   FIT RSAA
;
; PURPOSE:
;   Fitting the spatially averaged spectra. User-interactive. The user has to
;   provide parameter estimates. Process will repeat until user is happy with
;   the best-fitting solution.
;   
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-

FUNCTION FIT_SAA, x, x_rms, y, y_rms, err_y, $
                  rms_window_val, xpos, ypos, n, $
                  temp_file, ResArr=ResArr
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
                                param_estimates, $
                                ResArr=ResArr )                                                             

    SolnArr[*,15] = rms_window_val[0]
    SolnArr[*,16] = rms_window_val[1]
                                                                 
  ENDIF ELSE BEGIN

    SolnArr = [[n],$
               [xpos],[ypos],$
               [param_estimates[0]],[0.0],$
               [param_estimates[1]],[0.0],$
               [param_estimates[2]],[0.0],$
               [err_y[0]],[stddev(y_rms)],$
               [1000.0],[n_elements(x)-3.0],[1000.0],[1000.0],$               
               [rms_window_val[0]], [rms_window_val[1]]]

    ResArr = y
    
  ENDELSE
  
  ; Print out some useful information
  
  print, ' '
  print, 'Reduced chi-Squared value: ', SolnArr[0,13]
  print, 'AIC value: ', SolnArr[0,14]
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
  
  ; Overplot the solution 
  
  plot_soln = OVERPLOT_SOLUTION_SAA( x, y, SolnArr, ResArr, windowpos )
  
  ; Ask the user if they are happy with the current solution
  
  happy = ''
  PRINT, ''
  READ, happy, prompt = 'Happy? (yes/no): '
ENDWHILE

;------------------------------------------------------------------------------;
RETURN, SolnArr

END
