;+
;
; PROGRAM NAME:
;   FILE PREPARATION
;
; PURPOSE:
;   This program is prepares the data for further analysis based on the user 
;   inputs. It is primarily used to select only a specific region of a data 
;   cube.
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-

FUNCTION file_preparation, image, x, y, z, HDR_DATA, info, vunit, $ 
                           image_rms=image_rms, z_rms=z_rms, HDR_NEW=HDR_NEW
  
Compile_Opt idl2

;------------------------------------------------------------------------------;
; FILE INPUT
;------------------------------------------------------------------------------;

; First read in data stored in the input file. This contains information about 
; the extent of the region that is to be analysed

READCOL, info, inputs, /silent

; Retain one file that has been trimmed in position, but not in velocity. 
; This can be used to calculate the rms.

image_rms = image
z_rms = z

;------------------------------------------------------------------------------;
; TRIM THE DATA FILES
;------------------------------------------------------------------------------;
;
; Trim velocity according to input file

IF inputs[1] NE 1000.0 AND inputs[0] NE -1000.0 THEN BEGIN
  ID = WHERE(z GT inputs[0] AND z LT inputs[1])
  z = z[MIN(ID):MAX(ID)]
  image = image[*,*,MIN(ID):MAX(ID)]
endif

; Trim xaxis 

IF inputs[3] NE 1000.0 AND inputs[2] NE -1000.0 THEN BEGIN
  ID   = WHERE(x GT inputs[2] AND x LT inputs[3])
  x = x[MIN(ID):MAX(ID)]
  image = image[MIN(ID):MAX(ID),*,*]
  image_rms = image_rms[MIN(ID):MAX(ID),*,*]
ENDIF

; Trim yaxis

IF inputs[5] NE 1000.0 AND inputs[4] NE -1000.0 THEN BEGIN
  ID = WHERE(y GT inputs[4] AND y LT inputs[5])
  y = y[MIN(ID):MAX(ID)]
  image = image[*,MIN(ID):MAX(ID),*]
  image_rms = image_rms[*,MIN(ID):MAX(ID),*]
ENDIF

;------------------------------------------------------------------------------;
; UPDATE/CREATE NEW HEADER
;------------------------------------------------------------------------------;
HDR_NEW = HDR_DATA
SXADDPAR, HDR_NEW, 'CRPIX1', 1.0
SXADDPAR, HDR_NEW, 'CRVAL1', x[0]
SXADDPAR, HDR_NEW, 'CRPIX2', 1.0
SXADDPAR, HDR_NEW, 'CRVAL2', y[0]
SXADDPAR, HDR_NEW, 'CRPIX3', 1.0
SXADDPAR, HDR_NEW, 'CRVAL3', z[0]*vunit
SXADDPAR, HDR_NEW, 'NAXIS1', N_ELEMENTS(x)
SXADDPAR, HDR_NEW, 'NAXIS2', N_ELEMENTS(y)
SXADDPAR, HDR_NEW, 'NAXIS3', N_ELEMENTS(z)
;------------------------------------------------------------------------------;
RETURN, image

END



