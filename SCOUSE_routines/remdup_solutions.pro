;+
;
; PROGRAM NAME:
;   REMOVE DUPLICATE SOLUTIONS
;
; PURPOSE:
;   Removes all duplicate solutions. This is based on the residual value, which
;   should be unique to a given solution. 
;
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-

FUNCTION REMDUP_SOLUTIONS, InFile, Infofile, OutFile
Compile_Opt idl2

;------------------------------------------------------------------------------;
;
;------------------------------------------------------------------------------;

READCOL, InfoFile, xpos, ypos, xindx, yindx, combindx, nlines=npos, /silent
indArr = [[xpos], [ypos], [xindx], [yindx], [combindx]]
READCOL, InFile, n, xpos, ypos, int, sint, vel, svel, fwhm, sfwhm, rms, resid, totchisq, dof, chisqred, AIC, nlines=nfits, /silent
SolnArr = [[n],$
          [xpos],[ypos],$
          [int],[sint],$
          [vel],[svel],$
          [fwhm],[sfwhm],$
          [rms],[resid],$
          [totchisq],[dof],[chisqred],[AIC]]

OPENW, 1, OutFile, width = 200
CLOSE, 1

FOR i = 0, N_ELEMENTS(indArr[*,0])-1 DO BEGIN
  
  ; Every position should have a unique alternative, these will be stored for
  ; use with the latter stages
  
  SolnArr_nofit = [[0.0],$
                   [indArr[i,0]],[indArr[i,1]],$
                   [0.0],[0.0],$
                   [0.0],[0.0],$
                   [0.0],[0.0],$
                   [mean(rms)],[mean(resid)],$
                   [1000.0],[1000.0],[1000.0],[1000.0]]
  
  SolnArr_trim = 0.0 
  ID_pos = WHERE(SolnArr[*,1] EQ indArr[i,0] AND SolnArr[*,2] EQ indArr[i,1])
  
  IF ID_pos[0] NE -1.0 THEN BEGIN       
    
    ; Trim array to focus only on a single position
    SolnArr_trim = SolnArr[ID_pos, *] 
    
    ; Find where there is no best fitting solution
     
    ID_nofit = WHERE(SolnArr_trim[*,0] EQ 0.0)
    
    ; If there isn't already a best fitting solution with 0 components, add one
    
    IF ID_nofit[0] EQ -1 THEN SolnArr_trim = [SolnArr_trim, SolnArr_nofit] 
    
    ; Find where there is no best fitting solution
    
    ID_nofit     = WHERE(SolnArr_trim[*,0] EQ 0.0)
    
    ; Create an array that is going to contain only unique solutions
    
    SolnArr_uniq = SolnArr_trim[ID_nofit[0],*]    
    
    ; Find unique values of the residual
    
    uniq_indx    = REM_DUP(SolnArr_trim[*, 10]) 
    
    ; For each unique residual value, find out how many components have that 
    ; value. If the number of components with the unique residual is greater
    ; than the number of components fitted, this indicates that there are 
    ; non-unique solutions for this residual value.  
           
    FOR j = 0, N_ELEMENTS(uniq_indx)-1 do begin
      
      uniq_resid = SolnArr_trim[uniq_indx[j],10] ; Value of the unique residual
      ID_uniq = WHERE(SolnArr_trim[*,10] EQ uniq_resid) ; Indices of this resid
      SolnArr_uniq_fit = SolnArr_trim[ID_uniq,*] ; Solutions with this resid  
      
      ; For those solutions extract unique parameter values, I, V, and FWHM
      
      ID_remdup = REM_DUP(SolnArr_uniq_fit[*, 3]) 
      SolnArr_remdup = SolnArr_uniq_fit[ID_remdup, *]
       
      ID_remdup = REM_DUP(SolnArr_remdup[*, 5])
      SolnArr_remdup = SolnArr_remdup[ID_remdup, *]  
      
      ID_remdup = REM_DUP(SolnArr_remdup[*, 7])
      SolnArr_remdup = SolnArr_remdup[ID_remdup, *]
      
      ; Concatenate with the current unique array
       
      SolnArr_uniq = [SolnArr_uniq, SolnArr_remdup]
    ENDFOR
    
    ; Now there may be non-unique solutions with zero components
    
    ID_nofit = WHERE(SolnArr_uniq[*,11] EQ 1000.0)
    ID_fit   = WHERE(SolnArr_uniq[*,11] NE 1000.0)
    
    ; Indentify if this is the case, and remove these instances
    
    SolnArr_nofit = SolnArr_uniq[ID_nofit[0],*]
    SolnArr_fit   = SolnArr_uniq[ID_fit,*]

    IF ID_fit[0] NE -1 THEN BEGIN
      SolnArr_uniq  = [SolnArr_nofit, SolnArr_fit]    
    ENDIF ELSE BEGIN
      SolnArr_uniq  = SolnArr_nofit
    ENDELSE
    
    ; Output the unique solution array

    output_solns = OUTPUT_INDIV_SOLUTION( SolnArr_uniq, OutFile )
    
  ENDIF

ENDFOR


;------------------------------------------------------------------------------;

END