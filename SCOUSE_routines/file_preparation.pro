;+
;
; PROGRAM NAME:
;   FILE PREPARATION
;
; PURPOSE:
;   This program is prepares the data for further analysis based on the user 
;   inputs. It is primarily used to select only a specific region of a data 
;   cube.
;   
; NOTES:
;   Use the /OFFSETS keyword if you wish to return x/y axes in offset Ra and 
;   dec.
;   
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-

FUNCTION FILE_PREPARATION, image, x, y, z, header, info, vunit, iunit, $
                           image_rms=image_rms, z_rms=z_rms, header_new=header_new
Compile_Opt idl2

;------------------------------------------------------------------------------;
; FILE INPUT
;------------------------------------------------------------------------------;

; First read in data stored in the input file. This contains information about 
; the extent of the region that is to be analysed

READCOL, info, inputs, /silent
image_rms = image               ; These will be used during the rms calculation
z_rms     = z

;------------------------------------------------------------------------------;
; TRIM THE DATA FILES
;------------------------------------------------------------------------------;

; Trim velocity according to input file
IF inputs[1] NE 1000.0 AND inputs[0] NE -1000.0 THEN BEGIN
  ID = WHERE(z GE inputs[0] AND z LE inputs[1])
  z = z[MIN(ID):MAX(ID)]
  image = image[*,*,MIN(ID):MAX(ID)]
endif

; Trim xaxis 
IF inputs[3] NE 1000.0 AND inputs[2] NE -1000.0 THEN BEGIN
  ID   = WHERE(x GE inputs[2] AND x LE inputs[3])
  x = x[MIN(ID):MAX(ID)]
  image = image[MIN(ID):MAX(ID),*,*]
  image_rms = image_rms[MIN(ID):MAX(ID),*,*]
ENDIF

; Trim yaxis
IF inputs[5] NE 1000.0 AND inputs[4] NE -1000.0 THEN BEGIN
  ID = WHERE(y GE inputs[4] AND y LE inputs[5])
  y = y[MIN(ID):MAX(ID)]
  image = image[*,MIN(ID):MAX(ID),*]
  image_rms = image_rms[*,MIN(ID):MAX(ID),*]
ENDIF

;------------------------------------------------------------------------------;
; UPDATE/CREATE NEW HEADER
;------------------------------------------------------------------------------;

header_new = header
SXADDPAR, header_new, 'CRPIX1', 1.0
SXADDPAR, header_new, 'CRVAL1', x[0]
SXADDPAR, header_new, 'CRPIX2', 1.0
SXADDPAR, header_new, 'CRVAL2', y[0]
SXADDPAR, header_new, 'CRPIX3', 1.0
SXADDPAR, header_new, 'CRVAL3', z[0]*vunit
SXADDPAR, header_new, 'NAXIS1', N_ELEMENTS(x)
SXADDPAR, header_new, 'NAXIS2', N_ELEMENTS(y)
SXADDPAR, header_new, 'NAXIS3', N_ELEMENTS(z)

;------------------------------------------------------------------------------;

image     = image*iunit
image_rms = image_rms*iunit

RETURN, image

END



