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

FUNCTION FIT_SPECTRUM, x, y, err_y, x_location, y_location, parameter_estimates, residual_array=residual_array, result=result
Compile_Opt idl2

;------------------------------------------------------------------------------;
; 
;------------------------------------------------------------------------------;

conv_disp2FWHM  = (2.0*SQRT(2.0*ALOG(2.0))) ; Conversion factor from dispersion to FWHM
error_estimates = REPLICATE(0d0, N_ELEMENTS(parameter_estimates))
result          = MPFITFUN('gaussfunc', x, y, err_y, parameter_estimates, $
                            perror = error_estimates, $
                            bestnorm = totalchisq, $
                            best_resid = bres, $
                            dof = dof, $
                            /quiet)

chisqred        = totalchisq/(dof-1)
AIC             = CALCULATE_AIC(N_ELEMENTS(parameter_estimates)/3, x, totalchisq )
residual        = STDDEV(bres*err_y )
residual_array  = ( bres*err_y )
SolnArr         = REPLICATE(0d0, N_ELEMENTS(parameter_estimates)/3, 15)

FOR i = 0, (N_ELEMENTS(parameter_estimates)/3)-1 DO BEGIN

  result[(i*3.0)+2.0]          = ABS(result[(i*3.0)+2.0])
  error_estimates[(i*3.0)+2.0] = ABS(error_estimates[(i*3.0)+2.0])

  SolnArr[i,0]  = N_ELEMENTS(parameter_estimates)/3             ; The number of components
  SolnArr[i,1]  = x_location                                    ; The x position
  SolnArr[i,2]  = y_location                                    ; The y position
  SolnArr[i,3]  = result[(i*3.0)]                               ; Peak value
  SolnArr[i,4]  = error_estimates[(i*3.0)]                      ; Uncertainty on peak
  SolnArr[i,5]  = result[(i*3.0)+1.0]                           ; Centroid value
  SolnArr[i,6]  = error_estimates[(i*3.0)+1.0]                  ; Uncertainty
  SolnArr[i,7]  = result[(i*3.0)+2.0]*conv_disp2FWHM            ; FWHM
  SolnArr[i,8]  = error_estimates[(i*3.0)+2.0]*conv_disp2FWHM   ; Uncertainty
  SolnArr[i,9]  = err_y[0]                                      ; Spectral rms  
  SolnArr[i,10] = residual                                      ; Residual
  SolnArr[i,11] = totalchisq                                    ; The total chi-squared value (See MPFIT documentation)
  SolnArr[i,12] = dof                                           ; The number of degrees of freedom
  SolnArr[i,13] = chisqred                                      ; The reduced chi-squared
  SolnArr[i,14] = AIC                                           ; The AIC value
ENDFOR

;------------------------------------------------------------------------------;
RETURN, SolnArr


END