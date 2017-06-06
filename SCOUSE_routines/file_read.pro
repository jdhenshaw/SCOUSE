;+
;
; PROGRAM NAME:
;   FILE READ
;   
; PURPOSE:
;   This program is used to read a FITS file and create the axes
;   
; CALLING SEQUENCE:
; 
;   im = FILE_READ( directory, filename, x=x, y=y, z=z, header=hdr )
;   
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;   
;-

FUNCTION FILE_READ, dir, file, x=x, y=y, z=z, header = header, OFFSETS=offpos
Compile_Opt idl2

;------------------------------------------------------------------------------;
; READ FITS
;------------------------------------------------------------------------------;

image = MRDFITS(dir+file, 0, header)

; Generic properties

naxis     = SXPAR(header,'NAXIS')    ; Number of axes 
beam_maj  = SXPAR(header,'BMAJ')     ; Beam size major axis
beam_min  = SXPAR(header,'BMIN')     ; Beam size minor axis
beam_pa   = SXPAR(header,'BPA')      ; Beam position angle
bunit     = SXPAR(header,'BUNIT')    ; Units for data
restfreq  = SXPAR(header,'RESTFREQ') ; Rest frequency in Hz
x0        = SXPAR(header,'CRVAL1')
y0        = SXPAR(header,'CRVAL2')

IF naxis EQ 2.0 THEN BEGIN             ; Continuum data
  
  naxis1 = SXPAR(header,'NAXIS1')    ; Number of x-axis pixels
  crpix1 = SXPAR(header,'CRPIX1')    ; Reference x-axis pixel
  cdelt1 = SXPAR(header,'CDELT1')    ; Step size in x-axis 
  crval1 = SXPAR(header,'CRVAL1')    ; Coord value for x-axis reference pixel 
  ctype1 = SXPAR(header,'CTYPE1')    ; Co-ordinate system for x-axis
  naxis2 = SXPAR(header,'NAXIS2')    ; Number of y-axis pixels
  crpix2 = SXPAR(header,'CRPIX2')    ; Reference y-axis pixel
  cdelt2 = SXPAR(header,'CDELT2')    ; Step size in y-axis
  crval2 = SXPAR(header,'CRVAL2')    ; Coord value for y-axis reference pixel
  ctype2 = SXPAR(header,'CTYPE2')    ; Co-ordinate system for y-axis
  
  x = ((cdelt1*(FINDGEN(naxis1)+1-crpix1))/COS(y0*((2.0*!pi)/360.0)))+crval1 ; Create the axes
  y = (cdelt2*(FINDGEN(naxis2)+1-crpix2))+crval2
  z = -1
  
  
ENDIF ELSE BEGIN ; Spectral line data

  naxis1 = SXPAR(header,'NAXIS1') 
  crpix1 = SXPAR(header,'CRPIX1') 
  cdelt1 = SXPAR(header,'CDELT1')
  crval1 = SXPAR(header,'CRVAL1') 
  ctype1 = SXPAR(header,'CTYPE1') 
  naxis2 = SXPAR(header,'NAXIS2') 
  crpix2 = SXPAR(header,'CRPIX2') 
  cdelt2 = SXPAR(header,'CDELT2') 
  crval2 = SXPAR(header,'CRVAL2') 
  ctype2 = SXPAR(header,'CTYPE2') 
  naxis3 = SXPAR(header,'NAXIS3')    ; Number of velocity axis pixels
  crpix3 = SXPAR(header,'CRPIX3')    ; Reference velocity axis pixel
  cdelt3 = SXPAR(header,'CDELT3')    ; Step size in velocity axis 
  crval3 = SXPAR(header,'CRVAL3')    ; Value for velocity axis reference pixel 
  ctype3 = SXPAR(header,'CTYPE3')    ; Co-ordinate system for z-axis 

  x = ((cdelt1*(FINDGEN(naxis1)+1-crpix1))/COS(y0*((2.0*!pi)/360.0)))+crval1 ; Create the axes
  y = (cdelt2*(FINDGEN(naxis2)+1-crpix2))+crval2
  z = (cdelt3*(FINDGEN(naxis3)+1-crpix3))+crval3
ENDELSE

IF (KEYWORD_SET(offpos)) THEN BEGIN
  CREATE_OFFSETS, x, y, x0, y0, x_off=x_off, y_off=y_off
  x = x_off
  y = y_off
ENDIF

;------------------------------------------------------------------------------;

RETURN, image

END


