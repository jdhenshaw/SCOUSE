FUNCTION CREATE_OFFSETS, raaxis, decaxis, crval1, crval2, $
                         ra_offsets=ra_offsets, dec_offsets=dec_offsets
;------------------------------------------------------------------------------;
; PROGRAM NAME:
;   CREATE OFFSETS
;
; PURPOSE:
;   This program creates offset right ascension and declination given the 
;   central coordinates of a map. 
;
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, November 2015
;
;------------------------------------------------------------------------------;
Compile_Opt idl2
;------------------------------------------------------------------------------;

raaxis_hrs = (raaxis/360.0)*24.0

ra_offsets = REPLICATE(!values.f_nan,N_ELEMENTS(raaxis))
dec_offsets = REPLICATE(!values.f_nan,N_ELEMENTS(decaxis))
FOR i=0, N_ELEMENTS(raaxis)-1 DO BEGIN
  ra_offsets[i] = ((raaxis_hrs[i]-(crval1/360.0)*24.0)*3600.0)*15.0$
                    *COS(((crval2/360.0)*2.0*!pi))
ENDFOR
FOR i=0, N_ELEMENTS(decaxis)-1 DO BEGIN
  dec_offsets[i] = (decaxis[i]-crval2)*3600.0
ENDFOR

;------------------------------------------------------------------------------;
; END PROCESS
;------------------------------------------------------------------------------;

END