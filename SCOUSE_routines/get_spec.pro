;+
;
; PROGRAM NAME:
;   GET SPEC
;
; PURPOSE:
;   This program returns the y axis of a spectrum. It can be used to spatially
;   average data over a region and return this information. 
;   
; CALLING SEQUENCE:
;   y = GET_SPEC( image, x, ID_x, ID_y )
;   
;   ID_x/ID_y = the indices over which you are going to average image data. 
;   Single values will result in the return of a single spectrum. Multiple 
;   values will result in the return of a spatially averaged spectrum.
;   
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-

FUNCTION GET_SPEC, im, x, ID_x, ID_y
Compile_Opt idl2

;------------------------------------------------------------------------------;

y = REPLICATE(0d0, N_ELEMENTS(x))
FOR k = 0, N_ELEMENTS(y)-1 DO BEGIN
  y[k] = TOTAL(im[ID_x,ID_y,k])
ENDFOR
y = y/(N_ELEMENTS(ID_x)*N_ELEMENTS(ID_y))

;------------------------------------------------------------------------------;

RETURN, y

END
