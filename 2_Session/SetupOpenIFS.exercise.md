**LABORATORY COURSE IN NUMERICAL METEOROLOGY**  
**Exercise 2, Fri Jan 23 14:15-16:00 2015, D210**


## Setup OpenIFS

Let's develop the steps that we made in the exercise\ 1 a bit further.


## Put the files into the right places

Let's make directories for the OpenIFS source, OpenIFS executable and
the scripts that we will write:

~~~~{#make-dirs .bash}
mkdir -p ${HOME}/oifs/src
mkdir -p ${USERAPPL}/oifs/bin
mkdir -p ${USERAPPL}/oifs/scripts
~~~~~~~~~~~~~~~~~~~~~

We put also the scripts under `${USERAPPL}` because they will only
work in taito, but not in sisu. If we were planning to write more
general scripts that would work in both machines, they would be better
placed under `${HOME}`.

Some commands to try, too:

~~~~{#file-commands .bash}
readlink -f ${USERAPPL}
mount
~~~~~~~~~~~~~~~~~~~~~~~~


## Split the "notes" into "subroutines"

There are two tasks that we wish to do

- build OpenIFS from source 
- run OpenIFS

We do not need to build OpenIFS every time we wish to run it, so it is
clearly a good idea to separate the tasks into respective scripts.  In
addition, it is easiest if both tasks are executed in the same
environment. Thus, we will make three scripts,

1. `env.bash` for setting up the environment
2. `build.bash` for building OpenIFS
3. `t21test.bash` for running T21 resolution test case


## Environment setup

Module system takes care of most of the basic environment setup. In
addition, we set the environment variables `GRIB_SAMPLES_PATH` and
`LD_LIBRARY_PATH`, which are specific to our OpenIFS environment in
taito.

File `env.bash`:

~~~~{#env-script .bash }
#!/bin/bash                                                                     
module purge
module load intel/15.0.0 intelmpi/5.0.1 mkl/11.2.0
export GRIB_SAMPLES_PATH=/appl/climate/intel1500/share/grib_api/ifs_samples/grib1_mlgrib2
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/appl/climate/intel1500/lib
~~~~~~~~~~~~~~~~~~~~~~~~~~~

There is some advice in the internet to use bash shell
initialization files `~/.bashrc` and `~/.profile` for setting up the
environment for applications. That is a bad idea. Do not touch
`~/.bashrc` and `~/.profile` files.


## Build OpenIFS

First, copy the OpenIFS source tar-ball `oifs38r1v04.tar.gz` to the
right place, your source directory `${HOME}/oifs/src`. Then write file
`build.bash`:

~~~~{#build-oifs .bash}
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
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Exercise\ 1:** Add comments to the script that explain what each
line does.

Comment lines begin with character "#" (don't touch the first
line). First try to get a general idea. Don't get stuck if some line
is more difficult, just take the next line and come back to the
difficult line later.

BTW, the command to execute the script is:

~~~~{#execute-build .bash}
bash ${USERAPPL}/oifs/scripts/build.bash
~~~~~~~~~~~~~~~~~~~~~~~~~~

Some additional things to try:

~~~~{#additional-script-lines .bash}
set -v
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Have you noticed that most (all?) paths in the scripts are absolute?


## One job script, two approaches

The job script should

- set up environment variables and input files in the run directory
   the way the OpenIFS executable expects to find them, and then
- launch the executable.

When the job is run through the batch queue system, it also needs to
specify it's

- resource requirements.

In the lecture Batch Queues we discussed two approaches

1. a shell script prepares the run dir, writes a
   minimal batch job script and submits it
2. everything is done inside a single batch job script


## A shell script

Below is a "level\ 1" shell script that prepares the run directory,
writes a minimal batch job script, and submits it. All input file
preparations etc. are done immediately, on the login node.

File `t21test.bash`:

~~~~{#t21test-v1 .bash}
#!/bin/bash                                                                    

nproc=4
exe=${USERAPPL}/oifs/bin/master.exe
rundir=${WRKDIR}
tarball=${HOME}/oifs/src/oifs38r1v04.tar.gz
jobfile=job.bash

rm -rf ${rundir}/t21test
cd ${rundir}
tar --strip-components=1 -xf ${tarball}
cd t21test

sed -r "s/(^ *NPROC *= *).*/\1${nproc},/" namelists > fort.4

expid=$(ls ICMGG????INIT | sed -r 's/.*ICMGG(.{4})INIT/\1/')

cat > $jobfile <<EOF                                                           
#!/bin/bash                                                                    
#SBATCH -n $nproc                                                              
#SBATCH -t 5                                                                   
#SBATCH -p test                                                                
#SBATCH --mem-per-cpu=7000                                                     
source ${USERAPPL}/oifs/scripts/env.bash
srun $exe -e $expid                                                            
EOF                                                                            

sbatch $jobfile
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Again, you run the script with

~~~~{#run-t21test-v1 .bash}
bash ${USERAPPL}/oifs/scripts/t21test.bash
~~~~~~~~~~~~~~~~~~~~~~~~~

**Exercise\ 2:** Add comments to the script that explain what each
line does. Pay special attention to places where the script tries to
be semi-clever.


## A batch job script

A batch job script is executed only after the batch queue system has
found a suitable slot for it to run, and has reserved the required
resources for the job. BTW, in which node the batch job script is
executed?

**Exercise\ 3:** Write the above shell script as a single batch job
script, called `t21test.jobscript.bash`, for example. That is, put
everything from the above `t21test.bash` inside the `$jobfile`,
basically.Thus, the script should start with

~~~~{#t21test-v2-beginning .bash}
#!/bin/bash                                                                    
#SBATCH ...
~~~~~~~~~~~~~~~~~~~~~~~~~~

There should be no `sbatch` command in it (only `srun ...` at the
end), since the whole single job script should be given to batch queue
system execute, with the command:

~~~~{#run-t21test-v2-beginning .bash}
sbatch ${USERAPPL}/oifs/scripts/t21test.jobscript.bash
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The only difficult detail to figure out here (hopefully) is how to set
the number of processors to use (`nproc` variable in `t21test.bash`)
*only in one place*. **HINT:** See CSC Environment/Taito User guides
and `man sbatch`. Look for which variables `sbatch` command sets in
the environment that it executes the batch job script.

**Extra exercise:** OpenIFS test case directory `t21test` contains a
  file `job`. Have a look.


## Post-processing OpenIFS output

The next lecture is about post-processing and visualization of OpenIFS
output files. There is an example makefile, `oifs2nc.mk` and an
accompanying wrapper script `oifs2nc` in taito's directory
`/appl/climate/oifs/numlab/`, which can be used to convert (some)
OpenIFS output files to more easily digestiable NetCDF format.

You can try to run the conversion script on your OpenIFS outputs in the t21test directory, with

~~~~{#test-oifs2nc .bash}
/appl/climate/oifs/numlab/oifs2nc ICMGGepc8+000000
~~~~~~~~~~~~~~~~~~~~~~~~

**Exercise\ 4:** Get familiar with the script and makefile, figure out
  how they work, and add comments, so you can later in this course use
  and modify them.
