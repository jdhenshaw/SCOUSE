FUNCTION file_preparation, input_file, vunit, image, x_axis, y_axis, z_axis, $
                           HDR_DATA, data_rms = data_rms, $
                           z_axis_rms = z_axis_rms, HDR_NEW=HDR_NEW
;------------------------------------------------------------------------------;
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
;------------------------------------------------------------------------------;
Compile_Opt idl2
;------------------------------------------------------------------------------;
; FILE INPUT
;------------------------------------------------------------------------------;

; First read in data stored in the input file. This contains information about 
; the extent of the region that is to be analysed

READCOL, input_file, inputs, /silent

; Retain one file that has been trimmed in position, but not in velocity. 
; This can be used to calculate the rms.

image_rms = image
z_axis_rms = z_axis

;------------------------------------------------------------------------------;
; TRIM THE DATA FILES
;------------------------------------------------------------------------------;
;
; Trim velocity according to input file

IF inputs[1] NE 1000.0 AND inputs[0] NE -1000.0 THEN BEGIN
  ID   = WHERE(z_axis GT inputs[0] AND z_axis LT inputs[1])
  z_axis = z_axis[MIN(ID):MAX(ID)]
  image = image[*,*,MIN(ID):MAX(ID)]
endif

; Trim xaxis 

IF inputs[3] NE 1000.0 AND inputs[2] NE -1000.0 THEN BEGIN
  ID   = WHERE(x_axis GT inputs[2] AND x_axis LT inputs[3])
  x_axis = x_axis[MIN(ID):MAX(ID)]
  image = image[MIN(ID):MAX(ID),*,*]
  image_rms = image_rms[MIN(ID):MAX(ID),*,*]
ENDIF

; Trim yaxis

IF inputs[5] NE 1000.0 AND inputs[4] NE -1000.0 THEN BEGIN
  ID   = WHERE(y_axis GT inputs[4] AND y_axis LT inputs[5])
  y_axis = y_axis[MIN(ID):MAX(ID)]
  image = image[*,MIN(ID):MAX(ID),*]
  image_rms = image_rms[*,MIN(ID):MAX(ID),*]
ENDIF

;------------------------------------------------------------------------------;
; UPDATE/CREATE NEW HEADER
;------------------------------------------------------------------------------;
HDR_NEW = HDR_DATA
SXADDPAR, HDR_NEW, 'CRPIX1', 1.0
SXADDPAR, HDR_NEW, 'CRVAL1', x_axis[0]
SXADDPAR, HDR_NEW, 'CRPIX2', 1.0
SXADDPAR, HDR_NEW, 'CRVAL2', y_axis[0]
SXADDPAR, HDR_NEW, 'CRPIX3', 1.0
SXADDPAR, HDR_NEW, 'CRVAL3', z_axis[0]*vunit
SXADDPAR, HDR_NEW, 'NAXIS1', N_ELEMENTS(x_axis)
SXADDPAR, HDR_NEW, 'NAXIS2', N_ELEMENTS(y_axis)
SXADDPAR, HDR_NEW, 'NAXIS3', N_ELEMENTS(z_axis)
;------------------------------------------------------------------------------;
; END PROCESS
;-----------------------------------------------------------------------------;
RETURN, image

END



