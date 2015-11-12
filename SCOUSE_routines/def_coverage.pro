FUNCTION def_coverage, momzero, x_axis, y_axis, rsaa, moment_zero_ascii, $
                       coverage_ascii
;------------------------------------------------------------------------------;
; Copyright (c) 2015 Jonathan D. Henshaw
; CONTACT: j.d.henshaw@ljmu.ac.uk
;
; PROGRAM NAME:
;   DEF COVERAGE
;
; PURPOSE:
;   This program defines and creates the coverage 
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;------------------------------------------------------------------------------;
Compile_Opt idl2
;------------------------------------------------------------------------------;
; DEFINE THE COVERAGE
;------------------------------------------------------------------------------;

; Start by defining the minimium and maximum extent of the zeroth moment, i.e. 
; where this is ne 0.0. This gives the coordinates of a box enclosing all 
; non-zero moment positions.

READCOL, moment_zero_ascii, xpos, ypos, mom_values, /silent

xlower = MIN(xpos[WHERE(mom_values NE 0.0)]) 
xupper = MAX(xpos[WHERE(mom_values NE 0.0)])
ylower = MIN(ypos[WHERE(mom_values NE 0.0)])
yupper = MAX(ypos[WHERE(mom_values NE 0.0)])

; Define the spacing.

spacing = rsaa/2.0

; Identify the number of SAAs within this box by dividing the minimum and 
; maximum extent of the ra and dec by the user-defined radius.

nposx = ROUND(ABS(xupper-xlower)/rsaa)+1.0
nposy = ROUND(ABS(yupper-ylower)/rsaa)+1.0

; Calculate the absolute location of the SAAs. 

cov_x = xupper-rsaa*FINDGEN(nposx)
cov_y = ylower+rsaa*FINDGEN(nposy)

;------------------------------------------------------------------------------;
; Now remove all SAAs where 50% or more pixels are = 0.0 

nareas=0.0

OPENW, 1, coverage_ascii
FOR i = 0, nposx-1 DO BEGIN
  FOR j = 0, nposy-1 DO BEGIN
    
    ; Identify all the positions within the SAA

    ID_ra = WHERE(x_axis GT (cov_x[i]-spacing) AND x_axis LT (cov_x[i]+spacing))
    ID_dec= WHERE(y_axis GT (cov_y[j]-spacing) AND y_axis LT (cov_y[j]+spacing))

    ; Identify how many of those positions have non zero integrated intensity

    IF ID_ra[0] NE -1 AND ID_dec[0] NE -1 THEN BEGIN
      ID=WHERE(momzero[MIN(ID_ra):MAX(ID_ra), MIN(ID_dec):MAX(ID_dec)] NE 0.0,c)      
      IF c NE 0.0 THEN tot_non_zero = N_ELEMENTS(ID) ELSE tot_non_zero = 0.0
      
      ; Calculate the fraction of positions with non zero integrated intensity
      
      fraction = tot_non_zero/(N_ELEMENTS(ID_ra)*N_ELEMENTS(ID_dec))
      
      ; If this fraction > 50 % then accept the SAA into the coverage
      
      IF fraction GT 0.5 THEN BEGIN
        PRINTF, 1, cov_x[i], cov_y[j], format = '(2(F12.5,x))'
        nareas++
      ENDIF
    ENDIF
  ENDFOR
ENDFOR
CLOSE,1

;------------------------------------------------------------------------------;
; END PROCESS
;------------------------------------------------------------------------------;

RETURN, nareas

END