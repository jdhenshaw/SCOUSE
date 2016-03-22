;+
;
; SCOUSE - Semi-automated multi-COmponent Universal Spectral-line fitting Engine
; Copyright (c) 2015 Jonathan D. Henshaw
; CONTACT: j.d.henshaw[AT]ljmu.ac.uk
; 
; PROGRAM NAME:
;   SCOUSE - STAGE 2
;
; PURPOSE:
;   An interactive program designed to find best-fitting solutions to spatially
;   averaged spectra taken from the SAAs.
; 
; USAGE:
;   
;   SCOUSE requires a .fits file as input. The spectral axis should be in 
;   velocity units.  
;   
; OUTPUT:
; 
;   SAA_solutions.dat - An ascii file containing the best-fitting solutions to 
;     the SAAs. The columns are as follows:
;       
;     number of components, xpos, ypos, intensity, err_intensity, centroid vel,
;     err_centroid vel, FWHM, err_FWHM, spectral rms, residual, total chisq,
;     degrees of freedom, reduced chisq, AIC, rms window lower, rms window upper
;     
;   residual_*.dat - (optional) - An ascii file containing the residual 
;     spectrum.
;     
;   best_fit_spec_*.png - (optional) - An image of the best-fitting solution.
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
;   Updated - 03/03/16 - JDH - Updated the main routine. If no data found within 
;                              SAA limits, no fitting performed.
;
;-

PRO SCOUSE_STAGE_2
Compile_Opt idl2

;------------------------------------------------------------------------------;
; USER INPUT
;------------------------------------------------------------------------------;

datadirectory = ''  
filename      = ''                ; The data cube to be analysed
fitsfile      = filename+'.fits'  ; fits extension
vunit         = 1000.0            ; if FITS header has units of m/s; conv from m/s to km/s

;------------------------------------------------------------------------------;
; FILE INPUT AND AXES CREATION
; 
;   The SAA solutions will be output to 'SAA_solnFile'
;------------------------------------------------------------------------------;

SAA_solnFile  = datadirectory+filename+'/STAGE_2/SAA_SOLUTIONS/SAA_solutions.dat'
Residdir      = datadirectory+filename+'/STAGE_2/SAA_RESIDUALS/'
Figdir        = datadirectory+filename+'/STAGE_2/SAA_FIGURES/'
cov_coordfile = datadirectory+filename+'/STAGE_1/COVERAGE/coverage_coordinates.dat'
input_file    = datadirectory+filename+'/MISC/inputs.dat'
temp_file     = datadirectory+filename+'/MISC/tmp.dat'

;------------------------------------------------------------------------------;
;
;------------------------------------------------------------------------------;

image  = FILE_READ( datadirectory, fitsfile, x=x_axis, y=y_axis, z=z_axis, header=HDR_DATA )   
z_axis = z_axis/vunit            
data   = FILE_PREPARATION( image, x_axis, y_axis, z_axis, HDR_DATA, input_file, vunit, image_rms=data_rms, z_rms=z_axis_rms, header=HDR_NEW )                                            
READCOL, cov_coordfile, format = '(F,F)', coverage_x, coverage_y, /silent
READCOL, input_file, inputs, /silent
rsaa   = inputs[6]
OPENW,1, SAA_solnFile, width = 200 ; Prepare output file
CLOSE,1

;------------------------------------------------------------------------------;
; BEGIN ANALYSIS
;------------------------------------------------------------------------------;

PRINT, ''
PRINT, 'Beginning analysis...'
PRINT, ''
JOURNAL, datadirectory+filename+'/MISC/stagetwo_log.dat'
starttime = SYSTIME(/seconds)

;==============================================================================;
; MAIN ROUTINE
;   
;   The program cycles through the coverage coordinates identified in Stage 1. 
;   It identifies all spectra within R_saa from each point and creates a 
;   spatially averaged spectrum from these. 
;   
;   The program is user interactive. For the first spectrum the user will need
;   to input a window over which to estimate the rms. For each subsequent 
;   spectrum, entering nothing will result in SCOUSE taking the window from the 
;   previous spectrum. 
;   
;   The user will be asked to provide the number of components and parameter
;   estimates to these. Once a satisfactory fit has been obtained, fit info 
;   will be printed to the output file.
;   
;==============================================================================;

ncount     = 0          
spec_x     = z_axis
spec_x_rms = z_axis_rms

FOR i = 0, N_ELEMENTS(coverage_x)-1 DO BEGIN 
 
  ID_x           = WHERE(x_axis LT coverage_x[i]+rsaa AND x_axis GT coverage_x[i]-rsaa)   ; Identify the positions associated with each coverage area
  ID_y           = WHERE(y_axis LT coverage_y[i]+rsaa AND y_axis GT coverage_y[i]-rsaa)  
  
  IF ID_x[0] NE -1.0 AND ID_y[0] NE -1.0 THEN BEGIN

    spec_y         = GET_SPEC( data, spec_x, ID_x, ID_y)                                    ; Create a spatatially-averaged spectrum
    spec_y_rms     = GET_SPEC( data_rms, spec_x_rms, ID_x, ID_y)
    rms_window_val = RMS_WINDOW(spec_x_rms, spec_y_rms, coverage_x[i], coverage_y[i], temp_file)
    spectral_rms   = CALCULATE_RMS( spec_x_rms, spec_y_rms, rms_window_val )
    err_spec_y     = REPLICATE(spectral_rms, N_ELEMENTS(spec_y))                            ; Create an array containing the rms level

    ; Begin fitting process

    SolnArr        = FIT_MANUAL( spec_x, spec_x_rms, spec_y, spec_y_rms, err_spec_y, coverage_x[i], coverage_y[i], residual_array=ResArr)
    SolnArr_rmswin = REPLICATE(0d0, N_ELEMENTS(SolnArr[*,0]), 17)

    FOR j = 0, N_ELEMENTS( SolnArr[*,0] )-1 DO BEGIN
      FOR k = 0, N_ELEMENTS( SolnArr[0,*] )-1 DO SolnArr_rmswin[j,k] = SolnArr[j,k]
    ENDFOR
    SolnArr        = SolnArr_rmswin
    SolnArr[*,15]  = rms_window_val[0]
    SolnArr[*,16]  = rms_window_val[1]

    OUTPUT_SAA_SOLUTION, SolnArr, SAA_solnFile                                            ; Print to the output file

    ncount = ncount+1.0

    PRINT, ''
    PRINT, 'Number of spectra fitted: ', ncount                                           ; Print the number of spectra fitted
    PRINT, ''
  ENDIF ELSE BEGIN
    print, 'No suitable spectra found within Rsaa limits - check inputs.dat'
  ENDELSE
ENDFOR

;------------------------------------------------------------------------------;
endtime = (SYSTIME(/second)-starttime)/60.0
FILE_COPY, SAA_solnFile, SAA_solnFile+'.backup',/overwrite
PRINT, ''
PRINT, 'Time taken: ', endtime, ' minutes.'
PRINT, ''
JOURNAL

END


