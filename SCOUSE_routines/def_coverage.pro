;+
;
; PROGRAM NAME:
;   DEF COVERAGE
;
; PURPOSE:
;   This program defines and creates the coverage 
;   
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-

FUNCTION def_coverage, x, y, momzero, radius, OutFile
Compile_Opt idl2

;------------------------------------------------------------------------------;
; DEFINE THE COVERAGE
;------------------------------------------------------------------------------;

; Start by defining the minimium and maximum extent of the zeroth moment

ID = WHERE(momzero NE 0.0)
indices = ARRAY_INDICES(momzero, ID)

xrange = [x[MIN(indices[0,*])],x[MAX(indices[0,*])]]
yrange = [y[MIN(indices[1,*])], y[MAX(indices[1,*])]]

; Define the spacing.

spacing = radius/2.0

; Identify the number of SAAs within this region

nposx = ROUND(ABS(MAX(xrange)-MIN(xrange))/radius)+1.0
nposy = ROUND(ABS(MAX(yrange)-MIN(yrange))/radius)+1.0

; Calculate the absolute location of the SAAs. 

cov_x = MAX(xrange)-radius*FINDGEN(nposx)
cov_y = MIN(yrange)+radius*FINDGEN(nposy)

;------------------------------------------------------------------------------;
; Now remove all SAAs where 50% or more pixels are = 0.0 

nareas=0.0

OPENW, 1, OutFile
FOR i = 0, nposx-1 DO BEGIN
  FOR j = 0, nposy-1 DO BEGIN
    
    ; Identify all the positions within the SAA

    ID_ra = WHERE(x GT (cov_x[i]-spacing) AND x LT (cov_x[i]+spacing))
    ID_dec= WHERE(y GT (cov_y[j]-spacing) AND y LT (cov_y[j]+spacing))

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


RETURN, nareas

END