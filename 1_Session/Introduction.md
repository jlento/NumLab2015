**LABORATORY COURSE IN NUMERICAL METEOROLOGY**  
**Introduction to computational tools, Wed Jan 16 14:00-16:00 2014, D200**


## Introduction to computational tools

Laboratory course in numerical meteorology 2015 includes short
introductionary lecturettes on using (super)computers and scientific
software. Using scientific software in supercomputers as a "black box"
machine is not really possible, in general. In order to effectively
use scientific software on supercomputers one needs to be somewhat
familiar with the underlying software and hardware architectures. The
goal of the lecturettes is to make the black box more transparent.

The main differences between using a local workstation or a
laptop compared to using a supercomputer can be summarized in two
questions:

1. Where to put the all the different kind of files?
2. How to run the programs?

The third, a more general question which we approach is:

3. What happens after pressing Enter?

As simple as these questions may seem, the answers to them are not
necessarily simple.

As an example to the third question, "What happens after pressing
Enter?", let's see the following example, in which we give the
following command to bash shell command line interpreter:

~~~~
> ls $HOME
~~~~

The basic level of descibing what the above `ls` command does, is to
say that it shows the files in the user's home directory. The level on
which we should think is roughly that the bash shell

- reads the input line and breaks it into different components
- expands the variables, file names, etc. Here specifically,
  interprets the word `$HOME` as an (environment) variable and
  replaces the variable by it's value
- interprets the first word `ls` as a command, and the rest of the line
  as the arguments to the command
- searches the command `ls` from the directories specified in the
  environment variable `PATH` (because `ls` is not a bash builtin command)
- executes the `ls` command with the arguments given, and puts the output
  from the command to the standard output (stdout)

This level of thinking will make understanding bash scripts, how they
work, and why they sometimes do not work, much easier.

Besides bash scripts, we hope to cover an another useful tool, make,
in more detail. Make is used extensively in building programs from
sources, but it is also a very useful general tool for generating
workflows.
