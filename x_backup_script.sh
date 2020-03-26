#!/bin/bash

source workflow_parameters.conf

## DROP BACKUP SCHEMA
psql ${dbpar2} -t -c "DROP SCHEMA IF EXISTS ${SCH}_bak CASCADE;" && echo "${SCH}_bak"
## BACKUP SCHEMA
psql ${dbpar2} -t -c "ALTER SCHEMA ${SCH} RENAME TO ${SCH}_bak;" && echo "${SCH}_bak;"
