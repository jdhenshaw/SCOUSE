;+
;
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
;   
;   SCOUSE requires a .fits file as input. The spectral axis should be in 
;   velocity units.
;   
;   The user must provide:
;
;   i)   Data directory & Filename - location and file name of the .fits cube to 
;        be analysed.
;        
;   ii)  xupper, xlower, yupper, ylower, vlower, vupper - the range over which
;        to fit the data. This allows the user to fit a small region of a larger
;        cube.
;        
;   iii) rms_approx - an estimate of the spectral rms per bin. This is used 
;        when defining the coverage. 
;   
;   iv)  Radius - R_SAA - the radius of the spectral averaging area. In map 
;        units. 
;         
;   v)   sigma_cut -  Used for moment analysis. All voxels below a threshold 
;        are set to 0.0
;        
;   If the user wishes to perform line-fitting over the full cube provided, 
;   change the lower and upper limits to -1000.0 and 1000.0, respectively.
;   
;   The user should inspect the FILE_READ function. Note that the Rsaa 
;   value must be given in terms of map units. The keyword /OFFSETS can be
;   used to calculate the offset RA and Dec from a particular position. 
;
; OUTPUT:
;
;   SCOUSE file structure:
;   
;     FILENAME
;       FIGURES
;       MISC
;       STAGE_1
;         COVERAGE
;         MOMENTS
;       STAGE_2
;         SAA_FIGURES
;         SAA_RESIDUALS
;         SAA_SOLUTIONS
;       STAGE_3
;         INDIV_RESIDUALS
;         INDIV_SOLUTIONS
;       STAGE_4
;       STAGE_5
;       STAGE_6
;       STAGE_7
;       
;   STAGE_1 output:
;   
;     coverage_coordinates.dat - An ascii file containing the x and y positions
;       of the coverage
;       
;     coverage.eps - (optional) - An image of showing the moment 0 map with 
;       coverage over plotted
;      
;     moment_*.fits - .fits files containing the results of moment analysis
;     
;     moment_*.dat - (optional) - Ascii files containing the results of moment
;       analysis. These must be initiated using keywords to the relevant 
;       function.
;       
;     coords.dat - An ascii file containing the coordinates and indices of all
;       pixels within the user-defined region.
;       
;     coords_coverage.dat - As above but for all pixels contained within the 
;       coverage region. 
;       
;     input.dat - A file containing the user inputs - used by FILE_PREPARATION
;       to generate the correct axes. 
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

PRO SCOUSE_STAGE_1
Compile_Opt idl2

;------------------------------------------------------------------------------;
; USER INPUT
;------------------------------------------------------------------------------;

datadirectory =  ''  
filename      =  ''               ; The data cube to be analysed
fitsfile      =  filename+'.fits' ; fits extension
vlower        = -1000.0           ; The lower limit to the velocity 
vupper        =  1000.0           ; The upper limit to the velocity 
xlower        = -1000.0           ; The lower limit to the x dimension 
xupper        =  1000.0           ; The upper limit to the x dimension
ylower        = -1000.0           ; The lower limit to the y dimension
yupper        =  1000.0           ; The upper limit to the y dimension
rsaa          =  0.0              ; Radius for the spectral averaging areas. Map units.
rms_approx    =  0.0              ; Enter an approximate rms value for the data.
sigma_cut     =  3                ; Threshold below which all channel values set to 0.0
vunit         =  1000.0              ; if FITS header has units of m/s; conv from m/s to km/s

;------------------------------------------------------------------------------;
; CREATE MAIN OUTPUT DIRECTORY AND SUB-DIRECTORIES
;   
;   Prepare the output file structure and output files. This will create a 
;   directory in 'datadirectory'.
;   
;------------------------------------------------------------------------------;

CD, datadirectory                 
FILE_MKDIR, datadirectory+filename
stageone   = 'STAGE_1'
stagetwo   = 'STAGE_2'
stagethree = 'STAGE_3'
stagefour  = 'STAGE_4'
stagefive  = 'STAGE_5'
stagesix   = 'STAGE_6'
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
; S1
FILE_MKDIR, datadirectory+filename+'/'+stageone+'/COVERAGE'
FILE_MKDIR, datadirectory+filename+'/'+stageone+'/MOMENTS'
; S2
FILE_MKDIR, datadirectory+filename+'/'+stagetwo+'/SAA_RESIDUALS'
FILE_MKDIR, datadirectory+filename+'/'+stagetwo+'/SAA_SOLUTIONS'
FILE_MKDIR, datadirectory+filename+'/'+stagetwo+'/SAA_FIGURES'
; S3
FILE_MKDIR, datadirectory+filename+'/'+stagethree+'/INDIV_RESIDUALS'
FILE_MKDIR, datadirectory+filename+'/'+stagethree+'/INDIV_SOLUTIONS'

;------------------------------------------------------------------------------;
; 
;------------------------------------------------------------------------------;

