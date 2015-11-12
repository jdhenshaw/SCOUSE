PRO STAGE_1
;------------------------------------------------------------------------------;
; SCOUSE - Semi-automated multi-COmponent Universal Spectral-line fitting Engine
; Copyright (c) 2015 Jonathan D. Henshaw
; CONTACT: j.d.henshaw[AT]ljmu.ac.uk
;
; PROGRAM NAME:
;   SCOUSE - STAGE 1
;
; PURPOSE:
;   This program is used in order to identify the spatial area over which SCOUSE
;   will be implemented.
;
; USAGE:
;   The user must provide:
;
;   i)   Filename - the fits cube to be fitted
;   ii)  xupper, xlower, yupper, ylower, vlower, vupper - the range over which
;        to fit the data
;   iii) rms_approx - an estimate of the spectral rms per bin
;   iv)  Radius - R_SAA - the radius of the spectral averaging area
;   v)   sigma_cut -  Used for moment analysis. All voxels below a threshold 
;        are set to 0.0
;
; NOTES:
;
; This code will produce a figure of the coverage. This figure is created using
; the 'coverage_plot.pro' subroutine. The user may want to tweak this code to
; improve the quality of the figure.
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
;------------------------------------------------------------------------------;
Compile_Opt idl2
;------------------------------------------------------------------------------;
; USER INPUTS
;------------------------------------------------------------------------------;

datadirectory =  ''
filename = '' ; The data cube to be analysed
fitsfile = filename+'.fits'

vlower = -1000.0 ; The upper/lower limit over which to fit the data
vupper = 1000.0
xlower  = -1000.0 ; To fit the full range use 1000, -1000.
xupper = 1000.0
ylower  = -1000.0 ;
yupper = 1000.0 ;
rsaa = 0.0 ; Radius for the spectral averaging areas. Map units.
rms_approx = 0.0 ; Enter an approximate rms value for the data.
sigma_cut = 3

vunit = 1000.0 ; if FITS header has units of m/s; conv from m/s to km/s

;------------------------------------------------------------------------------;
; CREATE MAIN OUTPUT DIRECTORY AND SUB-DIRECTORIES
;------------------------------------------------------------------------------;

CD, datadirectory

FILE_MKDIR, datadirectory+filename
stageone = 'STAGE_1'
stagetwo = 'STAGE_2'
stagethree = 'STAGE_3'
stagefour = 'STAGE_4'
stagefive = 'STAGE_5'
stagesix = 'STAGE_6'
stageseven = 'STAGE_7'

FILE_MKDIR, datadirectory+filename+'/MISC'
FILE_MKDIR, datadirectory+filename+'/FIGURES'
FILE_MKDIR, datadirectory+filename+'/'+stageone
FILE_MKDIR, datadirectory+filename+'/'+stagetwo
FILE_MKDIR, datadirectory+filename+'/'+stagethree
FILE_MKDIR, datadirectory+filename+'/'+stagefour
FILE_MKDIR, datadirectory+filename+'/'+stagefive
FILE_MKDIR, datadirectory+filename+'/'+stagesix
FILE_MKDIR, datadirectory+filename+'/'+stageseven

; CREATE FURTHER SUB-DIRECTORIES

; S1

FILE_MKDIR, datadirectory+filename+'/'+stageone+'/COVERAGE'
FILE_MKDIR, datadirectory+filename+'/'+stageone+'/MOMENTS'

; S2

FILE_MKDIR, datadirectory+filename+'/'+stagetwo+'/SAA_RESIDUALS'
FILE_MKDIR, datadirectory+filename+'/'+stagetwo+'/SAA_SOLUTIONS'

; S3

FILE_MKDIR, datadirectory+filename+'/'+stagethree+'/INDIV_RESIDUALS'
FILE_MKDIR, datadirectory+filename+'/'+stagethree+'/INDIV_SOLUTIONS'

;------------------------------------------------------------------------------;
; INDIVIDUAL FILES CREATED DURING S1
;------------------------------------------------------------------------------;

; Moment files

moment_zero_fits =  datadirectory+filename+'/'+stageone+'/MOMENTS/moment_0.fits'
moment_zero_ascii = datadirectory+filename+'/'+stageone+'/MOMENTS/moment_0.dat'

