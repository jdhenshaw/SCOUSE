;+
;
; PROGRAM NAME:
;   CREATE OFFSETS
;
; PURPOSE:
;   This program creates offset right ascension and declination given the 
;   central coordinates of a map. 
;
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, November 2015
;
;-

FUNCTION CREATE_OFFSETS, x, y, crval1, crval2, x_off=x_off, y_off=y_off
Compile_Opt idl2
;------------------------------------------------------------------------------;

x_hrs = (x/360.0)*24.0

x_off = REPLICATE(!values.f_nan,N_ELEMENTS(x))
y_off = REPLICATE(!values.f_nan,N_ELEMENTS(y))

FOR i=0, N_ELEMENTS(x)-1 DO BEGIN
  x_off[i] = ((x_hrs[i]-(crval1/360.0)*24.0)*3600.0)*15.0$
               *COS(((crval2/360.0)*2.0*!pi))
ENDFOR
FOR i=0, N_ELEMENTS(y)-1 DO BEGIN
  y_off[i] = (y[i]-crval2)*3600.0
ENDFOR

;------------------------------------------------------------------------------;


END