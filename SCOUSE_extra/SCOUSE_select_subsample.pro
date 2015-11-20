;+
;
; SCOUSE - Semi-automated multi-COmponent Universal Spectral-line fitting Engine
; Copyright (c) 2015 Jonathan D. Henshaw
; CONTACT: j.d.henshaw@ljmu.ac.uk
;
; PROGRAM NAME:
;   SCOUSE SELECT SUBSAMPLE
;
; PURPOSE:
;   Reads in the best-fitting solutions output by SCOUSE and extracts a 
;   subsample of the data
;   
; USAGE:
; 
;   The user must provide:
;   
;   i) Data directory & Filename - location and file name data file
;   
;   ii) Output filename - Including directory
;   
;   iii) x, y, v_range - Min/Max values for the sample of data the user wishes
;                        to extract.
;                        
;   iv) sigma_cut - No data within intensity < sigma_cut*rms will be selected
;                     
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

PRO SCOUSE_SELECT_SUBSAMPLE
Compile_Opt idl2

;------------------------------------------------------------------------------;
; USER INPUT
;------------------------------------------------------------------------------;

datadirectory = ''  
filename      = ''               ; The data cube to be analysed
fitsfile      = filename+'.fits' ; Fits extension
OutputFile    = ''               ; Output file name
x_range       = [0.0, 0.0]       ; Range in x position for the subsample (map units)
y_range       = [0.0, 0.0]       ; Range in y position for the subsample (map units)
v_range       = [0.0, 0.0]       ; Range in velocity for the subsample (map units)
sigma_cut     =  0.0             ; Select data above sigma_cut*rms

;------------------------------------------------------------------------------;
; FILE READ
;------------------------------------------------------------------------------;

READCOL, datadirectory+filename,  n, xpos, ypos, int, sint, vel, svel, dv, sdv, rms, totchisq, dof, chisqred, AIC, resid, nlines = nlines, /silent
SolnArr = [[n], [xpos], [ypos], [int], [sint], [vel], [svel], [dv], [sdv], [rms], [totchisq], [dof], [chisqred], [AIC], [resid]]

;------------------------------------------------------------------------------;
; EXTRACT SUBSAMPLE
;------------------------------------------------------------------------------;

ID = WHERE(SolnArr[*,1] gt min(x_range) and SolnArr[*,1] lt max(x_range) and $
           SolnArr[*,2] gt min(y_range) and SolnArr[*,2] lt max(y_range) and $
           SolnArr[*,5] gt min(v_range) and SolnArr[*,5] lt max(v_range) and $
           SolnArr[*,3] gt sigma_cut*SolnArr[*,9])

IF ID[0] NE -1.0 THEN BEGIN
  SolnArr_sample = SolnArr[ID,*] 
  OUTPUT_INDIV_SOLUTION, SolnArr_sample, OutputFile )
ENDIF ELSE BEGIN
  SolnArr_sample = 0.0
  PRINT, "No fits identified, try again!"
ENDELSE

;------------------------------------------------------------------------------;

END