FUNCTION file_preparation, input_file, vunit, image, x_axis, y_axis, z_axis, $
                           HDR_DATA, data_rms = data_rms, $
                           z_axis_rms = z_axis_rms, HDR_NEW=HDR_NEW
;------------------------------------------------------------------------------;
; Copyright (c) 2015 Jonathan D. Henshaw
; CONTACT: j.d.henshaw@ljmu.ac.uk
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
;------------------------------------------------------------------------------;
Compile_Opt idl2
;------------------------------------------------------------------------------;
; FILE INPUT
;------------------------------------------------------------------------------;

; First read in data stored in the input file. This contains information about 
; the extent of the region that is to be analysed

readcol, input_file, inputs, /silent

; Retain one file that has been trimmed in position, but not in velocity. 
; This can be used to calculate the rms.

image_rms = image
z_axis_rms = z_axis

;------------------------------------------------------------------------------;
; TRIM THE DATA FILES
;------------------------------------------------------------------------------;
;
; Trim velocity according to input file

if inputs[1] ne 1000.0 and inputs[0] ne -1000.0 then begin
  ID   = where(z_axis gt inputs[0] and z_axis lt inputs[1])
  z_axis = z_axis[min(ID):max(ID)]
  image = image[*,*,min(ID):max(ID)]
endif

; Trim xaxis 

if inputs[3] ne 1000.0 and inputs[2] ne -1000.0 then begin
  ID   = where(x_axis gt inputs[2] and x_axis lt inputs[3])
  x_axis = x_axis[min(ID):max(ID)]
  image = image[min(ID):max(ID),*,*]
  image_rms = image_rms[min(ID):max(ID),*,*]
endif

; Trim yaxis

if inputs[5] ne 1000.0 and inputs[4] ne -1000.0 then begin
  ID   = where(y_axis gt inputs[4] and y_axis lt inputs[5])
  y_axis = y_axis[min(ID):max(ID)]
  image = image[*,min(ID):max(ID),*]
  image_rms = image_rms[*,min(ID):max(ID),*]
endif

;------------------------------------------------------------------------------;
; UPDATE/CREATE NEW HEADER
;------------------------------------------------------------------------------;
HDR_NEW = HDR_DATA
sxaddpar, HDR_NEW, 'CRPIX1', 1.0
sxaddpar, HDR_NEW, 'CRVAL1', x_axis[0]
sxaddpar, HDR_NEW, 'CRPIX2', 1.0
sxaddpar, HDR_NEW, 'CRVAL2', y_axis[0]
sxaddpar, HDR_NEW, 'CRPIX3', 1.0
sxaddpar, HDR_NEW, 'CRVAL3', z_axis[0]*vunit
sxaddpar, HDR_NEW, 'NAXIS1', n_elements(x_axis)
sxaddpar, HDR_NEW, 'NAXIS2', n_elements(y_axis)
sxaddpar, HDR_NEW, 'NAXIS3', n_elements(z_axis)
;------------------------------------------------------------------------------;
; END PROCESS
;-----------------------------------------------------------------------------;
return, image

END



