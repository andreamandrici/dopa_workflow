#!/bin/bash

source workflow_parameters.conf


psql ${dbpar2} -t -c -f some_code.sql
