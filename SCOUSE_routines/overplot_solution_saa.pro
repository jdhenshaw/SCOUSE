;+
;
; PROGRAM NAME:
;   OVERPLOT SOLUTION SAA
;
; PURPOSE:
;   Overplots the current SAA solution
;   
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-

FUNCTION OVERPLOT_SOLUTION_SAA, x, y, SolnArr, ResArr, windowpos
Compile_Opt idl2

;------------------------------------------------------------------------------;

; Prepare text

n             = STRING(SolnArr[0,0], format = '(I2)')
xpos          = STRING(SolnArr[0,1], format = '(F0.3)')
ypos          = STRING(SolnArr[0,2], format = '(F0.3)')
rmstext       = STRING(SolnArr[0,9], format = '(F0.3)')
resid_text    = STRING(SolnArr[0,10], format='(F0.2)')
chisqred_text = STRING(SolnArr[0,13], format='(F0.2)')


xtextpos = windowpos[2]+0.02
ytextpos = windowpos[3]-0.05
inc      = 0.05

cgText, xtextpos, ytextpos-5.0*inc, '!4v!X!U 2!N!D red!N = '+chisqred_text,$
  COLOR='navy', charsize = 1.2, /normal
cgText, xtextpos, ytextpos-6.0*inc, 'resid = ' + resid_text + ' K', $
  COLOR='navy', charsize = 1.2, /normal
cgText, xtextpos, ytextpos-4.0*inc, n+' components', $
  COLOR='navy', charsize = 1.2, /normal

; If no component fit is selected then plot the residuals, else plot the best 
; fitting solution

IF SolnArr[0,0] EQ 0.0 THEN BEGIN

  cgPlot, x, y, ps = 10, color = cgColor('green'), thick = 1, /over

ENDIF ELSE BEGIN
  dummy_x = (FINDGEN(6001)-3000)*0.1
  gauss_tot = FLTARR(N_ELEMENTS(dummy_x))
  
  FOR i = 0, n-1 DO BEGIN
    gauss = FLTARR(N_ELEMENTS(dummy_x))
    gauss_tot += SolnArr[i,3]*EXP(-(((dummy_x-SolnArr[i,5])^2.)/$
                 (2.*(SolnArr[i,7]/(2.0*SQRT(2.0*ALOG(2.0))))^2.)))
    gauss      = SolnArr[i,3]*EXP(-(((dummy_x-SolnArr[i,5])^2.)/$
                 (2.*(SolnArr[i,7]/(2.0*SQRT(2.0*ALOG(2.0))))^2.)))
                 
    cgPlot, dummy_x, gauss, color = cgColor('indian red'), thick = 2, /over
  ENDFOR
  cgPlot, dummy_x, gauss_tot, color = cgColor('dodger blue'), thick = 2, /over
  cgPlot, x, ResArr, ps =10, color = cgColor('green'), thick = 1, /over
  
ENDELSE

;------------------------------------------------------------------------------;

END