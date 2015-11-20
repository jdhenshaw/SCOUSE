;+
;
; SCOUSE - Semi-automated multi-COmponent Universal Spectral-line fitting Engine
; Copyright (c) 2015 Jonathan D. Henshaw
; CONTACT: j.d.henshaw[AT]ljmu.ac.uk
; 
; PROGRAM NAME:
;   SCOUSE - STAGE 3
;   
; PURPOSE:
;   This program is used to fit the individual spectra associated with each SAA.
;
; OUTPUT:
; 
;   indiv_solutions_*.dat - Ascii files containing the best-fitting solutions
;     to all spectra contained within the relevant SAA. The columns are:
;     
;     number of components, xpos, ypos, intensity, err_intensity, centroid vel,
;     err_centroid vel, FWHM, err_FWHM, spectral rms, residual, total chisq,
;     degrees of freedom, reduced chisq, AIC.
;   
;------------------------------------------------------------------------------;
;
; TERMS OF USE:
;   If you use SCOUSE for the analysis of molecular line data, please cite the
;   paper in which it is presented: Henshaw et al., 2015 (submitted)
;
;   If it is the first time you have used SCOUSE, J. D. Henshaw would appreciate
;   being involved in the project to provide assistance where necessary.
;   However, this is not required and you are free to use these routines as you
;   see fit.
;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;
;-

PRO SCOUSE_STAGE_3
Compile_Opt idl2

;------------------------------------------------------------------------------;
; USER INPUT; CONDITIONAL VALUES - SEE HENSHAW+ 2015
;------------------------------------------------------------------------------;


datadirectory = ''  
filename      = '         '       ; The data cube to be analysed
fitsfile      = filename+'.fits'  ; fits extension
vunit         = 1000.0            ; if FITS header has units of m/s; conv from m/s to km/s
T1            = 0.0               ; * RMS - minimum intensity of components
T2            = 0.0               ; * vel res - minimum width of components 
T3            = 0.0               ; Difference in dispersion from relevent component in SAA fit
T4            = 0.0               ; Difference in velocity from relevent component in SAA fit
T5            = 0.0               ; Difference in velocity between adjacent components (in units of FWHM)
velo_res      = 0.0               ; Velocity resolution

;------------------------------------------------------------------------------;
; FILE INPUT AND AXES CREATION
;------------------------------------------------------------------------------;

saasolutionfile = datadirectory+filename+'/STAGE_2/SAA_SOLUTIONS/SAA_solutions.dat'
cov_coordfile   = datadirectory+filename+'/STAGE_1/COVERAGE/coverage_coordinates.dat'
input_file      = datadirectory+filename+'/MISC/inputs.dat'
indivdirectory  = datadirectory+filename+'/STAGE_3/INDIV_SOLUTIONS/'
residdirectory  = datadirectory+filename+'/STAGE_3/INDIV_RESIDUALS/'

;------------------------------------------------------------------------------;
;
;------------------------------------------------------------------------------;

image  = FILE_READ( datadirectory, fitsfile, x=x_axis, y=y_axis, z=z_axis, header=HDR_DATA )   
z_axis = z_axis/vunit            
data   = FILE_PREPARATION( image, x_axis, y_axis, z_axis, HDR_DATA, input_file, vunit, image_rms=data_rms, z_rms=z_axis_rms, header=HDR_NEW, /OFFSETS )                            
READCOL, input_file, inputs, /silent
rsaa = inputs[6]  
READCOL, cov_coordfile, coverage_x, coverage_y, nlines=nlines, /silent
READCOL, saasolutionfile, n, x, y, int, sint, vel, svel, fwhm, sfwhm, rms, resid, totchisq, dof, chisqred, AIC, window_l, window_u, /silent        
            
;------------------------------------------------------------------------------;
; BEGIN ANALYSIS
;------------------------------------------------------------------------------;

PRINT, ''
PRINT, 'Beginning analysis...'
PRINT, ''
JOURNAL, datadirectory+filename+'/MISC/stagethree_log.dat'
starttime = SYSTIME(/seconds)
cgProgressBar = OBJ_NEW("cgProgressBar", /Cancel)
cgProgressBar -> Start

