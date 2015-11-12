FUNCTION PLOT_SPECTRUM, x, y, xrange_l, xrange_u, xtitle, ytitle, windowpos
;------------------------------------------------------------------------------;
; PROGRAM NAME:
;   PLOT SPECTRUM
;
; PURPOSE:
;   Plots a spectrum
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;------------------------------------------------------------------------------;
Compile_Opt idl2
;------------------------------------------------------------------------------;
; SIMPLE PLOT
;------------------------------------------------------------------------------;

diff = 0.1*max(y)

cgplot, x, y, xstyle = 4, ystyle=4, /nodata

pold_H=!p.multi[0]
plot, x, y, $
      xrange = [xrange_l, xrange_u], yrange=[min(y)-diff, max(y)+diff], $
      position = windowpos, $
      ps = 10, color = cgcolor('black'), $
      xtitle = xtitle, ytitle = ytitle, charsize=1.5, $
      /nodata, /noerase
!p.multi[0]=pold_H

oplot, x, y, color = cgcolor('black'), thick = 1, ps=10

;------------------------------------------------------------------------------;
; END PROCESS
;------------------------------------------------------------------------------;

END
