;+
;
; PROGRAM NAME:
;   FIT MANUAL SELECTION
;
; PURPOSE:
;   Find the best-fitting solution to a single spectrum or multiple spectra
;
;------------------------------------------------------------------------------;
; REVISION HISTORY:
;   Written by Jonathan D. Henshaw, 2015
;
;-
;

FUNCTION FIT_MANUAL_SELECTION, data, data_rms, x_axis, y_axis, z_axis, z_axis_rms, OutputFile, $
                               x_loc=x_loc, y_loc=y_loc, posfile=posfile, radius=radius, tolerances=tolerances, $
                               FIT_SINGLE=FS, FIT_SAMPLE=fSamp, FIT_SAA=Fsaa, FIT_COMP_SPEC=Fcs
Compile_Opt idl2

;------------------------------------------------------------------------------;

x     = z_axis
x_rms = z_axis_rms

IF (KEYWORD_SET(FS) && (N_ELEMENTS(x_loc) NE 0) && (N_ELEMENTS(y_loc) NE 0)) THEN BEGIN 

  xval = ABS(x_loc-x_axis)
  yval = ABS(y_loc-y_axis)

  ID_x = WHERE(xval EQ MIN(xval))
  ID_y = WHERE(yval EQ MIN(yval))
  
  x_loc_new  = x_axis[ID_x[0]]
  y_loc_new  = y_axis[ID_y[0]]
  
  y              = GET_SPEC( data, x, ID_x[0], ID_y[0])             
  y_rms          = GET_SPEC( data_rms, x_rms, ID_x[0], ID_y[0])
  rms_window_val = RMS_WINDOW( x_rms, y_rms, x_loc_new, y_loc_new, 'tmp.dat' )
  spectral_rms   = CALCULATE_RMS( x_rms, y_rms, rms_window_val )
  err_y          = REPLICATE(spectral_rms, N_ELEMENTS(y))               
  SolnArr        = FIT_MANUAL( x, x_rms, y, y_rms, err_y, x_loc_new, y_loc_new) 
  
  OUTPUT_INDIV_SOLUTION, SolnArr, OutputFile 
ENDIF

IF (KEYWORD_SET(FSamp) && (N_ELEMENTS(posfile) NE 0)) THEN BEGIN  
  READCOL, posfile, x_loc, y_loc
  
  FOR i = 0, N_ELEMENTS(x_loc)-1 DO BEGIN

    xval = ABS(x_loc[i]-x_axis)
    yval = ABS(y_loc[i]-y_axis)

    ID_x = WHERE(xval EQ MIN(xval))
    ID_y = WHERE(yval EQ MIN(yval))

    x_loc_new  = x_axis[ID_x[0]]
    y_loc_new  = y_axis[ID_y[0]]

    y              = GET_SPEC( data, x, ID_x[0], ID_y[0])
    y_rms          = GET_SPEC( data_rms, x_rms, ID_x[0], ID_y[0])
    rms_window_val = RMS_WINDOW( x_rms, y_rms, x_loc_new, y_loc_new, 'tmp.dat' )
    spectral_rms   = CALCULATE_RMS( x_rms, y_rms, rms_window_val )
    err_y          = REPLICATE(spectral_rms, N_ELEMENTS(y))
    SolnArr        = FIT_MANUAL( x, x_rms, y, y_rms, err_y, x_loc_new, y_loc_new)
    
    OUTPUT_INDIV_SOLUTION, SolnArr, OutputFile
  ENDFOR 
ENDIF


IF (KEYWORD_SET(Fsaa) && (N_ELEMENTS(x_loc) NE 0) && (N_ELEMENTS(y_loc) NE 0) && (N_ELEMENTS(radius) NE 0)) THEN BEGIN 
  ID_x           = WHERE(x_axis LT x_loc+radius AND x_axis GT x_loc-radius) 
  ID_y           = WHERE(y_axis LT y_loc+radius AND y_axis GT y_loc-radius)  
  
  y              = GET_SPEC( data, x, ID_x, ID_y)             
  y_rms          = GET_SPEC( data_rms, x_rms, ID_x, ID_y)
  rms_window_val = RMS_WINDOW( x_rms, y_rms, x_loc, y_loc, 'tmp.dat' )
  spectral_rms   = CALCULATE_RMS( x_rms, y_rms, rms_window_val )
  err_y          = REPLICATE(spectral_rms, N_ELEMENTS(y))               
  SolnArr        = FIT_MANUAL( x, x_rms, y, y_rms, err_y, x_loc, y_loc) 
  
  OUTPUT_INDIV_SOLUTION, SolnArr, OutputFile 
ENDIF

IF (KEYWORD_SET(Fcs) && (N_ELEMENTS(x_loc) NE 0) && (N_ELEMENTS(y_loc) NE 0) && (N_ELEMENTS(radius) NE 0) && (N_ELEMENTS(tolerances) NE 0)) THEN BEGIN

  ID_x           = WHERE(x_axis LT x_loc+radius AND x_axis GT x_loc-radius)
  ID_y           = WHERE(y_axis LT y_loc+radius AND y_axis GT y_loc-radius)

  y              = GET_SPEC( data, x, ID_x, ID_y)
  y_rms          = GET_SPEC( data_rms, x_rms, ID_x, ID_y)
  rms_window_val = RMS_WINDOW( x_rms, y_rms, x_loc, y_loc, 'tmp.dat' )
  spectral_rms   = CALCULATE_RMS( x_rms, y_rms, rms_window_val )
  err_y          = REPLICATE(spectral_rms, N_ELEMENTS(y))
  SaaSoln        = FIT_MANUAL( x, x_rms, y, y_rms, err_y, x_loc, y_loc)
  
  FOR k = 0, n_elements(ID_x)-1 DO BEGIN
    FOR l = 0, n_elements(ID_y)-1 DO BEGIN

      y              = GET_SPEC( data, x, ID_x[k], ID_y[l])
      y_rms          = GET_SPEC( data_rms, x_rms, ID_x[k], ID_y[l])
      spectral_rms   = CALCULATE_RMS( x_rms, y_rms, rms_window_val )
      err_y     = REPLICATE(spectral_rms, N_ELEMENTS(y))
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

      SolnArr = FIT_AUTO( x, y, err_y, x_axis[ID_x[k]], y_axis[ID_y[l]], param_est_init, tolerances, residual_array=ResArr )
      OUTPUT_INDIV_SOLUTION, SolnArr, OutputFile

    ENDFOR
  ENDFOR
ENDIF

;------------------------------------------------------------------------------;

RETURN, SolnArr

END