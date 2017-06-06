;+
;
; PROGRAM NAME:
;   PLOT SOLUTION GRID
;
; PURPOSE:
;   plots a grid of spectra
;
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-

FUNCTION PLOT_SOLUTION_GRID, SolnArr, SolnArr_alt, indArr_alt, uniq_indx, x, y, xrange
Compile_Opt idl2

;------------------------------------------------------------------------------;
; SET UP PLOT WINDOW
;------------------------------------------------------------------------------;

WINDOW, xsize = 800, ysize = 800

!p.multi = [0, 3, 4]
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
y_plot = y[MIN(ID):MAX(ID)]

; Convert to dispersion (for plotting)

conv_FWHM2disp = (2.0*SQRT(2.0*ALOG(2.0)))
SolnArr[*,7]   = SolnArr[*,7]/conv_FWHM2disp
SolnArr[*,8]   = SolnArr[*,8]/conv_FWHM2disp

;------------------------------------------------------------------------------;

cind      = IndArr_alt[*,4]
cind_text = STRING(cind, format='(I10)')
dmax      = MAX(y_plot)
diff      = 0.4*dmax
ymax      = dmax+diff

;------------------------------------------------------------------------------;
; Begin the plotting process
;------------------------------------------------------------------------------;
; Plot the current solution
;------------------------------------------------------------------------------;

FOR i = 0, 2 DO BEGIN
  IF i EQ 1 THEN BEGIN
    PLOT, x_plot, y_plot, ps=10, color = cgColor('black'), thick = 1., $
          background = cgColor('white'), $
          yrange=[-0.1,ymax], xrange = [MIN(xrange),MAX(xrange)], $
          ytickformat = '(A1)', xtickformat = '(A1)'
          
    gauss_tot = REPLICATE(0.0, N_ELEMENTS(x_plot))
    FOR j = 0, N_ELEMENTS(SolnArr[*,0])-1 DO BEGIN
      gauss      = REPLICATE(0d0, N_ELEMENTS(x_plot))
      gauss_tot += SolnArr[j, 3]*exp(-((x_plot-SolnArr[j, 5])^2.0)/$
                   (2.0*SolnArr[j, 7]^2.0))
      gauss      = SolnArr[j, 3]*exp(-((x_plot-SolnArr[j, 5])^2.0)/$
                   (2.0*SolnArr[j, 7]^2.0))
      OPLOT, x_plot, gauss, color = cgColor('indian red'), thick =2
    ENDFOR
    OPLOT, x_plot, gauss_tot, color = cgColor('dodger blue'), thick =1   
          
    XYOUTS, 0.61, 0.89, cind_text, $
            color=cgColor('black'), align = 1.0, $
            charthick = 1, charsize = 4.0, $
            /normal    
          
  ENDIF ELSE BEGIN
    PLOT, x_plot, y_plot, ps=10, color = cgColor('black'), thick = 1., $
          background = cgColor('white'), $
          yrange=[-0.1,ymax], xrange = [min(xrange),max(xrange)], $
          ytickformat = '(A1)', xtickformat = '(A1)',ystyle=4, xstyle=4,/nodata
  ENDELSE
ENDFOR

;------------------------------------------------------------------------------;
; Plot alternatives
;------------------------------------------------------------------------------;

vals=['a','b','c','d','e','f','g','h','i']
IF TOTAL(SolnArr_alt) NE -1.0 THEN BEGIN  
  SolnArr_alt[*,7] = SolnArr_alt[*,7]/conv_FWHM2disp
  SolnArr_alt[*,8] = SolnArr_alt[*,8]/conv_FWHM2disp
ENDIF

FOR i = 0, N_ELEMENTS(uniq_indx)-1 DO BEGIN
  PLOT, x_plot, y_plot, ps=10, color = cgColor('black'), thick = 1., $
        background = cgColor('white'), $
        yrange=[-0.1,ymax], xrange = [min(xrange),max(xrange)], $
        ytickformat = '(A1)', xtickformat = '(A1)'
  
  IF uniq_indx[i] NE -1 THEN BEGIN
    ID = WHERE(SolnArr_alt[*,11] EQ SolnArr_alt[uniq_indx[i],11]) 
    gauss_tot = REPLICATE(0.0, N_ELEMENTS(x_plot))
    FOR j = 0, N_ELEMENTS(ID)-1 DO BEGIN
      gauss      = REPLICATE(0.0, N_ELEMENTS(x_plot))
      gauss_tot += SolnArr_alt[ID[j], 3]*exp(-((x_plot-SolnArr_alt[ID[j], 5])^2.0)/$
                   (2.0*SolnArr_alt[ID[j], 7]^2.0))
      gauss      = SolnArr_alt[ID[j], 3]*exp(-((x_plot-SolnArr_alt[ID[j], 5])^2.0)/$
                   (2.0*SolnArr_alt[ID[j], 7]^2.0))
      OPLOT, x_plot, gauss, color = cgColor('indian red'), thick =2
    ENDFOR
    OPLOT, x_plot, gauss_tot, color = cgColor('dodger blue'), thick =1
    
    xpos = [0.34,0.60,0.86,0.34,0.60,0.86,0.34,0.60,0.86]
    ypos = [0.67,0.67,0.67,0.45,0.45,0.45,0.24,0.24,0.24]

    XYOUTS, xpos[i], ypos[i], vals[i], $
      color=cgColor('black'), align = 0.5, $
      charthick = 1, charsize = 4.0, $
      /normal

  ENDIF
ENDFOR

;------------------------------------------------------------------------------;

SolnArr[*,7]   = SolnArr[*,7]*conv_FWHM2disp
SolnArr[*,8]   = SolnArr[*,8]*conv_FWHM2disp

IF TOTAL(SolnArr_alt) NE -1.0 THEN BEGIN
  SolnArr_alt[*,7] = SolnArr_alt[*,7]*conv_FWHM2disp
  SolnArr_alt[*,8] = SolnArr_alt[*,8]*conv_FWHM2disp
ENDIF

;------------------------------------------------------------------------------;

XYOUTS, 0.08, 0.37, 'Unique alternatives', $
        color=cgColor('black'), align = 0.5, orientation = 90.0, $
        charthick = 1, charsize = 4.0, $
        /normal
  
XYOUTS, 0.25, 0.85, 'Current', $
        color=cgColor('black'), align = 0.5, $
        charthick = 1, charsize = 4.0, $
        /normal  

XYOUTS, 0.25, 0.80, 'Solution', $
        color=cgColor('black'), align = 0.5, $
        charthick = 1, charsize = 4.0, $
        /normal

;------------------------------------------------------------------------------;

END