;==============================================================================;
; MAIN ROUTINE
; 
;   The program cycles through the coverage coordinates identified in stage 1.
;   It identfies all spectra associated with each SAA. 
;   
;   The best-fitting solutions to the spatially averaged spectra extracted from
;   each SAA are used as free parameter inputs to the composite spectra. The
;   user-defined tolerance levels determine the flexibility of the fitting.
;     
;==============================================================================;

; Create the arrays
SaaSolnArr = [[n],[x],[y],[int],[sint],[vel],[svel], [fwhm],[sfwhm], [rms], [resid], [totchisq], [dof], [chisqred], [resid], [window_l], [window_u]]
TolArr     = [ T1, T2, T3, T4, T5, velo_res ]

print,''
print, 'Tolerance values: ', TolArr[0:4]
print,''

count_val  = 0.0
n          = ''
ncount     = 0
spec_x     = z_axis
spec_x_rms = z_axis_rms

FOR i = 0, nlines-1 DO BEGIN
  
  IF cgProgressBar -> CheckCancel() THEN BEGIN
    k = DIALOG_MESSAGE('The user cancelled operation.')
    RETURN
  ENDIF
  cgProgressBar -> Update, (i/FLOAT(nlines))*100.0  

  indiv_file = indivdirectory+'indiv_solutions_'+STRING(i,format='(I03)')+'.dat' 
  OPENW, 1, indiv_file, width = 200
  CLOSE, 1   
  
  ID = WHERE(SaaSolnArr[*,1] EQ coverage_x[i] AND SaaSolnArr[*,2] EQ coverage_y[i])  
  
  IF ID[0] NE -1 THEN BEGIN         
    SaaSoln        = SaaSolnArr[ID,*]
    rms_window_val = [SaaSoln[0,15], SaaSoln[0,16]]
    ID_x           = WHERE(x_axis LE coverage_x[i]+rsaa AND x_axis GE coverage_x[i]-rsaa)
    ID_y           = WHERE(y_axis LE coverage_y[i]+rsaa AND y_axis GE coverage_y[i]-rsaa)  
  
    ; Begin fitting process
    
    FOR k = 0, n_elements(ID_x)-1 DO BEGIN
      FOR l = 0, n_elements(ID_y)-1 DO BEGIN 
        
        spec_y         = GET_SPEC( data, spec_x, ID_x[k], ID_y[l])
        spec_y_rms     = GET_SPEC( data_rms, spec_x_rms, ID_x[k], ID_y[l])
        spectral_rms   = CALCULATE_RMS( spec_x_rms, spec_y_rms, rms_window_val )
        err_spec_y     = REPLICATE(spectral_rms, N_ELEMENTS(spec_y))    
        param_est_init = REPLICATE(0d0, N_ELEMENTS(SaaSoln[*,0])*3.0) ; Initial guesses - SAA solution
      
        IF SaaSoln[0,0] EQ 0.0 THEN BEGIN
          param_est_init = [0.0,0.0,0.0]
        ENDIF ELSE BEGIN
          FOR j = 0, N_ELEMENTS(SaaSoln[*,0])-1 DO BEGIN
            param_est_init[(j*3.0)]     = SaaSoln[j,3]
            param_est_init[(j*3.0)+1.0] = SaaSoln[j,5]
            param_est_init[(j*3.0)+2.0] = SaaSoln[j,7]/(2.0*SQRT(2.0*ALOG(2.0))) 
          ENDFOR
        ENDELSE
    
        SolnArr = FIT_AUTO( spec_x, spec_y, err_spec_y, x_axis[ID_x[k]], y_axis[ID_y[l]], param_est_init, TolArr, residual_array=ResArr )       
        OUTPUT_INDIV_SOLUTION, SolnArr, indiv_file 
       
      ENDFOR
    ENDFOR 
  ENDIF
ENDFOR

;------------------------------------------------------------------------------;
cgProgressBar -> Destroy
endtime = (SYSTIME(/second)-starttime)/60.0
PRINT, ''
PRINT, 'Time for completion = '+STRING(endtime, format = '(F7.2)')+' minutes'
PRINT, ''
JOURNAL

END
