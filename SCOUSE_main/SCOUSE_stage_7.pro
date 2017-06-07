;+
;
; SCOUSE - Semi-automated multi-COmponent Universal Spectral-line fitting Engine
; Copyright (c) 2015 Jonathan D. Henshaw
; CONTACT: j.d.henshaw[AT]ljmu.ac.uk
; 
; PROGRAM NAME:
;   SCOUSE - STAGE 7 
;   
; PURPOSE:
;   This program takes the re-fitted data from stage 6 and integrates these new 
;   fits into the solution file. This produces the final solution file.
;   
; OUTPUT:
; 
;   final_solns_updated.dat - The file containing the final (updated) best-
;     fitting solutions. 
;
;------------------------------------------------------------------------------;
;
; TERMS OF USE:
;   If you use SCOUSE for the analysis of molecular line data, please cite the
;   paper in which it is presented: Henshaw et al. (2016).
;
;   If it is the first time you have used SCOUSE, J. D. Henshaw would appreciate
;   being involved in the project to provide assistance where necessary.
;   However, this is not required and you are free to use these routines as you
;   see fit.
;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;
;-

PRO SCOUSE_STAGE_7
Compile_Opt idl2

;------------------------------------------------------------------------------;
; USER INPUT
;------------------------------------------------------------------------------;

datadirectory = ''  
filename      = ''               ; The data cube to be analysed
fitsfile      = filename+'.fits' ; fits extension
OutFile       = datadirectory+filename+'/STAGE_7/final_solns_updated.dat'

;------------------------------------------------------------------------------;
; FILE INPUT
;------------------------------------------------------------------------------;

coordfile     = datadirectory+filename+'/MISC/coords_coverage.dat'
final_solns   = datadirectory+filename+'/STAGE_4/final_solns.dat'
alt_solns     = datadirectory+filename+'/STAGE_6/alternative_solutions_1.dat'

;------------------------------------------------------------------------------;
;
;------------------------------------------------------------------------------;

READCOL, coordfile, x, y, xindx, yindx, combindx, nlines=nlines, /silent
READCOL, final_solns, n, xpos, ypos, int, sint, vel, svel, fwhm, sfwhm, rms, resid, totchisq, dof, chisqred, AIC, nlines = ncomps, /silent
READCOL, alt_solns, n_alt, xpos_alt, ypos_alt, int_alt, sint_alt, vel_alt, svel_alt, fwhm_alt, sfwhm_alt, rms_alt, resid_alt, totchisq_alt, dof_alt, chisqred_alt, AIC_alt, /silent                  
OPENW,1, OutFile, width=100 ; Prepare the output file
CLOSE,1                     
       
;------------------------------------------------------------------------------;
; BEGIN ANALYSIS
;------------------------------------------------------------------------------;

PRINT, ''
PRINT, 'Beginning analysis...'
PRINT, ''
JOURNAL, datadirectory+filename+'/MISC/stagesseven_log.dat'
starttime = SYSTIME(/seconds)

;==============================================================================;
; MAIN ROUTINE
;==============================================================================;

indArr         = [[x], [y], [xindx], [yindx], [combindx]]
SolnArr        = [[n],[xpos],[ypos], [int], [sint], [vel],[svel],[fwhm],[sfwhm],[rms],[resid],[totchisq],[dof],[chisqred],[AIC]]
SolnArr_alt    = [[n_alt],[xpos_alt],[ypos_alt],[int_alt],[sint_alt],[vel_alt],[svel_alt],[fwhm_alt],[sfwhm_alt],[rms_alt],[resid_alt],[totchisq_alt],[dof_alt],[chisqred_alt],[AIC_alt]]

FOR i = 0, N_ELEMENTS(IndArr[*,0])-1 DO BEGIN  
  
  ID_soln      = WHERE(SolnArr[*,1] EQ IndArr[i, 0] AND SolnArr[*,2] EQ IndArr[i, 1])              
  ID_soln_alt  = WHERE(SolnArr_alt[*,1] EQ IndArr[i, 0] AND SolnArr_alt[*,2] EQ IndArr[i, 1])  
  IF ID_soln_alt[0] NE -1.0 THEN SolnArr_final=SolnArr_alt[ID_soln_alt,*] ELSE SolnArr_final=SolnArr[ID_soln,*]     
  OUTPUT_INDIV_SOLUTION, SolnArr_final, OutFile 
  
ENDFOR

READCOL, OutFile, n, xpos, ypos, int, sint, vel, svel, fwhm, sfwhm, rms, resid, totchisq, dof, chisqred, AIC, nlines = ncomps, /silent
SolnArr_final = [[n],[xpos],[ypos], [int], [sint], [vel],[svel],[fwhm],[sfwhm],[rms],[resid],[totchisq],[dof],[chisqred],[AIC]]   
           
;-----------------------------------------------------------------------------;
HELP, SolnArr
HELP, SolnArr_final
FILE_COPY, OutFile, OutFile+'.backup'
endtime = (SYSTIME(/second)-starttime)/60.0
PRINT, ''
PRINT, 'Time taken: ', endtime, ' minutes.'
PRINT, ''

JOURNAL

END