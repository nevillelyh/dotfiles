#!/bin/bash

# Always clear changes
trap "xcalib -clear" EXIT

# Fade to black in 5 seconds in 2%, 100ms increments
let c=100
while (( c > 0 )); do
  xcalib -alter -contrast $c
  sleep 0.1
  let c=c-2
done
