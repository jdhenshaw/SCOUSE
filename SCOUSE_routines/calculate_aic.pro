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

FUNCTION CALCULATE_AIC, n, x, totalchisq
Compile_Opt idl2

;------------------------------------------------------------------------------;

nvel    = N_ELEMENTS(x)
nparams = n*3.0
AIC     = totalchisq+2.0*nparams+((2.0*nparams*(nparams+1.0))/(nvel-nparams-1.0))

;------------------------------------------------------------------------------;
RETURN, AIC

END