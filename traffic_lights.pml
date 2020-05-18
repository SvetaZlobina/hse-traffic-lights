bool ns_req = false, ne_req = false, ew_req = false, we_req = false, sw_req = false, p_req = false;
bool ns_sense = false, ne_sense = false, ew_sense = false, we_sense = false, sw_sense = false, p_sense = false;
bool ns_lock, ne_lock, ew_lock, we_lock, sw_lock, p_lock;

mtype = { red, green };
mtype ns_light, ne_light, ew_light, we_light, sw_light, p_light;

active proctype NS() {
    printf("ns");
    do
        :: if
                :: ns_req -> (!sw_lock && !we_lock && !ew_lock) -> ns_lock = true; ns_light = green;
                   !ns_sense -> ns_lock = false; ns_light = red; ns_req = false;
           fi;
    od;

}

active proctype EW() {
    printf("ew");
}

active proctype WE() {
    printf("we");
}

active proctype SW() {
    printf("sw");
}

active proctype NE() {
    printf("ne");
}

active proctype pedestrians() {
    printf("p");
}

active proctype ns_gen() {

}