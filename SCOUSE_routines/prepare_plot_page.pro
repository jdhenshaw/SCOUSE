;+
;
; PROGRAM NAME:
;   PREPARE TO FIT
;
; PURPOSE:
;   This program prepares the plot page prior to fitting
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-

FUNCTION PREPARE_PLOT_PAGE, x, y, x_location, y_location, rms
Compile_Opt idl2

;------------------------------------------------------------------------------;
; PREPARE PLOT PAGE
;------------------------------------------------------------------------------;

!p.multi      = [0,2,1]
!x.thick      = 1
!y.thick      = 1
!p.background = cgColor('white')
DEVICE,DECOMPOSED=0
WINDOW, 0, ysize = 512, xsize=700
windowpos = [0.15, 0.1, 0.7, 0.5]

;------------------------------------------------------------------------------;
; PLOT SPECTRUM
;------------------------------------------------------------------------------;

plot_rsaa_spec = PLOT_SPECTRUM( x, y, MIN(x), MAX(x), 'X AXIS', 'Y AXIS', windowpos )

;-----------------------------------------------------------------------------;
; CREATE ADJACENT BOX
;-----------------------------------------------------------------------------;

pold_H=!p.multi[0]
PolyFill, [windowpos[2]+0.008,windowpos[2]+0.008,windowpos[2]+0.261, $
           windowpos[2]+0.261], $
          [windowpos[1],windowpos[3],windowpos[3],windowpos[1]], $
           COLOR=FSC_COLOR('black'), /normal, thick=2
!p.multi[0]=pold_H ;
pold_H=!p.multi[0]
PolyFill, [windowpos[2]+0.01,windowpos[2]+0.01,windowpos[2]+0.26, $
           windowpos[2]+0.26], [windowpos[1]+0.002,windowpos[3]-0.002,$
           windowpos[3]-0.002,windowpos[1]+0.002], $
           COLOR=FSC_COLOR('white'), /normal
!p.multi[0]=pold_H

;-----------------------------------------------------------------------------;
; ADD TEXT
;-----------------------------------------------------------------------------;

xpostext = STRING(x_location, format = '(F0.3)')
ypostext = STRING(y_location, format = '(F0.3)')
rmstext  = STRING(rms, format = '(F0.3)')

xtextpos = windowpos[2]+0.02
ytextpos = windowpos[3]-0.05
inc      = 0.05

cgText, 0.5, 0.9, 'Gaussian Fitting', $
        COLOR='navy', charsize = 2.0, charthick = 1.5, align = 0.5, /normal
cgText, xtextpos, ytextpos, 'Information:', $
        COLOR='navy', charthick = 1.5, /normal
cgText, xtextpos, ytextpos-2.0*inc, 'Pos = '+xpostext+', '+ypostext, $
        COLOR='navy', charsize = 1.2, /normal
cgText, xtextpos, ytextpos-3.0*inc, 'rms = '+rmstext+' units', $
        COLOR='navy', charsize = 1.2, /normal

;------------------------------------------------------------------------------;

RETURN, windowpos

END
