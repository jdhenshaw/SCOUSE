FUNCTION create_offsets, raaxis, decaxis, crval1, crval2, ra_offsets=ra_offsets, dec_offsets=dec_offsets

;-----------------------------------------------------------------------------;
;
; NAME:
;   create_offsets
;
;-----------------------------------------------------------------------------;
;
; PURPOSE:
;   This program creates offset right ascension and declination given the central coordinates of a map. 
;
;-----------------------------------------------------------------------------;
; +
;
; SCOUSE - Semi-automated multi-COmponent Universal Spectral-line fitting Engine
; Copyright (c) 2015 Jonathan D. Henshaw
;
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions are met:
;
;   * Redistributions of source code must retain the above copyright notice,
;      this list of conditions and the following disclaimer.
;
;   * Redistributions in binary form must reproduce the above copyright
;     notice, this list of conditions and the following disclaimer in the
;     documentation and/or other material provided with the distribution.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHOR OR COPYRIGHT HOLDER BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
; THE SOFTWARE.
;
;-----------------------------------------------------------------------------;
;
; :Author:
;    Jonathan D. Henshaw
;       E-mail: j.d.henshaw@ljmu.ac.uk
;
; :History:
;    Modification history:
;
;-
;-----------------------------------------------------------------------------;

Compile_Opt idl2

;-----------------------------------------------------------------------------;

raaxis_hrs = (raaxis/360.0)*24.0 ; ra in hrs

ra_offsets = replicate(!values.f_nan,n_elements(raaxis))
for i=0, n_elements(raaxis)-1 do begin
  ra_offsets[i] = ((raaxis_hrs[i]-(crval1/360.0)*24.0)*3600.0)*15.0*cos(((crval2/360.0)*2.0*!pi))
endfor

dec_offsets = replicate(!values.f_nan,n_elements(decaxis))
for i=0, n_elements(decaxis)-1 do begin
  dec_offsets[i] = (decaxis[i]-crval2)*3600.0
endfor

;-----------------------------------------------------------------------------;
 
 END