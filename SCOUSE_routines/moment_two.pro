;+
;
; PROGRAM NAME:
;   MOMENT TWO
;
; PURPOSE:
;   This program calculates the second order moment. It requires the first 
;   order moment as input
;   
; CALLING SEQUENCE:
;   momtwp = moment_two(data, x, y, z, err_y, thresh, OutFile, momone)  
;   
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-

FUNCTION MOMENT_TWO, data, x, y, z, err_y, thresh, OutFile, momone
Compile_Opt idl2

;------------------------------------------------------------------------------;
; CREATE MOMTWO                                                                                                                  
;------------------------------------------------------------------------------;

momtwo  = REPLICATE(0.0, N_ELEMENTS(x), N_ELEMENTS(y))
datamom = REPLICATE(0.0, N_ELEMENTS(x), N_ELEMENTS(y), N_ELEMENTS(z))

ID = WHERE(data GE thresh*err_y)
indices = ARRAY_INDICES(data, ID)
datamom[indices[0,*],indices[1,*],indices[2,*]]=$
                                    data[indices[0,*],indices[1,*],indices[2,*]]

chanwidth = (((MAX(z)-MIN(z))/N_ELEMENTS(z)))

FOR i = 0, N_ELEMENTS(x)-1 DO BEGIN
  FOR j = 0, N_ELEMENTS(y)-1 DO BEGIN
    momtwo[i,j] = SQRT((TOTAL(datamom[i,j,WHERE(datamom[i,j,*] NE 0.0)]*$
                       (z[WHERE(datamom[i,j,*] NE 0.0)]-momone[i,j])*$
                       (z[WHERE(datamom[i,j,*] NE 0.0)]-momone[i,j])*$
                        chanwidth))/$
                       (TOTAL(datamom[i,j,WHERE(datamom[i,j,*] NE 0.0)]*$
                        chanwidth)))
  endfor
endfor

;------------------------------------------------------------------------------;
; write the moment out to a file for reference

OPENW,1, OutFile
FOR i = 0, N_ELEMENTS(x)-1 DO BEGIN
  FOR j = 0, N_ELEMENTS(y)-1 DO BEGIN
    PRINTF, 1, x[i], y[j], momtwo[i,j],$
               format = '((f12.5,x),(f12.5,x),(f10.3,x))'
  ENDFOR
ENDFOR
CLOSE,1

;------------------------------------------------------------------------------;
RETURN, momtwo

END