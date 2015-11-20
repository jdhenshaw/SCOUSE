;+
;
; PROGRAM NAME:
;   REORDER SOLUTIONS
;
; PURPOSE:
;   Reorders all best-fitting solutions
;
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-

PRO REORDER_SOLUTIONS, InFile, InfoFile, OutFile
Compile_Opt idl2

;------------------------------------------------------------------------------;
;
;------------------------------------------------------------------------------;

READCOL,  InfoFile, xpos, ypos, xindx, yindx, combindx, nlines=npos, /silent
indArr  = [[xpos], [ypos], [xindx], [yindx], [combindx]]
READCOL,  InFile, n, xpos, ypos, int, sint, vel, svel, fwhm, sfwhm, rms, resid, totchisq, dof, chisqred, AIC, nlines=nfits, /silent
SolnArr = [[n],[xpos],[ypos],[int],[sint],[vel],[svel],[fwhm],[sfwhm],[rms],[resid],[totchisq],[dof],[chisqred],[AIC]]
          
OPENW, 1, OutFile, width = 200
CLOSE, 1
FOR i = 0, N_ELEMENTS(indArr[*,0])-1 DO BEGIN 
  ID_pos = WHERE(SolnArr[*,1] EQ indArr[i,0] AND SolnArr[*,2] EQ indArr[i,1]) 
  IF ID_pos[0] NE -1.0 THEN BEGIN 
    SolnArr_trim = SolnArr[ID_pos, *]
    OUTPUT_INDIV_SOLUTION, SolnArr_trim, OutFile    
  ENDIF 
ENDFOR

;------------------------------------------------------------------------------;
END