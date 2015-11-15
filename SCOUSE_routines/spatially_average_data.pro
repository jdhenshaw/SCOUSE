;+
;
; PROGRAM NAME:
;   SPATIALLY AVERAGE DATA
;
; PURPOSE:
;   This program spatially averages data over a given area
;   
; CALLING SEQUENCE:
;   y = spatially_average_data( image, x, ID_x, ID_y )
;   
;   ID_x/ID_y = the indices over which you are going to average image data
;   
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-

FUNCTION SPATIALLY_AVERAGE_DATA, im, x, ID_x, ID_y
Compile_Opt idl2

;------------------------------------------------------------------------------;

y = REPLICATE(0.0, N_ELEMENTS(x))
FOR k = 0, N_ELEMENTS(y)-1 DO BEGIN
  y[k] = TOTAL(im[ID_x,ID_y,k])
ENDFOR
y = y/(N_ELEMENTS(ID_x)*N_ELEMENTS(ID_y))

;------------------------------------------------------------------------------;

RETURN, y

END
