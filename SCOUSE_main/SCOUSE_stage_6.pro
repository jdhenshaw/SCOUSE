;+
;
; SCOUSE - Semi-automated multi-COmponent Universal Spectral-line fitting Engine
; Copyright (c) 2015 Jonathan D. Henshaw
; CONTACT: j.d.henshaw[AT]ljmu.ac.uk
; 
; PROGRAM NAME:
;   SCOUSE - STAGE 6
;   
; PURPOSE:
;   This program takes a closer look at those spectra identified during stage 5.
;   The user can retain the current solution, select an alternative, or refit
;   entirely.
;
; USAGE:
;
;   SCOUSE requires a .fits file as input. The spectral axis should be in
;   velocity units. 
;  
; OUTPUT:
; 
;   alternative_solutions.dat - A file containing the alternative solutions to
;     the spectra identified in stage 5. 
;   
; NOTES:
; 
;   As with stage 5, this process is user interactive. The program will cycle 
;   through all of the spectra identified in stage 5. For each spectrum, the
;   current solution, as well as all available alternatives is displayed. 
;   
;   To retain the current solution: Enter '-1'
;   To choose an alternative:       Choose one of a,b,c,d...
;   To refit entirely:              Enter nothing 
;   
;   If the user enters nothing and decides to refit, the refitting process will
;   begin immediately.
;   
;   Once again, given that this process is quite user intensive, it is easier
;   to progress in stages. Altering nlower and nupper will allow the user to 
;   do this. 
;   
;   However, ***performing the task in this way will require the user to provide
;   unique filenames such that they are not overwritten. Following the completion 
;   of the process the user will then have to manually compile the fits into a 
;   single file for use with the next stage of the process.***
; 
;------------------------------------------------------------------------------;
;
; TERMS OF USE:
;   If you use SCOUSE for the analysis of molecular line data, please cite the
;   paper in which it is presented: Henshaw et al., 2015 (submitted)
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

PRO SCOUSE_STAGE_6
Compile_Opt idl2

;------------------------------------------------------------------------------;
; USER INPUT
;------------------------------------------------------------------------------;

datadirectory = ''  
filename      = ''                                                            ; The data cube to be analysed
fitsfile      = filename+'.fits' ; fits extension
vunit         = 1000.0                                                        ; if FITS header has units of m/s; conv from m/s to km/s
velrange      = [0.0, 0.0]                                                    ; range over which to plot spectra
IndxFile      = datadirectory+filename+'/STAGE_5/check_spec_indxfile.dat'     ; The input indices file
OutFile       = datadirectory+filename+'/STAGE_6/alternative_solutions_1.dat' ; This needs to be updated
JOURNAL,        datadirectory+filename+'/MISC/stagesix_1_log.dat'             ; This needs to be updated
nlines        = NUMLINES(IndxFile)
nlower        = 0                                                             ; Lower spectrum index
nupper        = nlines-1                                                      ; Upper spectrum index. Change to "nlines-1" to go through all spectra at once

;------------------------------------------------------------------------------;
; FILE INPUT AND AXES CREATION
;------------------------------------------------------------------------------;

input_file    = datadirectory+filename+'/MISC/inputs.dat'
coordfile     = datadirectory+filename+'/MISC/coords_coverage.dat'
alt_solns     = datadirectory+filename+'/STAGE_4/alt_solns.dat'
final_solns   = datadirectory+filename+'/STAGE_4/final_solns.dat'

;------------------------------------------------------------------------------;
; 
;------------------------------------------------------------------------------;

image  = FILE_READ( datadirectory, fitsfile, x=x_axis, y=y_axis, z=z_axis, header=HDR_DATA )               
z_axis = z_axis/vunit
data   = FILE_PREPARATION( image, x_axis, y_axis, z_axis, HDR_DATA, input_file, vunit, image_rms=data_rms, z_rms=z_axis_rms,header_new=HDR_NEW ) 
READCOL, coordfile, x, y, xindx, yindx, combindx, /silent
READCOL, IndxFile,  x_alt, y_alt, xindx_alt, yindx_alt, combindx_alt, /silent
READCOL, final_solns, n, xpos, ypos, int, sint, vel, svel, fwhm, sfwhm, rms, resid, totchisq, dof, chisqred, AIC, nlines = ncomps, /silent
READCOL, alt_solns, n_alt, xpos_alt, ypos_alt, int_alt, sint_alt, vel_alt, svel_alt, fwhm_alt, sfwhm_alt, rms_alt, resid_alt, totchisq_alt, dof_alt, chisqred_alt, AIC_alt, /silent
OPENW,1, OutFile, width=100 ;Prepare the output file
CLOSE,1

;------------------------------------------------------------------------------;
; BEGIN ANALYSIS
;------------------------------------------------------------------------------;

PRINT, ''
PRINT, 'Beginning analysis...'
PRINT, ''
starttime = SYSTIME(/seconds)

;------------------------------------------------------------------------------;
;
;------------------------------------------------------------------------------;

