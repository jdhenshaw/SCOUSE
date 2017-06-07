;+
;
; SCOUSE - Semi-automated multi-COmponent Universal Spectral-line fitting Engine
; Copyright (c) 2015 Jonathan D. Henshaw
; CONTACT: j.d.henshaw[AT]ljmu.ac.uk
; 
; PROGRAM NAME:
;   SCOUSE - STAGE 4
;
; PURPOSE:
;   This program is used to identify the best fitting solutions out of those 
;   fitted by SCOUSE
;
; OUTPUT:
; 
;   compile_solns.dat - All solutions compiled into a single file.
;   
;   reorder_solns.dat - All solutions reorded.
;   
;   remdup_solns.dat - All unique solutions
;   
;   final_solns.dat - Best-fitting solutions following AIC minimisation
;   
;   alt_solns.dat - Unique alternative solutions
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

PRO SCOUSE_STAGE_4
Compile_Opt idl2

;------------------------------------------------------------------------------;
; USER INPUT
;------------------------------------------------------------------------------;

datadirectory =  ''  
filename      =  ''               ; The data cube to be analysed
fitsfile      =  filename+'.fits' ; fits extension

;------------------------------------------------------------------------------;
; FILE INPUT
;------------------------------------------------------------------------------;

coordfile      = datadirectory+filename+'/MISC/coords_coverage.dat'
cov_coordfile  = datadirectory+filename+'/STAGE_1/COVERAGE/coverage_coordinates.dat'
indivdirectory = datadirectory+filename+'/STAGE_3/INDIV_SOLUTIONS/'
compile_solns  = datadirectory+filename+'/STAGE_4/compile_solns.dat'
reorder_solns  = datadirectory+filename+'/STAGE_4/reorder_solns.dat'
remdup_solns   = datadirectory+filename+'/STAGE_4/remdup_solns.dat'
final_solns    = datadirectory+filename+'/STAGE_4/final_solns.dat'
alt_solns      = datadirectory+filename+'/STAGE_4/alt_solns.dat'

;------------------------------------------------------------------------------;
; BEGIN ANALYSIS
;------------------------------------------------------------------------------;

PRINT, ''
PRINT, 'Beginning analysis...'
PRINT, ''
JOURNAL, datadirectory+filename+'/MISC/stagefour_log.dat'
starttime = SYSTIME(/seconds)

;==============================================================================;
; MAIN ROUTINE
; 
;   The first stage of the process is to compile all of the solutions. These are
;   then reordered. Duplicate solutions are then removed, before the best-fit
;   solutions and unique alternatives are written to file.
;   
;==============================================================================;

COMPILE_SOLUTIONS, indivdirectory, cov_coordfile, compile_solns 
REORDER_SOLUTIONS, compile_solns, coordfile, reorder_solns 
REMDUP_SOLUTIONS, reorder_solns, coordfile, remdup_solns 
FINAL_SOLUTIONS, remdup_solns, coordfile, final_solns, alt_solns 
   
;-----------------------------------------------------------------------------;
endtime = (SYSTIME(/second)-starttime)/60.0
PRINT, ''
PRINT, 'Time taken: ', endtime, ' minutes.'
PRINT, ''
JOURNAL

END