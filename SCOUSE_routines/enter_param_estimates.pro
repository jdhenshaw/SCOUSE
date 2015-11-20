;+
;
; PROGRAM NAME:
;   ENTER PARAM ESTIMATES
;
; PURPOSE:
;   An interactive program. The user needs to provide the number of Gaussians
;   and estimates for the intensity, centroid velocity, and FWHM line width.
;   
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-

FUNCTION ENTER_PARAM_ESTIMATES
Compile_Opt idl2

;------------------------------------------------------------------------------;
; Fit the Gaussian(s)                                                                                                                ;
;------------------------------------------------------------------------------;

PRINT, ''
n = ''
READ, n, prompt = 'Enter number of Gaussians to fit: '

;-----------------------------------------------------------------------------;
; ENTER PARAMETER GUESSES
;-----------------------------------------------------------------------------;


IF n EQ 0 THEN BEGIN

  parameter_estimates = [0.0,0.0,0.0]

ENDIF ELSE BEGIN

  ; Create an array to contain the users initial guesses to the average spectrum
  
  estimate_array = REPLICATE(0d0, n,3)

  intensity = REPLICATE(0d0,n)
  centroid  = REPLICATE(0d0,n)
  width     = REPLICATE(0d0,n)

  ; Create new array with correct order for mpfitfun

  parameter_estimates = REPLICATE(0d0, N_ELEMENTS(estimate_array[*,0])*N_ELEMENTS(estimate_array[0,*]))
  
  PRINT, ''
  PRINT, 'Entering guesses for average spectrum...'
  PRINT, ''

  FOR k = 0, (n)-1 DO BEGIN

    ; Entering initial Guesses

    int  = ''
    cent = ''
    wid  = ''
    READ, int,  prompt = 'Enter Intensity: '
    READ, cent, prompt = 'Enter Centroid: '
    READ, wid,  prompt = 'Enter Width: '
    PRINT, ''

    intensity[k] = int
    centroid[k]  = cent
    width[k]     = wid

    ; Fill the array

    estimate_array[k,0] = intensity[k]
    estimate_array[k,1] = centroid[k]
    estimate_array[k,2] = width[k]

  ENDFOR

  FOR i = 0, N_ELEMENTS(estimate_array[*,0])-1 DO BEGIN
    FOR j = 0, N_ELEMENTS(estimate_array[0,*])-1 DO BEGIN
      parameter_estimates[j+i*N_ELEMENTS(estimate_array[0,*])]=estimate_array[i,j]
    ENDFOR
  ENDFOR
  
ENDELSE

;------------------------------------------------------------------------------;
RETURN, parameter_estimates

END
