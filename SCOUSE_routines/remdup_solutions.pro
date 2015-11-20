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

PRO REMDUP_SOLUTIONS, InFile, Infofile, OutFile
Compile_Opt idl2

;------------------------------------------------------------------------------;
;
;------------------------------------------------------------------------------;

READCOL, InfoFile, xpos, ypos, xindx, yindx, combindx, nlines=npos, /silent
indArr  = [[xpos], [ypos], [xindx], [yindx], [combindx]]
READCOL, InFile, n, xpos, ypos, int, sint, vel, svel, fwhm, sfwhm, rms, resid, totchisq, dof, chisqred, AIC, nlines=nfits, /silent
SolnArr = [[n],[xpos],[ypos],[int],[sint],[vel],[svel],[fwhm],[sfwhm],[rms],[resid],[totchisq],[dof],[chisqred],[AIC]]

OPENW, 1, OutFile, width = 200
CLOSE, 1

FOR i = 0, N_ELEMENTS(indArr[*,0])-1 DO BEGIN 
  ID_pos = WHERE(SolnArr[*,1] EQ indArr[i,0] AND SolnArr[*,2] EQ indArr[i,1])
  
  ; Every position should have a unique alternative, these will be stored for
  ; use with the latter stages
  
  SolnArr_nofit = [[0.0],[indArr[i,0]],[indArr[i,1]],[0.0],[0.0],[0.0],[0.0],[0.0],[0.0],[SolnArr[ID_pos[0],9]],[SolnArr[ID_pos[0],10]],[1000.0],[1000.0],[1000.0],[1000.0]]
  SolnArr_trim = 0.0 
  
  IF ID_pos[0] NE -1.0 THEN BEGIN       
    
    
    SolnArr_trim = SolnArr[ID_pos, *]                                      ; Trim array to focus only on a single position
    ID_nofit = WHERE(SolnArr_trim[*,0] EQ 0.0)                             ; Find where there is no best fitting solution
    IF ID_nofit[0] EQ -1 THEN SolnArr_trim = [SolnArr_trim, SolnArr_nofit] ; If there isn't already a best fitting solution with 0 components, add one
    ID_nofit     = WHERE(SolnArr_trim[*,0] EQ 0.0)                         ; Find where there is no best fitting solution 
    SolnArr_uniq = SolnArr_trim[ID_nofit[0],*]                             ; Create an array that is going to contain only unique solutions     
    uniq_indx    = REM_DUP(SolnArr_trim[*, 11])                            ; Find unique values of the residual
    
    FOR j = 0, N_ELEMENTS(uniq_indx)-1 do begin                            ; Cycle through the unique values
      
      uniq_resid = SolnArr_trim[uniq_indx[j],11]                           ; Value of the unique residual
      ID_uniq = WHERE(SolnArr_trim[*,11] EQ uniq_resid)                    ; Indices of this resid
      SolnArr_uniq_fit = SolnArr_trim[ID_uniq, *]                          ; Solutions with this resid  
        
      ; For those solutions extract unique parameter values, I, V, and FWHM
      
      ID_remdup = REM_DUP(SolnArr_uniq_fit[*, 3]) 
      SolnArr_remdup = SolnArr_uniq_fit[ID_remdup, *]     
      ID_remdup = REM_DUP(SolnArr_remdup[*, 5])
      SolnArr_remdup = SolnArr_remdup[ID_remdup, *]    
      ID_remdup = REM_DUP(SolnArr_remdup[*, 7])
      SolnArr_remdup = SolnArr_remdup[ID_remdup, *]
      
      ; If the number of components with the unique residual is greater
      ; than the number of components fitted, this indicates that there are
      ; still non-unique solutions for this residual value.
      
      IF N_ELEMENTS(SolnArr_remdup[*,0]) NE SolnArr_remdup[0,0] AND $
         SolnArr_remdup[0,0] NE 0.0 THEN BEGIN
         
         ; Start with the velocity
          
         Soln_vel  = FLOAT(ROUND(SolnArr_remdup[*,5]*100.0)/100.0)   
         ID_remdup = REM_DUP(Soln_vel)
         SolnArr_remdup = SolnArr_remdup[ID_remdup, *] 
         
         IF N_ELEMENTS(SolnArr_remdup[*,0]) NE SolnArr_remdup[0,0] THEN BEGIN
           
           ; If there is still an issue, try the FWHM
          
           Soln_fwhm = FLOAT(ROUND(SolnArr_remdup[*,7]*100.0)/100.0)
           ID_remdup = REM_DUP(Soln_fwhm)
           SolnArr_remdup = SolnArr_remdup[ID_remdup, *]
           
           IF N_ELEMENTS(SolnArr_remdup[*,0]) NE SolnArr_remdup[0,0] THEN BEGIN
             ; As a last resort try the intensity. The intensity is most likely 
             ; to be influenced by the rounding. 
             Soln_int = FLOAT(ROUND(SolnArr_remdup[*,3]*10000.0)/10000.0)
             ID_remdup = REM_DUP(Soln_int)
             SolnArr_remdup = SolnArr_remdup[ID_remdup, *]
           ENDIF         
         ENDIF      
      ENDIF   
      SolnArr_uniq = [SolnArr_uniq, SolnArr_remdup] ; Concatenate with the current unique array        
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

    OUTPUT_INDIV_SOLUTION, SolnArr_uniq, OutFile 
    
  ENDIF
ENDFOR


;------------------------------------------------------------------------------;

END