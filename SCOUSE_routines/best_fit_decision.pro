;+
;
; PROGRAM NAME:
;   DECISION
;
; PURPOSE:
;   Interactive program establishing if the user wishes to keep the current
;   solution, use an alternative, or refit entirely.
;
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-

FUNCTION BEST_FIT_DECISION, indx, IndArr_alt, uniq_indx, decision_array
Compile_Opt idl2

;------------------------------------------------------------------------------;
;
;------------------------------------------------------------------------------;

decision = ''
PRINT, ''
PRINT, ';------------------------------------------------------------------------------;'
PRINT, '; INSTRUCTIONS: Choose one of the following...
PRINT, ';
PRINT, '; To retain the current solution: Enter -1'
PRINT, '; To accept a unique alternative: Enter available a-i'
PRINT, '; To refit the spectrum manually: Enter nothing'
PRINT, ';------------------------------------------------------------------------------;'
PRINT, ''
READ, decision, PROMPT='Enter decision: '
PRINT, ''

alt_choices = ['a','b','c','d','e','f','g','h','i']

ID_uniq     = WHERE(uniq_indx NE -1)
IF ID_uniq[0] EQ -1 THEN maxnumUniq = 0.0 ELSE maxnumUniq = N_ELEMENTS(ID_uniq)
ID_choice   = WHERE(decision EQ alt_choices)

IF decision EQ -1 THEN BEGIN
  decision_array[indx,0]=0.0
  PRINT, ''
  PRINT, 'You have chosen to retain the current solution'
  PRINT, ''
ENDIF ELSE BEGIN
  IF ID_choice[0] NE -1 AND ID_choice[0]+1 LE maxnumUniq THEN BEGIN
    decision_array[indx,1] = uniq_indx[ID_choice[0]]
    PRINT, ''
    PRINT, 'You have chosen to select an alternative solution'
    PRINT, ''
  ENDIF ELSE BEGIN
    decision_array[indx,2] = 0.0
    PRINT, ''
    PRINT, 'You have chosen to refit manually'
    PRINT, ''
  ENDELSE
ENDELSE

;------------------------------------------------------------------------------;
RETURN, decision_array

END