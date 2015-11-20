;+
;
; PROGRAM NAME:
;   DEF COVERAGE
;
; PURPOSE:
;   This program defines and creates the coverage. 
;   
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-

PRO DEF_COVERAGE, x, y, momzero, radius, OutFile, nareas=nareas
Compile_Opt idl2

;------------------------------------------------------------------------------;
; DEFINE THE COVERAGE
;------------------------------------------------------------------------------;

ID      = WHERE(momzero NE 0.0)
indices = ARRAY_INDICES(momzero, ID)
xrange  = [x[MIN(indices[0,*])], x[MAX(indices[0,*])]]    ; range in x of moment zero
yrange  = [y[MIN(indices[1,*])], y[MAX(indices[1,*])]]    ; range in y of moment zero
spacing = radius/2.0

nposx   = ROUND(ABS(MAX(xrange)-MIN(xrange))/radius)+1.0  ; Number of SAAs within xrange
nposy   = ROUND(ABS(MAX(yrange)-MIN(yrange))/radius)+1.0  ; Number of SAAs within yrange
cov_x   = MAX(xrange)-radius*FINDGEN(nposx)               ; x location of SAAs
cov_y   = MIN(yrange)+radius*FINDGEN(nposy)               ; x location of SAAs

nareas  = 0.0
OPENW, 1, OutFile  
FOR i = 0, nposx-1 DO BEGIN
  FOR j = 0, nposy-1 DO BEGIN  

    ID_ra  = WHERE(x GT (cov_x[i]-spacing) AND x LT (cov_x[i]+spacing))           ; Identify positions within each SAA
    ID_dec = WHERE(y GT (cov_y[j]-spacing) AND y LT (cov_y[j]+spacing))

    IF ID_ra[0] NE -1 AND ID_dec[0] NE -1 THEN BEGIN
      ID=WHERE(momzero[MIN(ID_ra):MAX(ID_ra), MIN(ID_dec):MAX(ID_dec)] NE 0.0, c) ; Identify where these positions are non zero     
      IF c NE 0.0 THEN tot_non_zero = FLOAT(c) ELSE tot_non_zero = 0.0      
      fraction = tot_non_zero/FLOAT((N_ELEMENTS(ID_ra)*N_ELEMENTS(ID_dec)))       ; Calculate the fraction of non-zero components
      IF fraction GE 0.5 THEN BEGIN
        PRINTF, 1, cov_x[i], cov_y[j], format = '(2(F12.5,x))'                    ; If this fraction > 50% then retain that coordinate
        nareas++
      ENDIF
    ENDIF
  ENDFOR
ENDFOR
CLOSE,1

;------------------------------------------------------------------------------;


END