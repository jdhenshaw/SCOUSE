FUNCTION OUTPUT_SAA_SOLUTION, indx, SolnArr, x, ResArr, outputdatafile
;------------------------------------------------------------------------------;
; PROGRAM NAME:
;   OUTPUT SAA SOLUTION
;
; PURPOSE:  
;   Output the best-fitting solution to the current SAA
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;------------------------------------------------------------------------------;
Compile_Opt idl2
;------------------------------------------------------------------------------;
; OUTPUT SOLUTIONS
;------------------------------------------------------------------------------;

; Write to output file

OPENW,1, outputdatafile, width = 200, /append
FOR i = 0, N_ELEMENTS(SolnArr[*,0])-1 DO BEGIN
    PRINTF,1, SolnArr[i,0],$
              SolnArr[i,1],SolnArr[i,2],$
              SolnArr[i,3],SolnArr[i,4],$
              SolnArr[i,5],SolnArr[i,6],$
              SolnArr[i,7],SolnArr[i,8],$
              SolnArr[i,9],SolnArr[i,10],SolnArr[i,11],$
              SolnArr[i,12],SolnArr[i,13],$
              format = '((F10.2, x), 2(F12.5, x), 11(F10.3, x))'
ENDFOR
CLOSE,1

;------------------------------------------------------------------------------;
; END PROCESS
;------------------------------------------------------------------------------;

END

;------------------------------------------------------------------------------;
; PRINT RESIDUALS
;------------------------------------------------------------------------------;

;OPENW,1, datadirectory+filename+'/STAGE_2/SAA_residuals/residual_'+string(indx, format = '(I03)')+'.dat'
;FOR j = 0, N_ELEMENTS(ResArr)-1 DO BEGIN
;  PRINTF, 1, x[j], ResArr[j]
;ENDFOR
;CLOSE,1

;-----------------------------------------------------------------------------;


;-----------------------------------------------------------------------------;
; CREATE FIGURES
;-----------------------------------------------------------------------------;

;printing = 'no'
;
;PRINT, ''
;READ, printing, PROMPT = 'Would you like to create a hard copy of this fit (yes/no)? '
;
;IF printing EQ 'yes' THEN screenDump = cgSnapshot(filename=datadirectory+filename+'/FIGURES/best_fit_spec_'+string(indx, format = '(I03)'), /jpeg)
;
