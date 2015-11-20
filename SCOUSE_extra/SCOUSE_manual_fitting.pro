;+
;
; NAME:
;   SCOUSE MANUAL FITTING
;
; PURPOSE:
;   This program can be used for a variety of different spectra. 
;
; USAGE:
;   This program can be used to:
;   
;   i) Fit a single spectrum - The user must provide the coordinates of the 
;      spectrum to be fit under the 'SINGLE SPECTRUM' heading. The program
;      will find the spectrum closest in projected distance from the user input
;      values and this spectrum will then be fit manually.
;      
;      CALLING SEQUENCE:
;      
;      SolnArr =data, data_rms, x_axis, y_axis, z_axis, z_axis_rms, OutputFile,$
;               x_loc=x_loc, y_loc=y_loc, /FIT_SINGLE
;               
;                
;   ii) Fit a sample of spectra - The user can prepare a text file with two 
;       columns, x position and y position. The program will treat as in (i) and
;       fit each individually.
;       
;       CALLING SEQUENCE:
;      
;       SolnArr =data, data_rms, x_axis, y_axis, z_axis, z_axis_rms, OutputFile,$
;                posfile=posfile, /FIT_SAMPLE
;                
;  iii) Fit a spatially averaged spectrum - the user can provide the central
;       x location and y location of a region as well as a radius. The program
;       will find all spectra within this area and display the spatially
;       averaged result. The user can then fit this.
;       
;       CALLING SEQUENCE:
;       
;       SolnArr =data, data_rms, x_axis, y_axis, z_axis, z_axis_rms, OutputFile,$
;                x_loc=x_loc, y_loc=y_loc, radius=radius, /FIT_SAA
;                
;   iv) Fit all spectra within a region according to certain tolerance levels -
;       The user fits an SAA then the output values are used as free-parameter
;       inputs to all composite spectra. 
;       
;       CALLING SEQUENCE:
;       
;       SolnArr =data, data_rms, x_axis, y_axis, z_axis, z_axis_rms, OutputFile,$
;                x_loc=x_loc, y_loc=y_loc, radius=radius, tolerances=tolerances,$
;                /FIT_COMP_SPEC 
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

PRO SCOUSE_MANUAL_FITTING
Compile_Opt idl2

;------------------------------------------------------------------------------;
; USER INPUT
;------------------------------------------------------------------------------;

datadirectory = ''  
filename      = ''               ; The data cube to be analysed
fitsfile      = filename+'.fits' ; fits extension
vunit         = 1000.0           ; if FITS header has units of m/s; conv from m/s to km/s
OutputFile    = ''
v_range       = [0.0, 0.0]       ; Range over which to fit the data
 
;------------------------------------------------------------------------------;
; SINGLE SPECTRUM
;------------------------------------------------------------------------------;

xpos = 0.0 ; x location of the spectrum to be fit
ypos = 0.0 ; y location of the spectrum to be fit

;------------------------------------------------------------------------------;
; MUTLIPLE SPECTRA
;------------------------------------------------------------------------------;

;positionFile  = datadirectory+'test.dat' ; A file containing the x and y locations of the spectra

;------------------------------------------------------------------------------;
; SPATIALLY AVERAGED SPECTRUM
;------------------------------------------------------------------------------;

;x0     = 0.0 ; Central x location of the region to be fit
;y0     = 0.0 ; Central y location of the region to be fit
;radius = 40.0 ; Radius surrounding x and y to fit

;------------------------------------------------------------------------------;
; FIT ALL SPECTRA TAKEN WITH A REGION USING AN SAA SOLUTION
;------------------------------------------------------------------------------;

;x0            = 0.0  ; Central x location of the region to be fit
;y0            = 0.0  ; Central y location of the region to be fit
;radius        = 0.0  ; Radius surrounding x and y to fit
;T1            = 0.0  ; * RMS - minimum intensity of components
;T2            = 0.0  ; * vel res - minimum width of components
;T3            = 0.0  ; Difference in dispersion from relevent component in SAA fit
;T4            = 0.0  ; Difference in velocity from relevent component in SAA fit
;T5            = 0.0  ; Difference in velocity between adjacent components (in units of FWHM)
;velo_res      = 0.0  ; Velocity resolution
;tolerances    = [ T1, T2, T3, T4, T5, velo_res ]

;------------------------------------------------------------------------------;
; FILE INPUT AND AXES CREATION
;------------------------------------------------------------------------------;

data       = FILE_READ( datadirectory, fitsfile, x=x_axis, y=y_axis, z=z_axis, header=HDR_DATA, /OFFSETS )
z_axis     = z_axis/vunit
ID         = WHERE(z_axis GT MIN(v_range) AND z_axis LT MAX(v_range))
z_axis_rms = z_axis
z_axis     = z_axis[ID]
data_rms   = data
data       = data[*,*,MIN(ID):MAX(ID)]

OPENW, 1, OutputFile
CLOSE, 1
 
;------------------------------------------------------------------------------;
; BEGIN ANALYSIS
;------------------------------------------------------------------------------;

PRINT, ''
PRINT, 'Beginning analysis...'
PRINT, ''

;------------------------------------------------------------------------------;
; MAIN ROUTINE
;------------------------------------------------------------------------------;

SolnArr = FIT_MANUAL_SELECTION( data, data_rms, x_axis, y_axis, z_axis, z_axis_rms, OutputFile, $
                                x_loc = x_loc, y_loc = y_loc, /FIT_SINGLE) 

;------------------------------------------------------------------------------;

END
