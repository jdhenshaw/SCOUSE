FUNCTION FIT_SPECTRUM_SAA, x, y, err_y, xpos, ypos, n, param_estimates, $
                           ResArr=ResArr
;------------------------------------------------------------------------------;
; PROGRAM NAME:
;   FIT SPECTRUM
;
; PURPOSE:
;   Fitting the spatially averaged spectra
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;------------------------------------------------------------------------------;
Compile_Opt idl2
;------------------------------------------------------------------------------;
; SEND PARAMETER GUESSES TO MPFIT
;------------------------------------------------------------------------------;

error_estimates = REPLICATE(0.0, N_ELEMENTS(param_estimates))

result = MPFITFUN('gaussfunc', x, y, err_y, param_estimates, $
                               perror = error_estimates, $
                               bestnorm = totchisq, $
                               best_resid = bres, $
                               dof = dof, $
                               /quiet)

chisqred = totchisq/(dof-1)
resid = STDDEV(bres*err_y )
ResArr = ( bres*err_y )

SolnArr = REPLICATE(0.0, n, 14)

FOR i = 0, n-1 DO BEGIN
  SolnArr[i,0]  = n
  SolnArr[i,1]  = xpos
  SolnArr[i,2]  = ypos
  SolnArr[i,3]  = result[(i*3.0)]
  SolnArr[i,4]  = error_estimates[(i*3.0)]
  SolnArr[i,5]  = result[(i*3.0)+1.0]
  SolnArr[i,6]  = error_estimates[(i*3.0)+1.0]
  SolnArr[i,7]  = result[(i*3.0)+2.0]*(2.0*SQRT(2.0*ALOG(2.0)))
  SolnArr[i,8]  = error_estimates[(i*3.0)+2.0]*(2.0*SQRT(2.0*ALOG(2.0)))
  SolnArr[i,9]  = err_y[0]
  SolnArr[i,10] = chisqred
  SolnArr[i,11] = resid
  SolnArr[i,12] = 0.0
  SolnArr[i,13] = 0.0
ENDFOR

;------------------------------------------------------------------------------;
; END PROCESS
;------------------------------------------------------------------------------;
RETURN, SolnArr

END