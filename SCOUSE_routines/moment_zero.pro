;+
;
; PROGRAM NAME:
;   MOMENT ZERO
;
; PURPOSE:
;   This program calculates the zeroth order moment
;   
; CALLING SEQUENCE:
;   momzero = MOMENT_ZERO(data, x, y, z, err_y, thresh, filename) 
;
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-

FUNCTION MOMENT_ZERO, data, x, y, z, err_y, thresh, OutFile=OutFile, PrintToFile=PTF
Compile_Opt idl2

;------------------------------------------------------------------------------;
; MOMZERO                                                                                                                 
;------------------------------------------------------------------------------;

momzero   = REPLICATE(0d0, N_ELEMENTS(x), N_ELEMENTS(y))
datamom   = REPLICATE(0d0, N_ELEMENTS(x), N_ELEMENTS(y), N_ELEMENTS(z))
chanwidth = (((MAX(z)-MIN(z))/N_ELEMENTS(z)))
ID        = WHERE(data GE thresh*err_y)   
indices   = ARRAY_INDICES(data, ID)

datamom[indices[0,*],indices[1,*],indices[2,*]] = data[indices[0,*],indices[1,*],indices[2,*]]
FOR i = 0, N_ELEMENTS(x)-1 DO BEGIN
  FOR j = 0, N_ELEMENTS(y)-1 DO BEGIN
    momzero[i,j]=TOTAL(chanwidth*datamom[i,j,WHERE(datamom[i,j,*] ne 0.0)])
  ENDFOR
ENDFOR

;------------------------------------------------------------------------------;
; PRINT TO FILE
;------------------------------------------------------------------------------;

If (KEYWORD_SET(PTF) && (N_ELEMENTS(OutFile) NE 0)) THEN BEGIN
  OPENW,1, OutFile
  FOR i = 0, N_ELEMENTS(x)-1 DO BEGIN
    FOR j = 0, N_ELEMENTS(y)-1 DO BEGIN
      PRINTF, 1, x[i], y[j], momzero[i,j], format = '((f12.5,x),(f12.5,x),(f10.3,x))'
    ENDFOR
  ENDFOR
  CLOSE,1
ENDIF

;------------------------------------------------------------------------------;
RETURN, momzero

END