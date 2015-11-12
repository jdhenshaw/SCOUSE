FUNCTION CREATE_COORDFILES, rsaa, coverage_ascii, coordfile, coordfile_coverage, $
                            tmp, x_axis, y_axis
;------------------------------------------------------------------------------;
; Copyright (c) 2015 Jonathan D. Henshaw
; CONTACT: j.d.henshaw@ljmu.ac.uk
;
; PROGRAM NAME:
;   CREATE COORDFILES
;
; PURPOSE:
;   This program creates two ascii files containing coordinate locations and 
;   their indices
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;------------------------------------------------------------------------------;
Compile_Opt idl2
;------------------------------------------------------------------------------;
; CREATE NECESSARY ARRAYS
;------------------------------------------------------------------------------;
posx = REPLICATE(0d0, N_ELEMENTS(x_axis)*N_ELEMENTS(y_axis))
posy = REPLICATE(0d0, N_ELEMENTS(x_axis)*N_ELEMENTS(y_axis))
xindex = REPLICATE(0d0, N_ELEMENTS(x_axis)*N_ELEMENTS(y_axis))
yindex = REPLICATE(0d0, N_ELEMENTS(x_axis)*N_ELEMENTS(y_axis))
combindex = REPLICATE(0d0, N_ELEMENTS(x_axis)*N_ELEMENTS(y_axis))
;------------------------------------------------------------------------------;
; ALL COORDS
;------------------------------------------------------------------------------;
FOR i = 0, N_ELEMENTS(x_axis)-1 DO BEGIN
  FOR j = 0, N_ELEMENTS(y_axis)-1 DO BEGIN
    posx[j+i*N_ELEMENTS(y_axis)] = x_axis[i]
    posy[j+i*N_ELEMENTS(y_axis)] = y_axis[j]
    xindex[j+i*N_ELEMENTS(y_axis)]  = i
    yindex[j+i*N_ELEMENTS(y_axis)]  = j
    combindex[j+i*N_ELEMENTS(y_axis)]  = j+i*N_ELEMENTS(y_axis)
  ENDFOR
ENDFOR

OPENW,1,coordfile, width = 100
FOR i = 0, N_ELEMENTS(posx)-1 DO BEGIN
  PRINTF,1, posx[i], posy[i],xindex[i],yindex[i],combindex[i], $
            format='(2(F12.5, x), 3(F10.2, x))'
ENDFOR
CLOSE,1

;-----------------------------------------------------------------------------;
; COVERAGE COORDS
;-----------------------------------------------------------------------------;
READCOL, coverage_ascii, format = '(F,F)', coverage_x, coverage_y, /silent

OPENW, 1, tmp, width=100
FOR i = 0,  N_ELEMENTS(coverage_x)-1  DO BEGIN
  ID_x = WHERE(x_axis LE coverage_x[i]+rsaa AND x_axis GE coverage_x[i]-rsaa)
  ID_y = WHERE(y_axis LE coverage_y[i]+rsaa AND y_axis GE coverage_y[i]-rsaa)
  FOR j = 0, N_ELEMENTS(ID_x)-1 DO BEGIN
    FOR k = 0, n_elements(ID_y)-1 DO BEGIN
      PRINTF, 1, x_axis[ID_x[j]], y_axis[ID_y[k]], format='(2(F12.5, x))'
    ENDFOR
  ENDFOR
ENDFOR
CLOSE,1

READCOL, tmp, xpos, ypos, /silent
READCOL, coordfile, posx, posy, xindex, yindex, combindex, /silent

OPENW,1,coordfile_coverage, width=100
FOR i = 0, N_ELEMENTS(posx)-1 DO BEGIN
  ID = WHERE(xpos EQ posx[i] AND ypos EQ posy[i])
  IF ID[0] NE -1.0 THEN BEGIN
    PRINTF,1, xpos[ID[0]], ypos[ID[0]], xindex[i], yindex[i], combindex[i], $
              format='(2(F12.5, x), 3(F10.2, x))'
  ENDIF
ENDFOR
CLOSE,1

READCOL, coordfile_coverage, xpos, ypos, nlines = nlines, /silent

;------------------------------------------------------------------------------;
; END PROCESS
;------------------------------------------------------------------------------;

RETURN, nlines

END