#!/bin/bash

# Always clear changes
trap "xcalib -clear" EXIT

# Fade to black in 5 seconds in 2%, 100ms increments
(( c = 100 ))
while (( c > 0 )); do
  xcalib -alter -contrast $c
  sleep 0.1
  (( c = c - 2 ))
done

# Extra sleep to remove flicker
sleep 1
