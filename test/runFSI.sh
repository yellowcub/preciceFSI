#!/bin/bash

# Print executed commands
set -e

base_dir=$(pwd)

# Group solvers to stop all if one fails
set -m
(
 # Launch openFOAM solver
 cd $base_dir/fluid-openfoam
 ./run.sh "$@" &> ../fluid.log &
 
 # Launch CalculiX solver
 cd $base_dir/solid-calculix
 ./run.sh &> ../solid.log &
 
 # Launch solver C
#  cd /path/to/solver/c
# ./runSolver  &> c.log &
 
 # Wait for every solver to finish
  wait
)
