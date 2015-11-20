;+
;
; PROGRAM NAME:
;   PLOT COVERAGE
;
; PURPOSE:
;   This program creates a plot of the moment zero map and the coverage
;   
; INFORMATION:
;   This program can and should be edited to the users taste and is 
;   non-essential to SCOUSE
;   
;   This code (optional) makes use of disp.pro, credit: Erik Rosolowsky
;   https://github.com/low-sky/idl-low-sky/blob/master/graphics/disp.pro
;   
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, November 2015
;
;-

PRO PLOT_COVERAGE, x, y, map, radius, coverage, OutFile
Compile_Opt idl2

;------------------------------------------------------------------------------;
; PLOT SETUP
;------------------------------------------------------------------------------;

!p.multi   = [0,1,1]
!x.margin  = [0,0]
!y.margin  = [0,0]
!x.omargin = [20,10]
!y.omargin = [20,10]
!x.thick   = 4
!y.thick   = 4
!P.FONT    = 0

SET_PLOT, 'PS'
IF N_ELEMENTS(x) GT N_ELEMENTS(y) THEN BEGIN
  DEVICE, filename = OutFile, /color, xsize = 11.7, ysize = 8.3, $
          /encap, /inches, SET_FONT = 'times-roman'
  position =  [0.2, 0.2, 0.9, 0.9]
ENDIF ELSE BEGIN
  DEVICE, filename = OutFile, /color, xsize = 8.3, ysize = 11.7, $
          /encap, /inches, SET_FONT = 'times-roman'
  position =  [0.2, 0.2, 0.8, 0.8]
ENDELSE

;------------------------------------------------------------------------------;
; PLOTTING
;------------------------------------------------------------------------------;

peak_data = MAX(map)

cgLoadCT, 0, ncolors = 256, /rev
cgLoadCT, 49, ncolors = 255, bottom = 1
pold_H=!p.multi[0]
DISP, map, x, y, /half, /sq, ystyle = 4, xstyle = 4, pos = position, /nodisp
!p.multi[0]=pold_H
cgLoadCT, 0, ncolors = 256
cgColorFill, [x[0],x[-1], x[-1], x[0]], [y[0], y[0], y[-1], y[-1]], Color='white' 
DISP, map, x, y, /half, /sq, /nodisp, /noerase, pos = position, $
      ytitle='y', xtitle='x', charthick = 5, charsize=1.8, $
      yminor = 5, yticklen = 0.01,$
      xminor = 5, xticklen = 0.05

;------------------------------------------------------------------------------;
; FILLED CONTOUR MAP - OPTIONAL
;------------------------------------------------------------------------------;

levels     = 7.0
step       = (MAX(map)) / levels
userLevels = INDGEN(levels) * step
  
cgLoadCT, 49, BOTTOM=0, NCOLORS=6

; Plot the filled contours

CONTOUR, map, x, y, $
         /Fill, C_Colors=(INDGEN(levels)+1)*1.0, Background=cgColor('white'), $
         levels=[0.01*peak_data,0.05*peak_data,0.25*peak_data,$
         0.45*peak_data,0.65*peak_data],Color=cgColor('black'), /over

cgLoadCT, 0, ncolors = 256

; Overplot the contour lines for clarity

CONTOUR, map, x, y, $
         thick =1, levels=[0.01*peak_data,0.05*peak_data,0.25*peak_data,$
         0.45*peak_data,0.65*peak_data], $
         Color=cgColor('black'), /over

;------------------------------------------------------------------------------;
; PLOT SPECTRAL AVERAGING AREAS
;------------------------------------------------------------------------------;

READCOL, coverage, format = '(F,F)', cov_xpos, cov_ypos, /silent
FOR i = 0, N_ELEMENTS(cov_xpos)-1 DO BEGIN
  TVBOX, radius*2.0, cov_xpos[i], cov_ypos[i], color=cgColor('black'), $
         thick = 3.0, /data
ENDFOR

;------------------------------------------------------------------------------;
DEVICE, /close
SET_PLOT, 'X'

END