; Coverage files
coverage_ascii     = datadirectory+filename+'/'+stageone+'/COVERAGE/coverage_coordinates.dat'
coverage_figure    = datadirectory+filename+'/'+stageone+'/COVERAGE/coverage.eps'
; Coordinate files
coordfile          = datadirectory+filename+'/MISC/coords.dat'
coordfile_coverage = datadirectory+filename+'/MISC/coords_coverage.dat'
; Input & tmp
input_file         = datadirectory+filename+'/'+'MISC/inputs.dat'
tmp                = datadirectory+filename+'/MISC/tmp.dat'
; Moment files
moment_zero_fits   = datadirectory+filename+'/'+stageone+'/MOMENTS/moment_0.fits'
moment_zero_ascii  = datadirectory+filename+'/'+stageone+'/MOMENTS/moment_0.dat'
moment_one_fits    = datadirectory+filename+'/'+stageone+'/MOMENTS/moment_1.fits'
moment_one_ascii   = datadirectory+filename+'/'+stageone+'/MOMENTS/moment_1.dat'
moment_two_fits    = datadirectory+filename+'/'+stageone+'/MOMENTS/moment_2.fits'
moment_two_ascii   = datadirectory+filename+'/'+stageone+'/MOMENTS/moment_2.dat'
; write to input file
OPENW,  1, input_file
PRINTF, 1, vlower
PRINTF, 1, vupper
PRINTF, 1, xlower
PRINTF, 1, xupper
PRINTF, 1, ylower
PRINTF, 1, yupper
PRINTF, 1, rsaa
PRINTF, 1, rms_approx
CLOSE,  1

;-----------------------------------------------------------------------------;
; FILE INPUT AND AXES CREATION
; 
;   Read in the .fits file. Use file prep to trim the axes according to the 
;   limits provided in the 'user input' section.
;   
;   Trimming the velocity axis, where possible, is recommended to aid the 
;   manual fitting of the SAAs. However, the full axis is used for the rms 
;   calculation. 
;   
;-----------------------------------------------------------------------------;

image  = FILE_READ( datadirectory, fitsfile, x=x_axis, y=y_axis, z=z_axis, header=HDR_DATA )              
z_axis = z_axis/vunit
data   = FILE_PREPARATION( image, x_axis, y_axis, z_axis, HDR_DATA, input_file, vunit, image_rms=data_rms, z_rms=z_axis_rms, header_new=HDR_NEW) 
              
;==============================================================================;
; BEGIN ANALYSIS
;==============================================================================;

print, ''
print, 'Beginning analysis...'
print, ''
JOURNAL, datadirectory+filename+'/MISC/stageone_log.dat' ; Create a log file 
starttime = SYSTIME(/seconds)                            ; Time the process

;------------------------------------------------------------------------------;
; MAKE MOMENT MAPS
; 
;   The integrated intensity map is integral to defining the coverage. The 
;   first and second order moment maps are optional and purely for reference.
;   Comment if necessary.
;   
;------------------------------------------------------------------------------;

momzero  = MOMENT_ZERO(data, x_axis, y_axis, z_axis, rms_approx, sigma_cut, OutFile=moment_zero_ascii, /PrintToFile )
momone   = MOMENT_ONE(data, x_axis, y_axis, z_axis, rms_approx, sigma_cut, OutFile=moment_one_ascii, /PrintToFile )
momtwo   = MOMENT_TWO(data, x_axis, y_axis, z_axis, rms_approx, sigma_cut, OutFile=moment_two_ascii, /PrintToFile )
WRITEFITS, moment_zero_fits, momzero, HDR_NEW
WRITEFITS, moment_one_fits, momone, HDR_NEW
WRITEFITS, moment_two_fits, momtwo, HDR_NEW

;==============================================================================;
; MAIN ROUTINE
;   
;   Create the coverage, the coordinate files used during latter stages of the 
;   SCOUSE procedure and a map of the coverage. 
;   
;   The procedure to plot the coverage may need editing. 
;   
;==============================================================================;

DEF_COVERAGE, x_axis, y_axis, momzero, rsaa, coverage_ascii, nareas=nareas          
CREATE_COORDFILES, x_axis, y_axis, rsaa, coverage_ascii, coordfile, coordfile_coverage, tmp, num=npos                                              
PLOT_COVERAGE, x_axis, y_axis, momzero, rsaa, coverage_ascii, coverage_figure                                                         

;------------------------------------------------------------------------------;

PRINT, ''
PRINT, 'Number of spectra to fit manually: ', FLOAT(nareas) ; The number of spectral averaging areas to fit
PRINT, ''
PRINT, 'Number of spectra:                 ', FLOAT(npos)   ; The total number of spectra contained within those regions
PRINT, ''
endtime = (SYSTIME(/second)-starttime)/60.0
PRINT, ''
PRINT, 'Time taken: ', endtime, ' minutes.'                 ; Time taken to complete the process
PRINT, ''
JOURNAL

END

