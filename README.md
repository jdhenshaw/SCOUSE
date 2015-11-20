# SCOUSE

Semi-automated multi-COmponent Universal Spectral-line fitting Engine

Copyright (c) 2015 Jonathan D. Henshaw

About
=====

SCOUSE is a spectral line fitting algorithm. The current version fits Gaussian
files to spectral line emission. Please refer to Henshaw et al. 2015
(submitted) for further information.

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

Terms of use
============

If you use SCOUSE please cite the paper in which it is presented:
Henshaw et al. 2015 (submitted)

Information
===========

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
