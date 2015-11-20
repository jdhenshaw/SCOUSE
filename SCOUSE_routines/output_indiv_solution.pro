;+
;
; PROGRAM NAME:
;   OUTPUT SAA SOLUTION
;
; PURPOSE:  
;   Output the best-fitting solution to the current spectrum
;   
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-

PRO OUTPUT_INDIV_SOLUTION, SolnArr, OutFile
Compile_Opt idl2

;------------------------------------------------------------------------------;
; OUTPUT SOLUTIONS
;------------------------------------------------------------------------------;

; Write to output file

OPENW,1, OutFile, width = 200, /append
FOR i = 0, N_ELEMENTS(SolnArr[*,0])-1 DO BEGIN
    PRINTF,1, SolnArr[i,0],$
              SolnArr[i,1],SolnArr[i,2],$
              SolnArr[i,3],SolnArr[i,4],$
              SolnArr[i,5],SolnArr[i,6],$
              SolnArr[i,7],SolnArr[i,8],$
              SolnArr[i,9],SolnArr[i,10],$
              SolnArr[i,11],SolnArr[i,12],SolnArr[i,13],SolnArr[i,14],$
              format = '((F10.2, x), 14(F12.5, x))'
ENDFOR
CLOSE,1

;------------------------------------------------------------------------------;


END