;+
;
; PROGRAM NAME:
;   FINAL SOLUTIONS
;
; PURPOSE:
;   Minimises the AIC value to attain the final best-fitting solutions, also
;   creates a file of unique alternatives to the best fitting solution. This
;   will be used in a latter stage of the process.
;
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-

FUNCTION FINAL_SOLUTIONS, InFile, Infofile, OutFile1, OutFile2
Compile_Opt idl2

;------------------------------------------------------------------------------;
;
;------------------------------------------------------------------------------;

READCOL, InfoFile, xpos, ypos, xindx, yindx, combindx, nlines=npos, /silent
indArr = [[xpos], [ypos], [xindx], [yindx], [combindx]]
READCOL, InFile, n, xpos, ypos, int, sint, vel, svel, fwhm, sfwhm, rms, resid, totchisq, dof, chisqred, AIC, nlines=nfits, /silent
SolnArr = [[n],$
           [xpos],[ypos],$
           [int],[sint],$
           [vel],[svel],$
           [fwhm],[sfwhm],$
           [rms],[resid],$
           [totchisq],[dof],[chisqred],[AIC]]
  
OPENW, 1, OutFile1, width = 200
CLOSE, 1
OPENW, 1, OutFile2, width = 200
CLOSE, 1

FOR i = 0, N_ELEMENTS(indArr[*,0])-1 DO BEGIN
  
  SolnArr_trim = 0.0
  ID_pos = WHERE(SolnArr[*,1] EQ indArr[i,0] AND SolnArr[*,2] EQ indArr[i,1])
  
  IF ID_pos[0] NE -1.0 THEN BEGIN
    
    SolnArr_trim = SolnArr[ID_pos, *]
    
    ; Best fits are those with the minimum AIC   
    SolnArr_min_AIC = SolnArr_trim[WHERE(SolnArr_trim[*,14] EQ MIN(SolnArr_trim[*,14])),*]
    output_solns = OUTPUT_INDIV_SOLUTION( SolnArr_min_AIC, OutFile1 )  
    ; Create a file to contain unique alternative solutions
    
    SolnArr_alt = SolnArr_trim[WHERE(SolnArr_trim[*,14] NE MIN(SolnArr_trim[*,14])), *]
    output_solns = OUTPUT_INDIV_SOLUTION( SolnArr_alt, OutFile2 )  
    
  ENDIF
ENDFOR


;------------------------------------------------------------------------------;

END