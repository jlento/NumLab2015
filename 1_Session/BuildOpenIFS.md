**LABORATORY COURSE IN NUMERICAL METEOROLOGY**  
**Exercise 1, Wed Dec 17 13:00-15:00 2015, D200**

## Introduction

In this first exercise we 1) build OpenIFS atmosphere model from
sources, and 2) test that the executable we produced actually
works. We will return to many of the steps in this exercise in more
detail in the later exercises and lectures. **NOTE:** *Basic knowledge
on how to work with linux command line is required for the exercises.*

The exercises are done in CSC's cluster `taito.csc.fi`. If you already
do not have a user account on taito, sign in into <https://sui.csc.fi>
with your HAKA authentication, and apply for the CSC user account. The
main technical documentation about CSC's supercomputing environment for
the exercises is

* CSC computing environment user guide: <https://research.csc.fi/csc-guide>
* Taito Users Guide: <https://research.csc.fi/taito-user-guide>

The build procedure follows the ECMWF's documentation

* OpenIFS User guide: [https://software.ecmwf.int/wiki/display/OIFS/User+Guide](https://software.ecmwf.int/wiki/display/OIFS/User+Guide)


## Software prerequisites

Taito uses a module system to manage which versions of the software
packages are active in the user's environment. The first command below
cleans up the current module environment, i.e. unloads all
modules. The second command loads a specified version of the compiler,
the MPI library and the math library into the current environment

~~~~
module purge
module load intel/15.0.0 intelmpi/5.0.1 mkl/11.2.0
~~~~


## Acquiring the OpenIFS source

**First:** *OpenIFS is not open source. Do not distribute it!*

OpenIFS source file archive `oifs38r1v04.tar.gz` is already downloaded
from `ftp.ecmwf.int` to a local disk at CSC. Ask the instructors where
to find it on taito.

First, let's make a directory for the sources, move there, and extract
the files from the archive file

~~~~
mkdir -p $WRKDIR/oifs
cd $WRKDIR/oifs
tar xvf <PATH TO ARCHIVE>/oifs38r1v04.tar.gz
~~~~


## Building OpenIFS

The general build instructions are in
<https://software.ecmwf.int/wiki/display/OIFS/Building+OpenIFS>. In
taito for this exercise

1. go to build directory
2. add build tool `fcm` to the shell's command search path
3. define the compiler and optimization level
4. define the location (prefix) of the grib_api library
5. execute OpenIFS's build command `fcm`

~~~~
cd oifs38r1v04/make
export PATH=$PATH:$WRKDIR/oifs/oifs38r1v04/fcm/bin
export OIFS_COMP=intel_mkl
export OIFS_BUILD=opt
export OIFS_GRIB_API_DIR="/appl/climate/intel1500"
fcm make --new -v -j 4 -f oifs.cfg
~~~~


## Testing the installation

The general instructions for testing OpenIFS are in
<https://software.ecmwf.int/wiki/display/OIFS/Testing+the+installation>. In
taito for this exercise

1. go to the test directory
2. edit `fort.4` file to run the "Acceptance testing" job, as described in
   ECMWF's documentation
   <https://software.ecmwf.int/wiki/display/OIFS/Testing+the+installation>,
   with 1 MPI task (`NPROC=1`)
3. define where to find auxiliary grib_api files
4. add grib_api shared library to the linker runtime search path
5. launch the job

~~~~
cd ../t21test
# Edit fort.4
export GRIB_SAMPLES_PATH= \
  /appl/climate/intel1500/share/grib_api/ifs_samples/grib1_mlgrib2
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/appl/climate/intel1500/lib
srun -n 1 -p test -t 5 \
  $WRKDIR/oifs/oifs38r1v04/make/intel_mkl-opt/oifs/bin/master.exe -e epc8
~~~~

Next, check that the test works also with multiple MPI tasks

1. change the number of MPI tasks to 4 (`NPROC=4`) in `fort.4`
2. launch the job again

~~~~
srun -n 1 -p test -t 5 \
  $WRKDIR/oifs/oifs38r1v04/make/intel_mkl-opt/oifs/bin/master.exe -e epc8
~~~~


**NOTE:** *OpenMP thread parallelization does not work in this build!*


## Some additional comments

$WRKDIR is not the optimal disk area to hold the source files or for
compilation. Here it is chosen for convenience and brevity of the
instructions.

The executable produced by this build procedure fails if OpenMP thread
parallelization is turned on (`OMP_NUM_THREADS > 1`). There is a bug
either in the OpenIFS source or in the Intel compiler (or in both).


## Extra exercise, build and run OpenIFS on a local workstation/laptop

It is possible to build OpenIFS and run small test cases on a Linux
workstation, laptop or virtual machine. Most build dependencies can be
installed using the package manager. Linux Mint 17, with GNU compiler
suite (gcc and gfortran) has been tested and works, provided OpenMP
parallelization in OpenIFS is turned off (remove `-fopenmp` flag from
compile and link configure options)

## Reporting

a\) If the model runs nicely, something like this should appear to
the console

~~~~
...
signal_drhook(SIGSYS=31): New handler installed at 0x12cea55; old preserved at 0x0
MPL_BUFFER_METHOD:  2    32000000
  15:42:57 STEP    0 H=   0:00 +CPU=  3.363
  15:42:57 STEP    1 H=   0:10 +CPU=  0.371
  15:42:58 STEP    2 H=   0:20 +CPU=  0.371
  15:42:58 STEP    3 H=   0:30 +CPU=  0.371
  15:42:58 STEP    4 H=   0:40 +CPU=  0.368
  15:42:59 STEP    5 H=   0:50 +CPU=  0.368
  15:42:59 STEP    6 H=   1:00 +CPU=  0.357
~~~~

Describe briefly, what information is printed to the console. How does
the run time for a single time step change when using four MPI tasks
instead of one? Which file contains most of the text output related to
the test runs?

b\) What problems did you encounter while trying to do the test runs?

**Email your answers to Olle Räty (olle.raty@helsinki.fi) by 18pm 22
  January, latest.**
