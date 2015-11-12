FUNCTION ENTER_PARAM_ESTIMATES, X, Y, xpos, ypos, rms, n = n             
;------------------------------------------------------------------------------;
; PROGRAM NAME:
;   ENTER PARAM ESTIMATES
;
; PURPOSE:
;   Here the user enters the number of gaussian components to fit. 
;   This program creates the arrays that will be passed into the fitting 
;   procedure
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;------------------------------------------------------------------------------;
Compile_Opt idl2
;------------------------------------------------------------------------------;
; Fit the Gaussian(s)                                                                                                                ;
;------------------------------------------------------------------------------;

print, ''
read, n, prompt = 'Enter number of Gaussians to fit: '

;-----------------------------------------------------------------------------;
; ENTER PARAMETER GUESSES
;-----------------------------------------------------------------------------;


IF n EQ 0 THEN BEGIN
  
  param_estimates = [0.0,0.0,0.0]

ENDIF ELSE BEGIN

  ; Create an array to contain the users initial guesses to the average spectrum
  
  estimate_array = REPLICATE(0.d, n,3)

  intensity = REPLICATE(0.d,n)
  centroid  = REPLICATE(0.d,n)
  width     = REPLICATE(0.d,n)

  ; Create new array with correct order for mpfitfun

  param_estimates = REPLICATE(0.d, N_ELEMENTS(estimate_array[*,0])*N_ELEMENTS(estimate_array[0,*]))
  
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
      param_estimates[j+i*N_ELEMENTS(estimate_array[0,*])]=estimate_array[i,j]
    ENDFOR
  ENDFOR
  
ENDELSE

;------------------------------------------------------------------------------;
; END PROCESS
;------------------------------------------------------------------------------;

RETURN, param_estimates

END
