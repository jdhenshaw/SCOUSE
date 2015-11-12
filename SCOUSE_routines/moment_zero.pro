FUNCTION MOMENT_ZERO, data, x_axis_map, y_axis_map, z_axis, rms_approx, $
                      sigma_cut, ascii_filename
;------------------------------------------------------------------------------;
; Copyright (c) 2015 Jonathan D. Henshaw
; CONTACT: j.d.henshaw@ljmu.ac.uk
;
; PROGRAM NAME:
;   MOMENT ZERO
;
; PURPOSE:
;   This program calculates the zeroth order moment
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;------------------------------------------------------------------------------;

Compile_Opt idl2

;------------------------------------------------------------------------------;
; CREATE MOMZERO                                                                                                                 
;------------------------------------------------------------------------------;

momzero = REPLICATE(0.0, N_ELEMENTS(x_axis_map), N_ELEMENTS(y_axis_map))
datamom = REPLICATE(0.0, N_ELEMENTS(x_axis_map), N_ELEMENTS(y_axis_map), $
                    N_ELEMENTS(z_axis))

ID = WHERE(data GE sigma_cut*rms_approx)
indices = ARRAY_INDICES(data, ID)
datamom[indices[0,*],indices[1,*],indices[2,*]]=$
                                    data[indices[0,*],indices[1,*],indices[2,*]]

chanwidth = (((MAX(z_axis)-MIN(z_axis))/N_ELEMENTS(z_axis)))

FOR i = 0, N_ELEMENTS(x_axis_map)-1 DO BEGIN
  FOR j = 0, N_ELEMENTS(y_axis_map)-1 DO BEGIN
    momzero[i,j]=TOTAL(chanwidth*datamom[i,j,WHERE(datamom[i,j,*] ne 0.0)])
  ENDFOR
ENDFOR

;------------------------------------------------------------------------------;
; write the zeroth moment out to a file for reference

OPENW,1, ascii_filename
FOR i = 0, N_ELEMENTS(x_axis_map)-1 DO BEGIN
  FOR j = 0, N_ELEMENTS(y_axis_map)-1 DO BEGIN
    PRINTF, 1, x_axis_map[i], y_axis_map[j], momzero[i,j],$
               format = '((f12.5,x),(f12.5,x),(f10.3,x))'
  ENDFOR
ENDFOR
CLOSE,1

;------------------------------------------------------------------------------;
; END PROCESS
;------------------------------------------------------------------------------;

RETURN, momzero

END