;+
;
; PROGRAM NAME:
;   MOMENT ONE
;
; PURPOSE:
;   This program calculates the first order moment. 
;   
; CALLING SEQUENCE:
;   momone = moment_one(data, x, y, z, err_y, thresh, OutFile)
;   
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-

FUNCTION MOMENT_ONE, data, x, y, z, err_y, thresh, OutFile
Compile_Opt idl2

;------------------------------------------------------------------------------;
; CREATE MOMONE                                                                                                                  
;------------------------------------------------------------------------------;

momone  = REPLICATE(0.0, N_ELEMENTS(x), N_ELEMENTS(y))
datamom = REPLICATE(0.0, N_ELEMENTS(x), N_ELEMENTS(y), N_ELEMENTS(z))

ID = WHERE(data GE thresh*err_y)
indices = ARRAY_INDICES(data, ID)
datamom[indices[0,*],indices[1,*],indices[2,*]]=$
                                    data[indices[0,*],indices[1,*],indices[2,*]]

chanwidth = (((MAX(z)-MIN(z))/N_ELEMENTS(z)))

FOR i = 0, N_ELEMENTS(x)-1 DO BEGIN
  FOR j = 0, N_ELEMENTS(y)-1 DO BEGIN
    momone[i,j] = (TOTAL(datamom[i,j,WHERE(datamom[i,j,*] NE 0.0)]*$
                   z[WHERE(datamom[i,j,*] NE 0.0)]*chanwidth))/$
                  (TOTAL(datamom[i,j,WHERE(datamom[i,j,*] NE 0.0)]*chanwidth))
  ENDFOR
ENDFOR

;------------------------------------------------------------------------------;
; write the moment out to a file for reference

OPENW,1, OutFile
FOR i = 0, N_ELEMENTS(x)-1 DO BEGIN
  FOR j = 0, N_ELEMENTS(y)-1 DO BEGIN
    PRINTF, 1, x[i], y[j], momone[i,j],$
               format = '((f12.5,x),(f12.5,x),(f10.3,x))'
  ENDFOR
ENDFOR
CLOSE,1

;------------------------------------------------------------------------------;
RETURN, momone

END