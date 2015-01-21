% Batch Queues
% Juha Lento
% January 23, 2015


# Running parallel programs on a supercomputer

## Running jobs on compute nodes

![Users log in into one of the LOGIN nodes. How to make use of the
 COMPUTE NODES?](include/SupercomputerArchitecture.svg)

## Message Passing Interface (MPI)

- MPI library provides a way for processes (MPI tasks) to
  send messages to each other
- MPI tasks may be all on the same node or on different nodes
- the tasks are launched on compute nodes with a job launcher. Common
  ones are `mpirun`, `mpiexec`, `srun` and `aprun`.


## Batch queue system

The efficient use of supercomputer resources is achieved using a batch
queue system, which:

1. Allocates resources
2. Integrates with the MPI job laucher

Although it may first feel like an extra step, it actually automates a
lot of work.


## How to communicate with the batch queue system?

- through batch queue system commands, such as `sbatch` and `squeue`,
  and batch job scripts

~~~~
> sbatch job.sh
> squeue -u $USER
~~~~


## Batch job script

Job script 

- prepares the environment for the program
- launches the application on the compute nodes

*Batch* job script, in addition,

- defines the requested resources, the number of cores, the amount of
  memory, computing time, etc.


## Batch jobs

The default way of submitting large parallel jobs.

- the user writes a batch job script and gives it to the batch queue system
- batch queue system executes the script when the requested
  resources become available
- stdin, stdout and stderr are connected to files

This is how we are going to run OpenIFS today.


## Interactive batch jobs

A very useful way to run small test, check that everything is set up
properly before the large runs, etc.

- the user runs the job launcher directly (not really), and waits
  for the execution to start
- one can think that the queue system actually makes a job script on
  the fly, and then proceeds as usual
- stdin, stdout and stderr are connected to terminal

This is how we run OpenIFS in the 1.\ exercise.


## Example batch job script

~~~~
#!/bin/bash
#SBATCH -n 4
#SBATCH -t 5
#SBATCH -p test
export CURDIR=${SLURM_SUBMIT_DIR}
export EXE=/path/to/myexe
srun ${EXE}
~~~~

## What does a batch queue system actually do?
 
1. reads the resource requests from the batch job file
2. puts the job into a batch job queue
3. reserves the required resources when they become available
4. sets some environment variables and  executes the batch
   job script (a single sequential shell script!)
5. waits until the script finishes and releases resources


## Two ways to write a job script

1. everything in a single batch job script
2. shell script prepares input files, writes a minimal batch job
   script, and then submits it


## Everything in a single batch job script

The script needs to be slightly clever if it should work both
interactively `bash myjob.bash` and through batch queue system `sbatch
myjob.bash`.


## A shell script and a minimal batch job script

### When, and when not, to use

- if setting up the environment requires lot's of file copying,
  conversions, e.g. sequential I/O or other sequential steps
- if the same script is also used to start interactive jobs
