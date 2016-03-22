;+
;
; PROGRAM NAME:
;   CALCULATE_RMS
;
; PURPOSE:
;   Calculates the rms given a window of line-free data
;   
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-

FUNCTION CALCULATE_RMS, x, y, rms_window_val
Compile_Opt idl2

;------------------------------------------------------------------------------;
; RMS calc
;------------------------------------------------------------------------------;

ID = WHERE(x GT MIN(rms_window_val) AND x LT MAX(rms_window_val))
IF ID[0] NE -1 THEN y_trim = y[ID] ELSE y_trim = y
rms = STDDEV(y_trim)

;------------------------------------------------------------------------------;
RETURN, rms

END