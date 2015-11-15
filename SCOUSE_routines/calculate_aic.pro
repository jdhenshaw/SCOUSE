;
;+
;
; PROGRAM NAME:
;   CALCULATE AIC
;
; PURPOSE:
;   Calculates the Akaike Information Criterion (AIC) for the current fit
;   
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-

FUNCTION calculate_AIC, n, x, totchisq
Compile_Opt idl2

;------------------------------------------------------------------------------;

nvel = n_elements(x)
nparams = n*3.0
AIC = totchisq+2.0*nparams+((2.0*nparams*(nparams+1.0))/(nvel-nparams-1.0))

;------------------------------------------------------------------------------;
return, AIC

END