moment_one_fits =  datadirectory+filename+'/'+stageone+'/MOMENTS/moment_1.fits'
moment_one_ascii = datadirectory+filename+'/'+stageone+'/MOMENTS/moment_1.dat'

moment_two_fits = datadirectory+filename+'/'+stageone+'/MOMENTS/moment_2.fits'
moment_two_ascii = datadirectory+filename+'/'+stageone+'/MOMENTS/moment_2.dat'

; Coverage files

coverage_ascii =  datadirectory+filename+'/'+stageone+'/COVERAGE/coverage_coordinates.dat'
coverage_figure = datadirectory+filename+'/'+stageone+'/COVERAGE/coverage.eps'

; Coordinate files

; coordfile: Coords of pixels within the map
coordfile = datadirectory+filename+'/MISC/coords.dat'
; coordfile_coverage: Coords of pixels within the coverage
coordfile_coverage = datadirectory+filename+'/MISC/coords_coverage.dat'

; Inputs

input_file = datadirectory+filename+'/'+'MISC/inputs.dat'

; Temp file

tmp = datadirectory+filename+'/MISC/tmp.dat'

; write to input file

OPENW, 1, input_file
PRINTF, 1, vlower
PRINTF, 1, vupper
PRINTF, 1, xlower
PRINTF, 1, xupper
PRINTF, 1, ylower
PRINTF, 1, yupper
PRINTF, 1, rsaa
PRINTF, 1, rms_approx
CLOSE,1

;-----------------------------------------------------------------------------;
; FILE INPUT AND AXES CREATION
;-----------------------------------------------------------------------------;
; Read in FITS file and create axes
image = FILE_READ( datadirectory, fitsfile, x_axis=x_axis, y_axis=y_axis, $
                   z_axis=z_axis, HDR_DATA=HDR_DATA ) 

z_axis = z_axis/vunit

data = FILE_PREPARATION( input_file, vunit, image, x_axis, y_axis, z_axis, $
                         HDR_DATA, data_rms=image_rms, z_axis_rms=z_axis_rms, $
                         HDR_NEW=HDR_NEW )
;-----------------------------------------------------------------------------;
; BEGIN ANALYSIS
;-----------------------------------------------------------------------------;
print, ''
print, 'Beginning analysis...'
print, ''
JOURNAL, datadirectory+filename+'/'+'MISC/stageone_log.dat'
starttime = SYSTIME(/seconds)
;-----------------------------------------------------------------------------;
; MAKE SOME MOMENT MAPS
;-----------------------------------------------------------------------------;
momzero = MOMENT_ZERO(data, x_axis, y_axis, z_axis, rms_approx, sigma_cut, $
                      moment_zero_ascii )

momone = MOMENT_ONE(data, x_axis, y_axis, z_axis, rms_approx, sigma_cut, $
                    moment_one_ascii, momzero )

momtwo = MOMENT_TWO(data, x_axis, y_axis, z_axis, rms_approx, sigma_cut, $
                    moment_two_ascii, momone )

WRITEFITS, moment_zero_fits, momzero, HDR_NEW
WRITEFITS, moment_one_fits, momone, HDR_NEW
WRITEFITS, moment_two_fits, momtwo, HDR_NEW
;------------------------------------------------------------------------------;
; DEFINE THE COVERAGE
;------------------------------------------------------------------------------;
nareas = DEF_COVERAGE( momzero, x_axis, y_axis, rsaa, moment_zero_ascii, $
                       coverage_ascii )
                       
npos = CREATE_COORDFILES( rsaa,coverage_ascii,coordfile,coordfile_coverage,tmp,$
                          x_axis,y_axis )
                          
moment_map = COVERAGE_PLOT( momzero,x_axis,y_axis, rsaa,coverage_ascii,$
                            coverage_figure )
;------------------------------------------------------------------------------;
; END PROCESS
;------------------------------------------------------------------------------;
PRINT, ''
PRINT, 'Number of spectra to fit manually: ', FLOAT(nareas)
PRINT, ''
PRINT, 'Number of spectra: ', FLOAT(npos)
PRINT, ''
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
;create_offset_positions = CREATE_OFFSETS( x_axis, y_axis, crval1, crval2, 
;                                          ra_offsets=ra_offsets, 
;                                          dec_offsets=dec_offsets )
;x_axis = ra_offsets
;y_axis = dec_offsets
