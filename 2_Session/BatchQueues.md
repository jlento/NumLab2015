% Batch Queues
% Juha Lento
% January 23, 2015


# Running parallel programs on a supercomputer

## Running jobs on compute nodes

![Users log in into one of the LOGIN nodes. How to launch parallel
 programs on the COMPUTE NODES?](include/SupercomputerArchitecture.svg)

## Batch queue system

The efficient use of supercomputer resources is achieved using a batch
queue system, which:

1. Allocates resources
2. Integrates with MPI job laucher

## MPI parallel program launcher

Parallel MPI programs are launched with a job launcher that comes with
the MPI library. Common MPI job launcher names are `mpirun`,
`mpiexec`, `srun` and `aprun`.

Job launcher needs to know exactly how to place the MPI tasks (=processes)
of the paralle program on the compute nodes.