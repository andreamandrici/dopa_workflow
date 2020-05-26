#!/bin/bash
git add .
wait
git commit -am "updated on `date +%Y%m%d` at `date +%H:%M:%S`"
wait
git push
