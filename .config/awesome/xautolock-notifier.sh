#!/bin/bash

# Always clear changes
trap "xcalib -clear" EXIT

# Fade to black in 5 seconds in 2%, 100ms increments
for (( i = 1; i <= 50; i++ )); do
  let contrast=100-$i*2
  echo $contrast
  xcalib -alter -contrast $contrast
  sleep 0.1
done
