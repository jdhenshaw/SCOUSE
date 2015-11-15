;+
;
; PROGRAM NAME:
;   CREATE COORDFILES
;
; PURPOSE:
;   This program creates two ascii files containing coordinate locations and 
;   their indices
;   
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-

FUNCTION CREATE_COORDFILES, x, y, radius, coverage, OutFile1, OutFile2, tmp
Compile_Opt idl2

;------------------------------------------------------------------------------;
; CREATE NECESSARY ARRAYS
;------------------------------------------------------------------------------;
posx = REPLICATE(0d0, N_ELEMENTS(x)*N_ELEMENTS(y))
posy = REPLICATE(0d0, N_ELEMENTS(x)*N_ELEMENTS(y))
xindex = REPLICATE(0d0, N_ELEMENTS(x)*N_ELEMENTS(y))
yindex = REPLICATE(0d0, N_ELEMENTS(x)*N_ELEMENTS(y))
combindex = REPLICATE(0d0, N_ELEMENTS(x)*N_ELEMENTS(y))
;------------------------------------------------------------------------------;
; ALL COORDS
;------------------------------------------------------------------------------;

FOR i = 0, N_ELEMENTS(x)-1 DO BEGIN
  FOR j = 0, N_ELEMENTS(y)-1 DO BEGIN
    posx[j+i*N_ELEMENTS(y)] = x[i]
    posy[j+i*N_ELEMENTS(y)] = y[j]
    xindex[j+i*N_ELEMENTS(y)] = i
    yindex[j+i*N_ELEMENTS(y)] = j
    combindex[j+i*N_ELEMENTS(y)] = j+i*N_ELEMENTS(y)
  ENDFOR
ENDFOR

OPENW, 1, OutFile1, width = 100
FOR i = 0, N_ELEMENTS(posx)-1 DO BEGIN
  PRINTF,1, posx[i], posy[i],xindex[i],yindex[i],combindex[i], $
            format='(2(F12.5, x), 3(F10.2, x))'
ENDFOR
CLOSE,1

;-----------------------------------------------------------------------------;
; COVERAGE COORDS
;-----------------------------------------------------------------------------;

READCOL, coverage, format = '(F,F)', coverage_x, coverage_y, /silent

OPENW, 1, tmp, width=100
FOR i = 0,  N_ELEMENTS(coverage_x)-1  DO BEGIN
  ID_x = WHERE(x LE coverage_x[i]+radius AND x GE coverage_x[i]-radius)
  ID_y = WHERE(y LE coverage_y[i]+radius AND y GE coverage_y[i]-radius)
  FOR j = 0, N_ELEMENTS(ID_x)-1 DO BEGIN
    FOR k = 0, n_elements(ID_y)-1 DO BEGIN
      PRINTF, 1, x[ID_x[j]], y[ID_y[k]], format='(2(F12.5, x))'
    ENDFOR
  ENDFOR
ENDFOR
CLOSE,1

READCOL, tmp, xpos, ypos, /silent
READCOL, OutFile1, posx, posy, xindex, yindex, combindex, /silent

OPENW, 1, OutFile2, width=100
FOR i = 0, N_ELEMENTS(posx)-1 DO BEGIN
  ID = WHERE(xpos EQ posx[i] AND ypos EQ posy[i])
  IF ID[0] NE -1.0 THEN BEGIN
    PRINTF,1, xpos[ID[0]], ypos[ID[0]], xindex[i], yindex[i], combindex[i], $
              format='(2(F12.5, x), 3(F10.2, x))'
  ENDIF
ENDFOR
CLOSE,1

READCOL, OutFile2, xpos, ypos, nlines = nlines, /silent

;------------------------------------------------------------------------------;
RETURN, nlines

END