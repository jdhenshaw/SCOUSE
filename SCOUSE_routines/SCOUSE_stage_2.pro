;+
;
; SCOUSE - Semi-automated multi-COmponent Universal Spectral-line fitting Engine
; Copyright (c) 2015 Jonathan D. Henshaw
; CONTACT: j.d.henshaw@ljmu.ac.uk
; 
; PROGRAM NAME:
;   SCOUSE - STAGE 2
;
; PURPOSE:
;   An interactive program designed to find best-fitting solutions to spatially
;   averaged spectra taken from the SAAs.
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

PRO SCOUSE_STAGE_2
Compile_Opt idl2

;------------------------------------------------------------------------------;
; USER INPUTS
;------------------------------------------------------------------------------;

datadirectory =  '/Users/Jonathan/Dropbox/Work/Code/PPV_analysis/fits_files_for_analysis/test/'
filename = 'n2h+10_37' ; The data cube to be analysed
fitsfile = filename+'.fits'
vunit = 1000.0 ; if FITS header has units of m/s; conv from m/s to km/s

;------------------------------------------------------------------------------;
; 
;------------------------------------------------------------------------------;

CD, datadirectory

outputdatafile = datadirectory+filename+'/STAGE_2/SAA_SOLUTIONS/SAA_solutions.dat'
cov_coordfile = datadirectory+filename+'/STAGE_1/COVERAGE/coverage_coordinates.dat'
input_file = datadirectory+filename+'/MISC/inputs.dat'
temp_file = datadirectory+filename+'/MISC/tmp.dat'

; Prepare output file

OPENW,1, outputdatafile, width = 200
CLOSE,1

;------------------------------------------------------------------------------;
; FILE INPUT AND AXES CREATION
;------------------------------------------------------------------------------;
; Read in FITS file and create axes
image = FILE_READ( datadirectory, fitsfile, x=x_axis, y=y_axis, z=z_axis, $
                   HDR_DATA=HDR_DATA ) 

crval1    = SXPAR(HDR_DATA,'CRVAL1')
crval2    = SXPAR(HDR_DATA,'CRVAL2')
create_offset_positions = CREATE_OFFSETS( x_axis, y_axis, crval1, crval2,$
                                          x_off=ra_offsets,$
                                          y_off=dec_offsets )
x_axis = ra_offsets
y_axis = dec_offsets                
z_axis = z_axis/vunit

data = FILE_PREPARATION( image, x_axis, y_axis, z_axis, HDR_DATA,$ 
                         input_file, vunit, $
                         image_rms=data_rms, z_rms=z_axis_rms,HDR_NEW=HDR_NEW )
                                               
READCOL, cov_coordfile, format = '(F,F)', coverage_x, coverage_y, /silent
READCOL, input_file, inputs, /silent
rsaa = inputs[6]

;------------------------------------------------------------------------------;
; BEGIN ANALYSIS
;------------------------------------------------------------------------------;
PRINT, ''
PRINT, 'Beginning analysis...'
PRINT, ''
JOURNAL, datadirectory+filename+'/'+'misc/stagetwo_log.dat'
starttime = SYSTIME(/seconds)

;------------------------------------------------------------------------------;
count_val  = 0.0
n          = '' ; Number of gaussian components
ncount     = 0 ; Number of spectra fitted
spec_x     = z_axis
spec_x_rms = z_axis_rms

FOR i = 0, N_ELEMENTS(coverage_x)-1 DO BEGIN 

  ; Identify the positions associated with each coverage area

  ID_x = WHERE(x_axis LT coverage_x[i]+rsaa AND x_axis GT coverage_x[i]-rsaa)
  ID_y = WHERE(y_axis LT coverage_y[i]+rsaa AND y_axis GT coverage_y[i]-rsaa)
  
  ; Create a spatatially-averaged spectrum 

  spec_y     = SPATIALLY_AVERAGE_DATA( data, spec_x, ID_x, ID_y)
  spec_y_rms = SPATIALLY_AVERAGE_DATA( data_rms, spec_x_rms, ID_x, ID_y)
                                                    
  ; Create rms window - user interactive

  spectral_rms = RMS_WINDOW(spec_x_rms,spec_y_rms,coverage_x[i],coverage_y[i],$
                            temp_file, rms_window_val=rms_window_val)    
                            
  err_spec_y = REPLICATE(spectral_rms, N_ELEMENTS(spec_y))
                       
  ; Begin the fitting routine
  
  SolnArr = FIT_SAA( spec_x, spec_x_rms, spec_y, spec_y_rms, err_spec_y,$
                     rms_window_val, coverage_x[i], coverage_y[i], $
                     n, temp_file, ResArr=ResArr)
  
  output_solns = OUTPUT_SAA_SOLUTION( i, SolnArr, spec_x, specResArr, outputdatafile )
                                   
  ncount = ncount+1.0

  PRINT,'' 
  PRINT, 'Number of spectra fitted: ', ncount
  PRINT, ''
  
ENDFOR

;------------------------------------------------------------------------------;

endtime = (SYSTIME(/second)-starttime)/60.0
PRINT, ''
PRINT, 'Time taken: ', endtime, ' minutes.'
PRINT, ''
JOURNAL

END

;------------------------------------------------------------------------------;
; ADDITIONAL (OPTIONAL) CODE FOR OFFSET POSITIONS
;------------------------------------------------------------------------------;

;crval1    = SXPAR(HDR_DATA,'CRVAL1')
;crval2    = SXPAR(HDR_DATA,'CRVAL2')
;create_offset_positions = CREATE_OFFSETS( x_axis, y_axis, crval1, crval2,$
;                                          x_off=ra_offsets,$
;                                          y_off=dec_offsets )
;x_axis = ra_offsets
;y_axis = dec_offsets 