# hse-traffic-lights
Homework for course "Formal methods in software development" - traffic lights simulator in promela

spin -a traffic_lights_simple.pml
gcc -O2 -DBITSTATE -o pan pan.c
./pan -a -m100000000 -N s1
spin -t traffic_lights_simple.pml