;+
;
; PROGRAM NAME:
;   PRESENT ALTERNATIVES
;
; PURPOSE:
;   presents the user with alternative solutions 
;
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-

PRO PRESENT_SOLUTIONS, x, y, SolnArr, SolnArr_alt, IndArr_alt, uniq_indx, velrange
Compile_Opt idl2

;------------------------------------------------------------------------------;
;
;------------------------------------------------------------------------------;

; Print the current solution
PRINT, ''
PRINT,';------------------------------------------------------------------------------;'
PRINT, '; CURRENT SOLUTION'
print, ';------------------------------------------------------------------------------;'
PRINT, ''
PRINT, 'Reduced chi-Squared value: ', SolnArr[0,13]
PRINT, 'AIC value:                 ', SolnArr[0,14]
PRINT, ''

FOR i = 0, N_ELEMENTS(SolnArr[*,0])-1 DO BEGIN
  PRINT, ''
  PRINT, 'Intensity: ', STRING(SolnArr[i,3], format = '(F10.3)'), ' +/-', $
          STRING(SolnArr[i,4], format = '(F10.3)')
  PRINT, 'Centroid:  ', STRING(SolnArr[i,5], format = '(F10.3)'), ' +/-', $
          STRING(SolnArr[i,6], format = '(F10.3)')
  PRINT, 'Linewidth: ', STRING(SolnArr[i,7], format = '(F10.3)'),' +/-', $
          STRING(SolnArr[i,8], format = '(F10.3)')
  PRINT, ''
ENDFOR

IF TOTAL(SolnArr_alt) NE -1 THEN BEGIN

  PRINT, ''
  PRINT, ';------------------------------------------------------------------------------;'
  PRINT, '; ALTERNATIVE SOLUTIONS'
  print, ';------------------------------------------------------------------------------;'

  
  FOR i = 0, N_ELEMENTS(WHERE(uniq_indx NE -1))-1 DO BEGIN
    

    ID = WHERE(SolnArr_alt[*,11] EQ SolnArr_alt[uniq_indx[i],11])

    PRINT, ''
    PRINT, 'Reduced chi-Squared value: ', SolnArr_alt[ID[0],13]
    PRINT, 'AIC value:                 ', SolnArr_alt[ID[0],14]
    PRINT, ''

    FOR j = 0, N_ELEMENTS(ID)-1 DO BEGIN
      PRINT, ''
      PRINT, 'Intensity: ', STRING(SolnArr_alt[ID[j],3], format = '(F10.3)'), ' +/-', $
              STRING(SolnArr_alt[ID[j],4], format = '(F10.3)')
      PRINT, 'Centroid:  ', STRING(SolnArr_alt[ID[j],5], format = '(F10.3)'), ' +/-', $
              STRING(SolnArr_alt[ID[j],6], format = '(F10.3)')
      PRINT, 'Linewidth: ', STRING(SolnArr_alt[ID[j],7], format = '(F10.3)'),' +/-', $
              STRING(SolnArr_alt[ID[j],8], format = '(F10.3)')
      PRINT, ''
    ENDFOR
    PRINT,';------------------------------------------------------------------------------;'
  ENDFOR

  ; Plot the current solution and the alternatives

  grid = PLOT_SOLUTION_GRID( SolnArr, SolnArr_alt, indArr_alt, uniq_indx, x, y, velrange )

ENDIF ELSE BEGIN
  PRINT, ''
  PRINT, 'No alternative solutions available.'
  PRINT, ''
  
  grid = PLOT_SOLUTION_GRID( SolnArr, SolnArr_alt, indArr_alt, uniq_indx, x, y, velrange )
  
ENDELSE


END