;+
;
; SCOUSE - Semi-automated multi-COmponent Universal Spectral-line fitting Engine
; Copyright (c) 2015 Jonathan D. Henshaw
; CONTACT: j.d.henshaw[AT]ljmu.ac.uk
; 
; PROGRAM NAME:
;   SCOUSE - STAGE 5
;   
; PURPOSE:
;   This program is used to check the fits produced by SCOUSE. The user is 
;   required to enter indices of the spectra they wish to revisit, either
;   to seek an alternative solution or to refit entirely. 
;
; USAGE:
;
;   SCOUSE requires a .fits file as input. The spectral axis should be in
;   velocity units.
;   
; NOTES:
; 
;   This stage of the process is optional but highly recommended.
; 
;   Spectra are plotted in blocks (of 36/49 spectra). Depdending on the total 
;   number of spectra, there could be > 100 blocks to check. This process 
;   requires a significant amount of user interaction. 
; 
;   The number of spectra per block can be edited in the user inputs section.
;   Note however, that this may require the user to edit the plot spectrum 
;   grid function.
;   
; OUTPUT:
; 
;   check_spec_indxfile.dat - A file containing the locations and indices of the 
;     spectra a user would like to take a closer look at. Either because the fit
;     is poor, or they would like to see if an alternative solution is available
; 
; EXAMPLE:
; 
;   If nblocks is > 50, check the spectra in blocks of 50 (1800/2450 specta at a 
;   time). 
;   
;   However, if the user wishes to break down the process in this way, The 
;   name of the indxfile will need updating for each block.
;
;   First run:
;
;   lower_block = 0
;   upper_block = 49
;
;   indxfile = datadirectory+filename+'/STAGE_5/check_spec_indxfile_1.dat'
;
;   Second run:
;
;   lower_block = 50
;   upper_block = 99
;
;   indxfile = datadirectory+filename+'/STAGE_5/check_spec_indxfile_2.dat'
;
;   ***Following the completion of the process the user will have to manually
;   compile the indices into a single file for use with the next stage of
;   the process.***
;   
;   See section "To be edited" below
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

PRO SCOUSE_STAGE_5
Compile_Opt idl2

;------------------------------------------------------------------------------;
; USER INPUT
;------------------------------------------------------------------------------;

datadirectory = ''  
filename      = ''                                                          ; The data cube to be analysed
fitsfile      = filename+'.fits'                                            ; fits extension
vunit         = 1000.0                                                      ; if FITS header has units of m/s; conv from m/s to km/s
velrange      = [0.0, 0.0]                                                  ; range over which to plot spectra
SolnFile      = datadirectory+filename+'/STAGE_4/final_solns.dat'           ; The solution file
OutFile       = datadirectory+filename+'/STAGE_5/check_spec_indxfile_1.dat' ; This needs to be updated
JOURNAL,        datadirectory+filename+'/MISC/stagefive_1_log.dat'          ; This needs to be updated
val           = 49.0                                                        ; Plot 36/49 spectra at a time is reasonable.
grid_dim      = 7                                                           ; This will plot a 7x7 grid
nblocks       = NUMBLOCKS( datadirectory, filename, val )
lower_block   = 0                                                           ; lower block index
upper_block   = nblocks                                                     ; upper block index. Change to nblocks if you want to check all in one sitting

;------------------------------------------------------------------------------;
; FILE INPUT AND AXES CREATION
;------------------------------------------------------------------------------;

input_file    = datadirectory+filename+'/MISC/inputs.dat'
coordfile     = datadirectory+filename+'/MISC/coords_coverage.dat'

;------------------------------------------------------------------------------;
;
;------------------------------------------------------------------------------;

image  = FILE_READ( datadirectory, fitsfile, x=x_axis, y=y_axis, z=z_axis, header=HDR_DATA )   
z_axis = z_axis/vunit            
data   = FILE_PREPARATION( image, x_axis, y_axis, z_axis, HDR_DATA, input_file, vunit, image_rms=data_rms, z_rms=z_axis_rms, header=HDR_NEW )           
READCOL, coordfile, x, y, xindx, yindx, combindx, nlines=nlines, /silent
READCOL, SolnFile, n, xpos, ypos, int, sint, vel, svel, fwhm, sfwhm, rms, resid, totchisq, dof, chisqred, AIC, nlines=nfits, /silent                                    
OPENW,1, OutFile, width=100 ; Prepare the output file
CLOSE,1         
              
;------------------------------------------------------------------------------;
; BEGIN ANALYSIS
;------------------------------------------------------------------------------;

PRINT, ''
PRINT, 'Beginning analysis...'
PRINT, ''
starttime = SYSTIME(/seconds)

;==============================================================================;
; MAIN ROUTINE
;   
;   A block of 'val' spectra is presented. The user is required to enter the 
;   indices of the spectra they would like to take a closer look at.
;   
;==============================================================================;

indArr         = [[x], [y], [xindx], [yindx], [combindx]]
SolnArr        = [[n],[xpos],[ypos], [int], [sint], [vel],[svel],[fwhm],[sfwhm],[rms],[resid],[totchisq],[dof],[chisqred],[AIC]]
conv_FWHM2disp = (2.0*SQRT(2.0*ALOG(2.0)))
SolnArr[*,7]   = SolnArr[*,7]/conv_FWHM2disp
SolnArr[*,8]   = SolnArr[*,8]/conv_FWHM2disp
spec_count     = 0.0

FOR i = lower_block, upper_block DO BEGIN
  
  lowerblocktext = STRING(i+1, format='(I4)')
  upperblocktext = STRING(upper_block+1, format='(I4)')
  PRINT, 'Block: ', lowerblocktext, ' of ', upperblocktext
  PRINT, '' 
  low         = (i)*val
  high        = ((i+1)*val)-1.0  
  IF i EQ nblocks THEN high = FLOAT(nlines)-1.0  
  IndArr_trim = IndArr[low:high, *]  
  PLOT_SPECTRUM_GRID, SolnArr, IndArr_trim, z_axis, data, val, velrange, grid_dim         
  SELECT_INDICES, SolnArr, IndArr_trim, OutFile 
  spec_count  = spec_count+N_ELEMENTS(IndArr_trim[*,0]) 
  
ENDFOR

;-----------------------------------------------------------------------------;
FILE_COPY, OutFile, OutFile+'.backup',/overwrite
endtime = (SYSTIME(/second)-starttime)/60.0
PRINT, ''
PRINT, spec_count, ' spectra checked in ', endtime, ' minutes.'
PRINT, ''
JOURNAL

END

;-----------------------------------------------------------------------------;

FUNCTION NUMBLOCKS, datadirectory, filename, val
  ; A function to estimate the total number of blocks to check. This tidies up
  ; the 'USER INPUT' section above.  
  coordfile_coverage = datadirectory+filename+'/MISC/coords_coverage.dat'
  READCOL, coordfile_coverage, data, nlines=nlines, /silent   
  nblocks = nlines/val
  nblocks = ROUND(nblocks)-1 
  RETURN, nblocks
END
