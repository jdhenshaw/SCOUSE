FUNCTION CALCULATE_RMS, x, y, rms_window_val
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

y_trim = y[where(x GT MIN(rms_window_val) AND x LT MAX(rms_window_val))]
rms = STDDEV(y_trim)

;------------------------------------------------------------------------------;
RETURN, rms

END