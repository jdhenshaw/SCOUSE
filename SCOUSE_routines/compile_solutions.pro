;+
;
; PROGRAM NAME:
;   COMPILE SOLUTIONS
;
; PURPOSE:
;   Compiles all best-fitting solutions
;
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-

PRO COMPILE_SOLUTIONS, Dir, InFile, OutFile
Compile_Opt idl2

;------------------------------------------------------------------------------;
;
;------------------------------------------------------------------------------;

READCOL, InFile, covx, covy, nlines=ncov, /silent
OPENW, 1, OutFile, width = 200
CLOSE, 1
FOR i = 0, ncov-1 DO BEGIN
  SolnArr      = 0.0
  File=Dir+'indiv_solutions_'+string(i,format='(I03)')+'.dat'  
  READCOL, File, n, xpos, ypos, int, sint, vel, svel, fwhm, sfwhm, rms, resid, totchisq, dof, chisqred, AIC, nlines=nfits, /silent
  SolnArr      = [[n],[xpos],[ypos],[int],[sint],[vel],[svel],[fwhm],[sfwhm],[rms],[resid],[totchisq],[dof],[chisqred],[AIC]]             
  OUTPUT_INDIV_SOLUTION, SolnArr, OutFile           
ENDFOR

;------------------------------------------------------------------------------;

END