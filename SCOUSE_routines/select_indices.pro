;+
;
; PROGRAM NAME:
;   SELECT INDICES
;
; PURPOSE:
;   User interactive program. The user is to input the indices of spectra they
;   wish to revisit (either to find an alternative solution or to refit 
;   entirely)
;
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-

PRO SELECT_INDICES, SolnArr, IndArr_trim, OutFile
Compile_Opt idl2

;------------------------------------------------------------------------------;

ind = ''
OPENW,1, OutFile, /append
PRINT, ''
WHILE ind NE -1 DO BEGIN
  READ, ind, prompt = 'Enter index (enter -1 when finished): '  
  ID = WHERE(IndArr_trim[*, 4] EQ ind)
  IF ind[0] NE -1.0 AND ID[0] NE -1.0 THEN BEGIN
    PRINTF, 1, IndArr_trim[ID,0], IndArr_trim[ID,1], IndArr_trim[ID,2], IndArr_trim[ID,3], IndArr_trim[ID,4], format='(5(F12.5, x))'
  ENDIF
ENDWHILE
PRINT, ''
CLOSE,1

;------------------------------------------------------------------------------;

END