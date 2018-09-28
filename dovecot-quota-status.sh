#!/bin/bash
doveadm -f table quota get -A | tail -n +1| sort -n -k 7
