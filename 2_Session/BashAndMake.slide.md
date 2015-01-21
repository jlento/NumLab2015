% Bash and Make
% Juha Lento
% January 23, 2015


# Level\ 0: Bash scripts as executable notes

## A way to work

![Copying commands (the ones that actually worked) from the terminal window to a file is "a level\ 0" use case.](include/EmacsAndXterm.png)

## An example, Exercise\ 1:

~~~~
#!/bin/bash
module purge
module load intel/15.0.0 intelmpi/5.0.1 mkl/11.2.0
mkdir -p $WRKDIR/oifs
cd $WRKDIR/oifs
tar xvf ${PATH_TO_ARCHIVE}/oifs38r1v04.tar.gz
cd oifs38r1v04/make
export PATH=$PATH:$WRKDIR/oifs/oifs38r1v04/fcm/bin
export OIFS_COMP=intel_mkl
export OIFS_BUILD=opt
export OIFS_GRIB_API_DIR="/appl/climate/intel1500"
fcm make --new -v -j 4 -f oifs.cfg
cd ../t21test
# Edit fort.4
export GRIB_SAMPLES_PATH= \
  /appl/climate/intel1500/share/grib_api/ifs_samples/grib1_mlgrib2
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/appl/climate/intel1500/lib
srun -n 1 -p test -t 5 \
  $WRKDIR/oifs/oifs38r1v04/make/intel_mkl-opt/oifs/bin/master.exe -e epc8
~~~~

## The Good, the Bad, and the Ugly

- there actually is some notes! (the Good)
- script is very specific, re-do everything, non-parallel (the Bad)
- not even a mother would call this child beautiful (the Ugly)

### Do I need to make it pretty?

- depends totally on how many times, and by how many people it is used
- if you show it to someone else, yes


# Level\ 1: Readable bash scripts

## Some desing ideas

- use variables for values that you may want to change
- split the notes into "subroutines"
- put the files into the right places
- write a batch job script (the other three are quite general tips!)

Todays exercise is to put those into practice!


# Level\ 2: Clever scripts

## A cleaver script

- does not do again something that already exists and is up to date
- does not fail for no real reason, and when fails for a good reason,
  clearly indicates why
- works for the next user, too
- works in an another computer, too

All this is quite a lot to ask. Let's keep those things in mind and
try to make our scripts clever, but not in the expense of the most
important rule:

** KEEP IT SIMPLE **

 
