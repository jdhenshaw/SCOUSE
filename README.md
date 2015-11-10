# SCOUSE

Semi-automated multi-COmponent Universal Spectral-line fitting Engine
Copyright (c) 2015 Jonathan D. Henshaw

About
=====

SCOUSE is a spectral line fitting algorithm. The current version fits Gaussian
files to spectral line emission. Please refer to Henshaw+ 2015 for further
information.

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

Information
===========

The method is broken down into seven stages. The codes used to implement each
stage of the process can be found in the directory SCOUSE/SCOUSE_frontmatter.
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
