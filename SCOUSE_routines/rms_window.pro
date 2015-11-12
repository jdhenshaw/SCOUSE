FUNCTION RMS_WINDOW, x, y, n, xpos, ypos, temp_file, $
                     rms_window_val=rms_window_val
;------------------------------------------------------------------------------;
; PROGRAM NAME:
;   RMS WINDOW
;
; PURPOSE:
;   This program prompts the user to define the rms window
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;------------------------------------------------------------------------------;
Compile_Opt idl2
;------------------------------------------------------------------------------;

rms_window_val = REPLICATE(0.0, 2)

happy = 'no'
WHILE happy NE 'yes' DO BEGIN
  
  windowpos = PREPARE_PLOT_PAGE( x, y, xpos, ypos, 0.0 ) 

  ;-----------------------------------------------------------------------------;

  PRINT, ''
  PRINT, 'Define window for rms calculation...'
  PRINT, ''
  
  new_vals = ''
  READ, new_vals, prompt = 'Would you like to choose a new rms window? ' 
  PRINT, ''
  
  IF new_vals EQ 'yes' OR new_vals EQ 'y' OR new_vals EQ 'ys' THEN BEGIN
    
    OPENW, 1, temp_file
    READ, win, prompt = 'Enter lower window limit (km s-1): '
    rms_window_val[0] = win
    PRINTF,1,win
    READ, win, prompt = 'Enter upper window limit (km s-1): '
    rms_window_val[1] = win
    PRINTF,1,win
    CLOSE,1

    FOR i = 0, 1 DO BEGIN
      OPLOT, [rms_window_val[i],rms_window_val[i]], [MIN(y)-100, MAX(y)+100], $
              color = cgColor('black'), linestyle = 2, thick = 2
    ENDFOR

    happy = ''
    PRINT, ''
    READ, happy, prompt = 'Happy? (yes/no): '
    
  ENDIF ELSE BEGIN
    
    READCOL, temp_file, rms_window_val, /silent
    FOR i = 0, 1 DO BEGIN
      OPLOT, [rms_window_val[i],rms_window_val[i]], [MIN(y)-100, MAX(y)+100], $
              color = cgColor('black'), linestyle = 2, thick = 2
    ENDFOR
    PRINT, ''
    happy = 'yes'
    
  ENDELSE
ENDWHILE

spec_rms = CALCULATE_RMS( y, x, rms_window_val)

;-----------------------------------------------------------------------------;

RETURN, spec_rms

END

