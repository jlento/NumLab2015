% Batch Queues
% Juha Lento
% January 23, 2015


# Running parallel programs on a supercomputer

## Running jobs on compute nodes

![Users log in into one of the LOGIN nodes. How to make use of the
 COMPUTE NODES?](../1_Session/include/SupercomputerArchitecture.svg)

## Parallel (MPI) program launcher

- launches a program (the instance of the program, a process), or
  multiple instances of a program (SPMD), or multiple instances of
  multiple programs (MPMD), on a compute node or compute nodes
- Message Passing Interface (MPI) library provides a way for the
  program instances (MPI tasks) to communicate with each other
- common job launchers are `mpirun`, `mpiexec`, `srun`, and `aprun`.


## Batch queue system

The efficient use of the supercomputer resources is achieved using a batch
queue system, which:

1. Allocates resources
2. Integrates with the MPI job laucher

Although it may first feel like an extra step, it actually automates a
lot of work.


## Usage policy

- fair and efficient use of resources
- defines which kind of jobs are run on the machine
- implemented using batch queue system
- different queues, ~ called partitions in SLURM, for different
  kind of jobs
- queues can have different priorities
- typically small jobs, with small number of cores and short
  runtime, start sooner


## How to communicate with the batch queue system?

- through batch queue system commands, such as `sbatch` and `squeue`
  (SLURM), and batch job scripts

~~~~{#slurm-commands .bash}
sbatch job.sh
squeue
squeue -u $USER
sinfo
scontrol show partition test
scontrol show partition parallel
...
~~~~


## Job script

- prepares the environment for the program, copies input files to
  run directory, etc.
- launches the application on the compute nodes
- *Batch* job script, in addition, defines the requested resources:
  the number of cores, the amount of memory, computing time, etc.


## Batch jobs

- the default way of submitting large parallel jobs.
- the user writes a batch job script and gives it to the batch queue system
- batch queue system executes the script when the requested
  resources become available
- stdin, stdout and stderr are connected to files
- (this is how we are going to run OpenIFS today)


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


## Interactive batch jobs

- A very useful way to run small test, check that everything is set up
  properly before the large runs, etc.
- the user runs the job launcher directly (not really)
- one can think that the queue system actually makes a job script on
  the fly, and then proceeds as usual
- stdin, stdout and stderr are connected to the terminal
- (this is how we ran OpenIFS in the 1st exercise)


## What does a batch queue system *actually* do?
 
1. reads the resource requests from the batch job file
2. puts the job into a batch job queue
3. reserves the required resources when they become available
4. sets some environment variables and  executes the batch
   job script (a single sequential shell script!)
5. waits until the script finishes and releases resources


## Two ways to write a job script

1. a shell script prepares input files, writes a minimal batch job
   script, and then submits it
2. everything as a single *batch* job script


## A shell script generating a minimal batch job script

- if setting up the environment requires lot's of file copying,
  conversions, e.g. sequential I/O or other sequential steps
- if the same script is also used to start interactive jobs (with
  minimal modifications)


## Everything in a single batch job script

The script needs to be slightly clever if it should work both
interactively and through the batch queue system.

~~~~~
bash myjob.bash
sbatch myjob.bash
~~~~~


# Supercomputers are individuals

## Taito and Sisu

- the intended usage profile is different
- the basic unit of resource is a processor core in taito,
  and a compute node in sisu
- in taito the batch queue system (SLURM) and job launcher `srun`
  are tightly integrated
- in sisu the user uses batch queue system to reserve nodes, and
  then tells `aprun` how to place the processes in the nodes


# Questions?

## Further reading

- more details and examples in the [CSC Environment User
  Guide](https://research.csc.fi/csc-guide), [Taito User
  Guide](https://research.csc.fi/taito-user-guide), and in [Sisu User
  Guide](https://research.csc.fi/sisu-user-guide)

~~~~
man sbatch
man srun
...
~~~~

