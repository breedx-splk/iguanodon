#!/bin/bash

echo quick test here

echo here is the github workspace dir
ls -l /github/workspace/

echo making a file in the workspace
echo TEST123 > /github/workspace/results/FLIMFLAM
echo $?
echo lets check to see if it worked
echo ls -l /github/workspace/results/
ls -l /github/workspace/results/