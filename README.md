# SCOUSE

Semi-automated multi-COmponent Universal Spectral-line fitting Engine

Copyright (c) 2015 Jonathan D. Henshaw

About
=====

SCOUSE is a spectral line fitting algorithm. The current version fits Gaussian
files to spectral line emission. Please refer to
[Henshaw et al. 2016](http://ukads.nottingham.ac.uk/abs/2016arXiv160103732H)
for further information.

<img src="images/Figure_cartoon.png"  alt="" width = "850" />

Installation
============

The function files need to be located in the working directory, or in some other
location specified in your IDL_PATH.

SCOUSE also uses the following (publicly available) libraries:

The IDL Astronomy User's Library:

http://idlastro.gsfc.nasa.gov/homepage.html

IDL Coyote:

http://www.idlcoyote.com/documents/programs.php#COYOTE_LIBRARY_DOWNLOAD

Markwardt IDL:

http://purl.com/net/mpfit

Note that SCOUSE was developed in IDL 8.3. It is possible that there may be some
issues for IDL 7 users.

Terms of use
============

If you use SCOUSE please cite the paper in which it is presented:
Henshaw et al. 2016, MNRAS, 457, 2675

Information
===========

JUNE 2016

**Important: Work around for issue with coordinates - added keyword optional
"/PIXELS" to file_read.pro - this will output pixel values instead of absolute
coordinates or offset coordinates. This keyword is available in release v0.1.1.
**

**Users are strongly advised to make use of either the /OFFSETS or /PIXELS
keywords in 'file_read' and to double-check the output. Although this issue does
not affect the fitting process it can affect the output coordinates
(see issues).**

DECEMBER 2016

**Important: XQuartz update causing SCOUSE to crash...problem (and fix) outlined
here http://blogs.qub.ac.uk/screenshotsfromtheedge/2016/10/25/xquartz-2-7-10-and-libxt-motif-idl/**

The method is broken down into seven stages. The codes used to implement each
stage of the process can be found in the directory SCOUSE/SCOUSE_main.
Each stage is summarised below.

Stage 1
=======
	Here SCOUSE identifies the spatial area over which to fit the data. It
	generates a grid of spectral averaging areas (SAAs). The user is required to
	provide several input values. Please refer to stage_1.pro for more details on
	these.

Stage 2
=======

	User-interactive fitting of the spatially averaged spectra output from
	stage 1.

Stage 3
=======

	Non user-interactive fitting of individual spectra contained within all SAAs.
	The user is required to input several tolerance levels to SCOUSE. Please refer
	to Henshaw+ 2015 for more details on each of these.

Stage 4
=======

	Here SCOUSE selects the best-fits that are output in stage 3.

OPTIONAL STAGES
===============

Unfortunately there is no one-size-fits-all method to selecting a best-fitting
solution when multiple choices are available (stage 4). SCOUSE uses the Akaike
Information Criterion, which weights the chisq of a best-fitting solution
according to the number of free-parameters.

While AIC does a good job of returning the best-fitting solutions, there are
areas where the best-fitting solutions can be improved. As such the following
stages are optional but *highly recommended*.

Given the level of user interaction, this is the most time-consuming part of the
routine. However, changing the tolerance levels in stage 3 can help. A quick run
through of stage 5 is recommended to see whether or not the tolerance levels
should be changed. Once the user is satisfied with the tolerance levels of
stage 3, a more detailed inspection of the spectra should take place.

Depending on the data a user may wish to perform a few iterations of Stages 5-7.

Stage 5
=======

	Checking the fits. Here the user is required to check the best-fitting
	solutions to the spectra. The user enters the indices of spectra that they
	would like to revisit. One can typically expect to re-analyse (stage 6) around
	5-10% of the fits. However, this is dependent on the complexity of the
	spectral line profiles.

Stage 6
=======

	Re-analysing the identified spectra. In this stage the user is required to
	either select an alternative solution or re-fit completely the spectra
	identified in stage 5.

Stage 7
=======

	SCOUSE then integrates these new solutions into the solution file.
