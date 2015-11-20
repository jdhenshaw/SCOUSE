;+
;
; SCOUSE - Semi-automated multi-COmponent Universal Spectral-line fitting Engine
; Copyright (c) 2015 Jonathan D. Henshaw
; CONTACT: j.d.henshaw[AT]ljmu.ac.uk
;
; PROGRAM NAME:
;   SCOUSE check input file
;
; PURPOSE:
;   This program checks the FITS header of the file you wish to fit.
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

PRO SCOUSE_CHECK_INPUT_FILE
Compile_Opt idl2

;------------------------------------------------------------------------------;
; USER INPUT
;------------------------------------------------------------------------------;

datadirectory = ''  
filename      = '' ; The data cube to be analysed
fitsfile      = filename+'.fits' ; fits extension
vunit         = 1000.0

;------------------------------------------------------------------------------;
; READ .FITS FILE
;------------------------------------------------------------------------------;

image = FILE_READ(datadirectory, fitsfile, x=x_axis, y=y_axis, z=z_axis, header=HDR_DATA)
z_axis=z_axis/vunit

beam_maj  = SXPAR(HDR_DATA,'BMAJ')     ; Beam size major axis
beam_min  = SXPAR(HDR_DATA,'BMIN')     ; Beam size minor axis
beam_pa   = SXPAR(HDR_DATA,'BPA')      ; Beam position angle
naxis     = SXPAR(HDR_DATA,'NAXIS')    ; Number of axes (should be 3 for a cube)
naxis1    = SXPAR(HDR_DATA,'NAXIS1')   ; Number of x-axis (usually RA or l) pixels
crpix1    = SXPAR(HDR_DATA,'CRPIX1')   ; Reference x-axis pixel
cdelt1    = SXPAR(HDR_DATA,'CDELT1')   ; Step size in x-axis (degrees)
crval1    = SXPAR(HDR_DATA,'CRVAL1')   ; Coord value for x-axis reference pixel (degrees)
ctype1    = SXPAR(HDR_DATA,'CTYPE1')   ; Co-ordinate system for x-axis
naxis2    = SXPAR(HDR_DATA,'NAXIS2')   ; Number of y-axis (usually Dec or b) pixels
crpix2    = SXPAR(HDR_DATA,'CRPIX2')   ; Reference y-axis pixel
cdelt2    = SXPAR(HDR_DATA,'CDELT2')   ; Step size in y-axis (degrees)
crval2    = SXPAR(HDR_DATA,'CRVAL2')   ; Coord value for y-axis reference pixel (degrees)
ctype2    = SXPAR(HDR_DATA,'CTYPE2')   ; Co-ordinate system for y-axis
naxis3    = SXPAR(HDR_DATA,'NAXIS3')   ; Number of velocity axis pixels
crpix3    = SXPAR(HDR_DATA,'CRPIX3')   ; Reference velocity axis pixel
cdelt3    = SXPAR(HDR_DATA,'CDELT3')   ; Step size in velocity axis in m/s
crval3    = SXPAR(HDR_DATA,'CRVAL3')   ; Value for velocity axis reference pixel in m/s V_LSR
ctype3    = SXPAR(HDR_DATA,'CTYPE3')   ; Co-ordinate system for z-axis (velocity)
bunit     = SXPAR(HDR_DATA,'BUNIT')    ; Units for data
restfreq  = SXPAR(HDR_DATA,'RESTFREQ') ; Rest frequency in Hz

PRINT, HDR_DATA

;-----------------------------------------------------------------------------;

END