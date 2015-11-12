FUNCTION create_offsets, raaxis, decaxis, crval1, crval2, $
                         ra_offsets=ra_offsets, dec_offsets=dec_offsets
;------------------------------------------------------------------------------;
; PROGRAM NAME:
;   CREATE OFFSETS
;
; PURPOSE:
;   This program creates offset right ascension and declination given the 
;   central coordinates of a map. 
;
; INFORMATION:
;   This program can and should be edited to the users taste and is
;   non-essential to SCOUSE
;
;   This code makes use of disp.pro written by Erik Rosolowski available here:
;   https://github.com/low-sky/idl-low-sky/blob/master/graphics/disp.pro
;
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, November 2015
;
;------------------------------------------------------------------------------;
Compile_Opt idl2
;------------------------------------------------------------------------------;

raaxis_hrs = (raaxis/360.0)*24.0

ra_offsets = replicate(!values.f_nan,n_elements(raaxis))
dec_offsets = replicate(!values.f_nan,n_elements(decaxis))
for i=0, n_elements(raaxis)-1 do begin
  ra_offsets[i] = ((raaxis_hrs[i]-(crval1/360.0)*24.0)*3600.0)*15.0$
                    *cos(((crval2/360.0)*2.0*!pi))
endfor
for i=0, n_elements(decaxis)-1 do begin
  dec_offsets[i] = (decaxis[i]-crval2)*3600.0
endfor

;------------------------------------------------------------------------------;
; END PROCESS
;------------------------------------------------------------------------------;

END