;+
;
; PROGRAM NAME:
;   PLOT SPECTRUM GRID
;
; PURPOSE:
;   plots a grid of spectra
;
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-

PRO PLOT_SPECTRUM_GRID, SolnArr, IndArr_trim, x, y, gridtotal, xrange, dim
Compile_Opt idl2

;------------------------------------------------------------------------------;
; SET UP PLOT WINDOW
;------------------------------------------------------------------------------;

WINDOW, xsize = 1200, ysize = 800

!p.multi = [0, dim, dim]
!x.thick=1
!y.thick =1
!x.margin = [1,1]
!x.omargin = [30,30]
!y.margin = [1,1]
!y.omargin = [10,10]
!p.background = cgColor('white')
!P.FONT = 1

cgLoadCT, 0, ncolors = 256

;------------------------------------------------------------------------------;

; Trim the x axes

ID     = WHERE(x GT MIN(xrange) AND x LT MAX(xrange))
x_plot = x[MIN(ID):MAX(ID)]
y_plot = y[*,*,MIN(ID):MAX(ID)]

;-----------------------------------------------------------------------------;

; Begin the plotting process

FOR i = 0, N_ELEMENTS(IndArr_trim[*,0])-1 DO BEGIN

  cind      = IndArr_trim[i,4]
  cind_text = STRING(cind, format='(I10)')
  dmax      = MAX(y[IndArr_trim[i, 2], IndArr_trim[i, 3], *])
  diff      = 0.4*dmax
  ymax      = dmax+diff
  
  PLOT, x_plot, y_plot[IndArr_trim[i, 2], IndArr_trim[i, 3], *], ps=10, $
        color = cgColor('black'), thick = 1., background = cgColor('white'), $
        yrange=[-0.1,ymax], xrange = [min(xrange),max(xrange)], $
        ytickformat = '(A1)', xtickformat = '(A1)'

  ID = where(SolnArr[*,1] EQ IndArr_trim[i,0] AND SolnArr[*,2] EQ IndArr_trim[i,1])

  IF ID[0] NE -1.0 THEN BEGIN
    gauss_tot = REPLICATE(0d0, N_ELEMENTS(x_plot))
    FOR j = 0, N_ELEMENTS(ID)-1 DO BEGIN
      gauss      = REPLICATE(0.0, N_ELEMENTS(x_plot))
      gauss_tot += SolnArr[ID[j], 3]*exp(-((x_plot-SolnArr[ID[j], 5])^2.0)/$
                  (2.0*SolnArr[ID[j], 7]^2.0))
                  
      gauss      = SolnArr[ID[j], 3]*exp(-((x_plot-SolnArr[ID[j], 5])^2.0)/$
                  (2.0*SolnArr[ID[j], 7]^2.0))
      OPLOT, x_plot, gauss, color = cgColor('indian red'), thick =2
    ENDFOR
    OPLOT, x_plot, gauss_tot, color = cgColor('dodger blue'), thick =1
  ENDIF
  
  XYOUTS, MAX(xrange)-1.0, ymax-(0.15*ymax), cind_text, $
    color=cgColor('black'), align = 1.0, $
    charthick = 1, charsize = 2.5, $
    /data

  XYOUTS, 0.05, 0.5, 'Variable y-axis', $
    color=cgColor('black'), align = 0.5, orientation = 90.0, $
    charthick = 1, charsize = 4.0, $
    /normal

  XYOUTS, 0.5, 0.02, 'From min to max x-range (defined by user)', $
    color=cgColor('black'), align = 0.5, $
    charthick = 1, charsize = 4.0, $
    /normal

ENDFOR

;-----------------------------------------------------------------------------;

END