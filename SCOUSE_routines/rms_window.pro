;+
;
; PROGRAM NAME:
;   RMS WINDOW
;
; PURPOSE:
;   An interactive program that calculates the rms over a window defined by
;   the user. The information is saved to a file and can be used for subsequent
;   rms calculations (without the need to enter a new window)
;   
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-

FUNCTION RMS_WINDOW, x, y, x_location, y_location, TmpFile
Compile_Opt idl2

;------------------------------------------------------------------------------;

rms_window_val = REPLICATE(0d0, 2)

happy = 'no'
WHILE happy NE 'yes' DO BEGIN
  
  ; Begin rms window definition
  
  windowpos = PREPARE_PLOT_PAGE( x, y, x_location, y_location, 0.0 ) 
  PRINT, ''
  PRINT, 'Define window for rms calculation...'
  PRINT, '' 
  new_vals = ''
  READ, new_vals, prompt = 'Would you like to choose a new rms window? ' 
  PRINT, '' 
  IF new_vals EQ 'yes' OR new_vals EQ 'y' OR new_vals EQ 'ys' OR new_vals EQ 'YES' OR new_vals EQ 'Y' OR new_vals EQ 'YS' THEN BEGIN   
    OPENW, 1, TmpFile
    READ, win, prompt = 'Enter lower window limit (km s-1): '
    rms_window_val[0] = win
    PRINTF,1,win
    READ, win, prompt = 'Enter upper window limit (km s-1): '
    rms_window_val[1] = win
    PRINTF,1,win
    CLOSE,1
    FOR i = 0, 1 DO BEGIN
      OPLOT, [rms_window_val[i],rms_window_val[i]], [MIN(y)-100, MAX(y)+100], color = cgColor('black'), linestyle = 2, thick = 2
    ENDFOR
    happy = ''
    PRINT, ''
    READ, happy, prompt = 'Happy? (yes/no): '  
  ENDIF ELSE BEGIN
    
    ; If user does not want to select a new window - use the previous one
    
    READCOL, TmpFile, rms_window_val, /silent
    FOR i = 0, 1 DO BEGIN
      OPLOT, [rms_window_val[i],rms_window_val[i]], [MIN(y)-100, MAX(y)+100], color = cgColor('black'), linestyle = 2, thick = 2
    ENDFOR
    PRINT, ''
    happy = 'yes'
    
  ENDELSE
ENDWHILE

;-----------------------------------------------------------------------------;

RETURN, rms_window_val

END

