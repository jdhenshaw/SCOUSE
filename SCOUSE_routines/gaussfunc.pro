;+
;
; PROGRAM NAME:
;   GAUSSFUNC
;
; PURPOSE:
;   Create a Gaussian profile
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-

FUNCTION GAUSSFUNC, velo, p
Compile_Opt idl2

;------------------------------------------------------------------------------;

array_size = SIZE(p, /dimensions)
n = array_size/3

gauss = 0.0
FOR i = 0, n[0]-1 DO BEGIN
  gauss += p[i*3]*EXP(-(((velo-p[(i*3)+1])^2)/(2*p[(i*3)+2]^2)))
ENDFOR

;------------------------------------------------------------------------------;

RETURN, gauss

END