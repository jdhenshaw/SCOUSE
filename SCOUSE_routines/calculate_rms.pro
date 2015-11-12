FUNCTION CALCULATE_RMS, y, x, rms_window_val
;------------------------------------------------------------------------------;
; PROGRAM NAME:
;   CALCULATE_RMS
;
; PURPOSE:
;   Calculates the rms given a window of line-free data
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;------------------------------------------------------------------------------;
Compile_Opt idl2
;------------------------------------------------------------------------------;
; RMS calc
;------------------------------------------------------------------------------;

IF rms_window_val[0] GT rms_window_val[1] THEN BEGIN
  y_trim = y[where(x LT rms_window_val[0] AND x GT rms_window_val[1])]
  rms = STDDEV(y_trim)
ENDIF ELSE BEGIN
  y_trim = y[where(x GT rms_window_val[0] AND x LT rms_window_val[1])]
  rms = STDDEV(y_trim)
ENDELSE
;------------------------------------------------------------------------------;
; END PROCESS
;------------------------------------------------------------------------------;
RETURN, rms

END