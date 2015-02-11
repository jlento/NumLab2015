% OpenIFS output and post-procesing
% Juha Lento
% January 30, 2015


Post-processing
===============

Rough guides
------------

- file I/O is the bottle neck in 90% of the cases
- the read/write speed is about 100MB/sec for
  any disk system
- if post-processing is slower than about 30MB/sec, it's time to
  investigate further


Design experiments
------------------

1. do the whole experiment from the model runs all the way to the
   visualizations with a comfortably small resolution (file sizes,
   queueing, running, post-processing,...)
2. repeat the process with the target resolution
3. only write the data you absolutely need from the application

**Saves your time in the development cycle, and gives a sensitivity
  experiment as a bonus**


Post-processing goals
---------------------

- store the data in compressed format
- only extract/convert the data you analyse
- filter out as much data as much as possible in the first step
- read/write the same data only once from the disk
- filter the same data with as few tools as possible
- with multiple tools use pipes


OpenIFS output
==============

File structure
--------------

![OpenIFS writes output to two GRIB formatted files at specified
 times.](include/OIFSOutput.svg)


Which way to slice the data?
----------------------------

1. All fields at single time step in one file ( ~ as output by OpenIFS)
2. All fields (levels?) in separate files as time series

*Answer depends on how you plan to analyse the data...*


GRIB files
----------

- are roughly 1/2 size of the corresponding NetCDF files --> store the
  data in GRIB
- two grib files simply concatenated is a grib file
- there are two formats, GRIB1 and GRIB2, and many tools only work
  with one of them...


OpenIFS GRIB files
------------------

- no(?) single post-processing or visualization tool can manage OpenIFS
  output files, which are a mix of GRIB1 and GRIB2 formats, different
  horisontal and vertical coordinate systems, etc.
- ICM\*(t=0) contains additional fields compared to ICM\*(t>0)
