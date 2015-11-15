;+
;
; PROGRAM NAME:
;   FIT SPECTRUM INDIV
;
; PURPOSE:
;   Find the best-fitting solution to a spectrum given an array of parameter 
;   estimates
;   
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-
;

FUNCTION FIT_SPECTRUM_INDIV, x, y, err_y, xpos, ypos, param_estimates, $
                             ResArr=ResArr, result=result
Compile_Opt idl2

;------------------------------------------------------------------------------;
; FITTING
;------------------------------------------------------------------------------;

; Create an array for mpfit to populate with the uncertainties

error_estimates = REPLICATE(0.0, N_ELEMENTS(param_estimates))

; Send the parameter estimates to mpfit

result = MPFITFUN('gaussfunc', x, y, err_y, param_estimates, $
                   perror = error_estimates, $
                   bestnorm = totchisq, $
                   best_resid = bres, $
                   dof = dof, $
                   /quiet)


chisqred = totchisq/(dof-1)
AIC = CALCULATE_AIC(N_ELEMENTS(param_estimates)/3, x, totchisq )
resid = STDDEV(bres*err_y )
ResArr = ( bres*err_y )

; Population the best-fitting solution array. Convert Gaussian dispersion to
; FWHM line width

conv_disp2FWHM = (2.0*SQRT(2.0*ALOG(2.0)))

SolnArr = REPLICATE(0.0, N_ELEMENTS(param_estimates)/3, 15)

FOR i = 0, (N_ELEMENTS(param_estimates)/3)-1 DO BEGIN
  
  result[(i*3.0)+2.0] = abs(result[(i*3.0)+2.0])
  error_estimates[(i*3.0)+2.0] = abs(error_estimates[(i*3.0)+2.0])
  
  SolnArr[i,0]  = N_ELEMENTS(param_estimates)/3
  SolnArr[i,1]  = xpos
  SolnArr[i,2]  = ypos
  SolnArr[i,3]  = result[(i*3.0)]
  SolnArr[i,4]  = error_estimates[(i*3.0)]
  SolnArr[i,5]  = result[(i*3.0)+1.0]
  SolnArr[i,6]  = error_estimates[(i*3.0)+1.0]
  SolnArr[i,7]  = result[(i*3.0)+2.0]*conv_disp2FWHM
  SolnArr[i,8]  = error_estimates[(i*3.0)+2.0]*conv_disp2FWHM
  SolnArr[i,9]  = err_y[0]
  SolnArr[i,10] = resid
  SolnArr[i,11] = totchisq
  SolnArr[i,12] = dof
  SolnArr[i,13] = chisqred
  SolnArr[i,14] = AIC
ENDFOR

;------------------------------------------------------------------------------;
RETURN, SolnArr


END