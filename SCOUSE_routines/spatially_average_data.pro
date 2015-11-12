FUNCTION SPATIALLY_AVERAGE_DATA, data_rms, data, x_rms, x, ID_x, ID_y, y = y
;------------------------------------------------------------------------------;
; PROGRAM NAME:
;   SPATIALLY AVERAGE DATA
;
; PURPOSE:
;   This program spatially averages data over a given area
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;------------------------------------------------------------------------------;
Compile_Opt idl2
;------------------------------------------------------------------------------;

y = REPLICATE(0.0, N_ELEMENTS(x))
FOR k = 0, N_ELEMENTS(y)-1 DO BEGIN
  y[k] = TOTAL(data[ID_x,ID_y,k])
ENDFOR
y = y/(N_ELEMENTS(ID_x)*N_ELEMENTS(ID_y))
y_rms = REPLICATE(0.0, N_ELEMENTS(x_rms))
FOR k = 0, N_ELEMENTS(y_rms)-1 DO BEGIN
  y_rms[k] = TOTAL(data_rms[ID_x,ID_y,k])
ENDFOR
y_rms = y_rms/(N_ELEMENTS(ID_x)*N_ELEMENTS(ID_y))

;------------------------------------------------------------------------------;
; END PROCESS
;------------------------------------------------------------------------------;
RETURN, y_rms

END
