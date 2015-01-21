**LABORATORY COURSE IN NUMERICAL METEOROLOGY**  
**Exercise 2, Fri Jan 23 14:15-16:00 2015, D210**

## Setup OpenIFS

Let's develop the steps that we made in the exercise\ 1 a bit further.


## Put the files into the right places

Let's make directories for the OpenIFS source, OpenIFS executable and
the scripts that we will write:

~~~~
mkdir -p ${HOME}/oifs/src
mkdir -p ${USERAPPL}/oifs/bin
mkdir -p ${USERAPPL}/oifs/scripts
~~~~

We put also the scripts under `${USERAPPL}` because they will only
work in taito, but not in sisu. If we were planning to write more
general scripts that would work in both machines, they would be better
placed under `${HOME}`.

Some commands to try, too:

~~~~
readlink -f ${USERAPPL}
mount
~~~~

## Split the "notes" to "subroutines"

There are two tasks that we wish to do

1. build OpenIFS from source 
2. run OpenIFS

We do not need to build OpenIFS every time we wish to run it, so it is
clearly a good idea to separate the tasks into respective scripts.  In
addition, it is easiest if both tasks are executed in the same
environment. Thus, we will make three scripts,

- `env.bash` for setting up the environment
- `build.bash` for building OpenIFS
- `t21test.bash` for running T21 resolution test case

## Environment setup

Module system takes care of most of the basic environment setup. In
addition, we set the environment variables `GRIB_SAMPLES_PATH` and
`LD_LIBRARY_PATH`, which are specific to our OpenIFS environment in
taito.

File `env.bash`:

~~~~
#!/bin/bash                                                                     
module purge
module load intel/15.0.0 intelmpi/5.0.1 mkl/11.2.0
export GRIB_SAMPLES_PATH=/appl/climate/intel1500/share/grib_api/ifs_samples/grib1_mlgrib2
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/appl/climate/intel1500/lib
~~~~


## Build OpenIFS

First, copy the OpenIFS source tar-ball `oifs38r1v04.tar.gz` to the
right place, your source directory `${HOME}/oifs/src`.

File `build.bash`:

~~~~
#!/bin/bash                                                                     

set -e

source ${USERAPPL}/oifs/scripts/env.bash

tarball=${HOME}/oifs/src/oifs38r1v04.tar.gz
builddir=${TMPDIR}
installdir=${USERAPPL}/oifs

test -f ${tarball}
mkdir -p ${builddir}
mkdir -p ${installdir}

export PATH=$PATH:${builddir}/oifs38r1v04/fcm/bin
export OIFS_COMP=intel_mkl
export OIFS_BUILD=opt
export OIFS_GRIB_API_DIR="/appl/climate/intel1500"

cd ${builddir}
tar xf ${tarball}
cd oifs38r1v04/make
fcm make --new -j 4 -f oifs.cfg
cp -f intel_mkl-opt/oifs/bin/* ${installdir}/bin
~~~~

The exercise is to add comments to the script that explain what each
line does. Comment lines begin with character "#" (don't touch the
first line). First try to get a general idea. Don't get stuck if some
line is more difficult, just take the next line and come back to the
difficult line later.

BTW, the command to execute the script is:

~~~~
bash ${USERAPPL}/oifs/scripts/build.bash
~~~~

Some additional things to try:
~~~~
set -v
~~~~

Have you noticed that most (all?) paths in the scripts are absolute?


## Run OpenIFS

The basic job of the run script is to

1. set up environment variables and input files in the run directory
   the way the OpenIFS executable expects to find them, and then
2. launch the executable.

When the job is run through the batch queue system, it also needs to
specify it's

3. resource requirements.

Now, there are basically two possibilities

- write the whole job script as a single batch script


