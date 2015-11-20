;+
;
; PROGRAM NAME:
;   MOMENT ONE
;
; PURPOSE:
;   This program calculates the first order moment. 
;   
; CALLING SEQUENCE:
;   momone = MOMENT_ONE(data, x, y, z, err_y, thresh, OutFile)
;   
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-

FUNCTION MOMENT_ONE, data, x, y, z, err_y, thresh, OutFile=OutFile, PrintToFile=PTF
Compile_Opt idl2

;------------------------------------------------------------------------------;
; MOMONE                                                                                                                  
;------------------------------------------------------------------------------;

momone    = REPLICATE(0d0, N_ELEMENTS(x), N_ELEMENTS(y))
datamom   = REPLICATE(0d0, N_ELEMENTS(x), N_ELEMENTS(y), N_ELEMENTS(z))
chanwidth = (((MAX(z)-MIN(z))/N_ELEMENTS(z)))
ID        = WHERE(data GE thresh*err_y)   
indices   = ARRAY_INDICES(data, ID)

datamom[indices[0,*],indices[1,*],indices[2,*]]=data[indices[0,*],indices[1,*],indices[2,*]]
FOR i = 0, N_ELEMENTS(x)-1 DO BEGIN
  FOR j = 0, N_ELEMENTS(y)-1 DO BEGIN
    momone[i,j] = (TOTAL(datamom[i,j,WHERE(datamom[i,j,*] NE 0.0)]*z[WHERE(datamom[i,j,*] NE 0.0)]*chanwidth))/(TOTAL(datamom[i,j,WHERE(datamom[i,j,*] NE 0.0)]*chanwidth))
  ENDFOR
ENDFOR

;------------------------------------------------------------------------------;
; PRINT TO FILE
;------------------------------------------------------------------------------;

If (KEYWORD_SET(PTF) && (N_ELEMENTS(OutFile) NE 0)) THEN BEGIN
  OPENW,1, OutFile
  FOR i = 0, N_ELEMENTS(x)-1 DO BEGIN
    FOR j = 0, N_ELEMENTS(y)-1 DO BEGIN
      PRINTF, 1, x[i], y[j], momone[i,j], format = '((f12.5,x),(f12.5,x),(f10.3,x))'
    ENDFOR
  ENDFOR
  CLOSE,1
ENDIF

;------------------------------------------------------------------------------;
RETURN, momone

END