indArr         = [[x], [y], [xindx], [yindx], [combindx]]
indArr_alt     = [[x_alt], [y_alt], [xindx_alt], [yindx_alt], [combindx_alt]]
SolnArr        = [[n],[xpos],[ypos], [int], [sint], [vel],[svel],[fwhm],[sfwhm],[rms],[resid],[totchisq],[dof],[chisqred],[AIC]]
SolnArr_alt    = [[n_alt],[xpos_alt],[ypos_alt],[int_alt],[sint_alt],[vel_alt],[svel_alt],[fwhm_alt],[sfwhm_alt],[rms_alt],[resid_alt],[totchisq_alt],[dof_alt],[chisqred_alt],[AIC_alt]]
decision_array = REPLICATE(-1.0, N_ELEMENTS(IndArr_alt[*,0]),3)
x              = z_axis
x_rms          = z_axis_rms

;==============================================================================;
; MAIN ROUTINE
;==============================================================================;

FOR i = nlower, nupper  DO BEGIN 
 
  y           = GET_SPEC( data, x, indArr_alt[i,2], indArr_alt[i,3])
  y_rms       = GET_SPEC( data_rms, x_rms, indArr_alt[i,2], indArr_alt[i,3])    

  ID_soln     = WHERE(SolnArr[*,1] EQ IndArr_alt[i, 0] AND SolnArr[*,2] EQ IndArr_alt[i, 1])                        
  ID_soln_alt = WHERE(SolnArr_alt[*,1] EQ IndArr_alt[i, 0] AND SolnArr_alt[*,2] EQ IndArr_alt[i, 1])
  
  ; Trim the arrays and find unique alternative solutions
  SolnArr_trim = SolnArr[ID_soln, *]  
  IF ID_soln_alt[0] NE -1 THEN BEGIN    
    SolnArr_alt_trim = SolnArr_alt[ID_soln_alt, *]
    uniq_indx        = REPLICATE(-1, 9)
    uniqChisqIndx    = REM_DUP(SolnArr_alt_trim[*,11])
    uniqChisqIndx    = UniqChisqIndx[SORT(uniqChisqIndx)]   
    FOR j = 0, N_ELEMENTS(uniqChisqIndx)-1 DO uniq_indx[j]=uniqChisqIndx[j]    
  ENDIF ELSE BEGIN     
    SolnArr_alt_trim = -1
    uniq_indx        = REPLICATE(-1, 9)    
  ENDELSE     
  
  ; Present the current solution plus any unique alternatives
  PRESENT_SOLUTIONS, x, y, SolnArr_trim, SolnArr_alt_trim, IndArr_alt[i,*], uniq_indx, velrange  
  decision_array = BEST_FIT_DECISION( i, IndArr_alt[i,*], uniq_indx, decision_array )   
  
  ; Based on the decision the user will either retain the current solution, 
  ; accept an alternative, or refit entirely. 
  
  IF decision_array[i,0] NE -1.0 THEN BEGIN
    SolnArr_decision   = SolnArr_trim
    OUTPUT_INDIV_SOLUTION, SolnArr_decision, OutFile 
  ENDIF ELSE BEGIN
    IF decision_array[i,1] NE -1.0 THEN BEGIN
      SolnArr_decision = SolnArr_alt_trim[WHERE(SolnArr_alt_trim[*,11] EQ SolnArr_alt_trim[decision_array[i,1],11]),*]
      OUTPUT_INDIV_SOLUTION, SolnArr_decision, OutFile 
    ENDIF ELSE BEGIN
      n=''
      SolnArr_decision = FIT_MANUAL( x, x_rms, y, y_rms, REPLICATE(SolnArr_trim[0,9], N_ELEMENTS(x)), IndArr_alt[i,0], IndArr_alt[i,1])      
      OUTPUT_INDIV_SOLUTION, SolnArr_decision, OutFile 
    ENDELSE
  ENDELSE
  
ENDFOR

;-----------------------------------------------------------------------------;

ID=WHERE(decision_array[*,2] NE -1.0)
IF ID[0] EQ -1 then num=0.0 ELSE num=N_ELEMENTS(ID)
PRINT, ''
PRINT, ';-----------------------------------------------------------------------------;'
PRINT, 'TOTAL NUMBER OF POSITIONS REVISITED:      ',  N_ELEMENTS(IndArr_alt[*,0])
PRINT, 'PERCENTAGE NUMBER OF POSITIONS REVISITED: ', (FLOAT(N_ELEMENTS(IndArr_alt[*,0]))/FLOAT(N_ELEMENTS(IndArr[*,0])))*100.0
PRINT, 'TOTAL NUMBER OF POSITIONS REFIT:          ',  FLOAT(num)
PRINT, 'PERCENTAGE NUMBER OF POSITIONS REFIT:     ', (FLOAT(num)/FLOAT(N_ELEMENTS(IndArr_alt[*,0])))*100.0
PRINT, ';-----------------------------------------------------------------------------;'
PRINT, ''
FILE_COPY, OutFile, OutFile+'.backup'
endtime = (SYSTIME(/second)-starttime)/60.0
PRINT, ''
PRINT, 'Time taken: ', endtime, ' minutes.'
PRINT, ''
JOURNAL

END

;-----------------------------------------------------------------------------;

FUNCTION NUMLINES, file
  READCOL, file, data, nlines=nlines, /silent
  RETURN, nlines
END


