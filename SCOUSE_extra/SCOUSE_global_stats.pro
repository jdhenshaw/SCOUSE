;+
;
; SCOUSE - Semi-automated multi-COmponent Universal Spectral-line fitting Engine
; Copyright (c) 2015 Jonathan D. Henshaw
; CONTACT: j.d.henshaw[AT]ljmu.ac.uk
;
; PROGRAM NAME:
;   SCOUSE - GLOBAL STATS
;
; PURPOSE:
;   This program provides statistics on a data file processed by SCOUSE.
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
;-

PRO SCOUSE_global_stats
Compile_Opt IDL2

;------------------------------------------------------------------------------;
; USER INPUT
;------------------------------------------------------------------------------;

datadirectory = ''
filename      = '' ; The data cube to be analysed
SolnFile      = datadirectory+filename+'/STAGE_7/final_solns_updated.dat'
saa_coordfile = datadirectory+filename+'/STAGE_1/COVERAGE/coverage_coordinates.dat'
coordfile     = datadirectory+filename+'/MISC/coords.dat'
coordfile_cov = datadirectory+filename+'/MISC/coords_coverage.dat'
x_range       = [-1000.0, 1000.0] ; Can use these to select a subsample of data
y_range       = [-1000.0, 1000.0]
v_range       = [-1000.0, 1000.0]

;------------------------------------------------------------------------------;
; FILE INPUT
;------------------------------------------------------------------------------;

READCOL, coordfile, x, y, xindx, yindx, combindx, nlines=nlines, /silent
indArr         = [[x], [y], [xindx], [yindx], [combindx]]
READCOL, coordfile_cov, x, y, xindx, yindx, combindx, nlines=nlines, /silent
indArr_cov     = [[x], [y], [xindx], [yindx], [combindx]]
READCOL, SolnFile, n, xpos, ypos, int, sint, vel, svel, fwhm, sfwhm, rms, resid, totchisq, dof, chisqred, AIC, nlines=nfits, /silent
SolnArr        = [[n],[xpos],[ypos], [int], [sint], [vel],[svel],[fwhm],[sfwhm],[rms],[resid],[totchisq],[dof],[chisqred],[AIC]]
READCOL, saa_coordfile, xpos, ypos, /silent

;==============================================================================;
; MAIN ROUTINE
;==============================================================================;

ID      = WHERE(SolnArr[*,1] GT MIN(x_range) AND SolnArr[*,1] LT MAX(x_range) AND SolnArr[*,2] GT MIN(y_range) AND SolnArr[*,2] LT MAX(y_range) AND SolnArr[*,6] GT MIN(v_range) AND SolnArr[*,6] LT MAX(v_range))
SolnArr = SolnArr[ID, *]

count = 0.0
FOR i = 0, N_ELEMENTS(indArr[*,0])-1 do begin
  ID = WHERE(SolnArr[*,1] EQ indArr[i,0] AND SolnArr[*,2] EQ indArr[i,1])
  IF ID[0] NE -1 AND SolnArr[ID[0],13] NE 1000.0 THEN BEGIN
    count = count+1
  ENDIF
ENDFOR

SolnArr[WHERE(SolnArr[*,13] NE 1000.0),7] = SolnArr[WHERE(SolnArr[*,13] NE 1000.0),7]/(2.0*sqrt(2*alog(2)))
bpd = CREATEBOXPLOTDATA(SolnArr[WHERE(SolnArr[*,13] NE 1000.0),7], MEAN_VALUES=means)


JOURNAL, datadirectory+filename+'/MISC/SCOUSE_global_stats.dat'

PRINT, ''
PRINT, 'Total number of positions:             ', N_ELEMENTS(indArr[*,0])
PRINT, 'Total number of positions in coverage: ', N_ELEMENTS(indArr_cov[*,0])
PRINT, 'Number of SAAs fit:                    ', N_ELEMENTS(xpos)
PRINT, 'Number of positions fit:               ', count
PRINT, 'Total number of components:            ', N_ELEMENTS(SolnArr[WHERE(SolnArr[*,13] NE 1000.0),0])
PRINT, 'Number of components per position:     ', N_ELEMENTS(SolnArr[WHERE(SolnArr[*,13] NE 1000.0),0])/count
PRINT, 'Mean reduced chisq value:              ', MEAN(SolnArr[WHERE(SolnArr[*,13] NE 1000.0),13])
PRINT, 'Mean sigma_resid/sigma_rms:            ', MEAN(SolnArr[WHERE(SolnArr[*,13] NE 1000.0),10]/SolnArr[WHERE(SolnArr[*,13] NE 1000.0),9])
PRINT, ''
PRINT, 'Max intensity:                         ', MAX(SolnArr[WHERE(SolnArr[*,13] NE 1000.0),3])
PRINT, 'Min intensity:                         ', MIN(SolnArr[WHERE(SolnArr[*,13] NE 1000.0),3])
PRINT, ''
PRINT, 'Sigma: 0th-1st quartile:               ', bpd[0], bpd[1]
PRINT, 'Sigma: 1st-3rd quartile:               ', bpd[1], bpd[3]
PRINT, 'Sigma: 3rd-4th quartile:               ', bpd[3], bpd[4]
PRINT, 'Sigma: median:                         ', bpd[2]
PRINT, ''

JOURNAL

;------------------------------------------------------------------------------;

END