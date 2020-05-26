SCRIPTS USED

IS NOT POSSIBLE TO AUTOMATE THE IMPORT SCRIPTS: OBJECTS NAMES AND STRUCTURE CHANGE OFTEN

They are contained in "species" folder.

IMPORT=
time ./01_species_input_gosling.sh

Only on CORALS it takes:

DOPAPRC
real    6m15.995s
user    3m54.400s
sys     0m8.668s
 
GOSLING
real    16m0.203s !!!!
user    13m2.376s
sys     0m17.709s



time ./01_species_input_gosling_chondichthyes.sh > logs/01_species_input_gosling_chondichthyes.log 2>&1 &
time ./01_species_input_gosling_amphibians.sh > logs/01_species_input_gosling_amphibians.log 2>&1 &
time ./01_species_input_gosling_mammals.sh > logs/01_species_input_gosling_mammals.log 2>&1 &



docker@gosling:/globes/processing_current/species$ ./01_species_input_all.sh

real    3m0.454s
user    0m39.884s
sys     0m5.100s

real    9m51.122s
user    6m44.352s
sys     0m11.201s

real    11m44.956s
user    9m28.423s
sys     0m7.390s

real    17m14.833s
user    12m55.339s
sys     0m20.529s
fatto!

docker@gosling:/globes/processing_current/species$ ./01_species_input_birds.sh

real    875m32.906s
user    871m26.806s
sys     0m44.747s
fatto!
