#define CHAN_SIZE 1
#define TRAFFIC_LIGHTS_NUM 3
#define ns_sense_nempty (len(ns_sense) != 0)
#define we_sense_nempty (len(we_sense) != 0)
#define ew_sense_nempty (len(ew_sense) != 0)

bool ns_buf, we_buf, ew_buf;
chan ns_sense = [CHAN_SIZE] of {bool};
chan ne_sense = [CHAN_SIZE] of {bool};
chan ew_sense = [CHAN_SIZE] of {bool};
chan we_sense = [CHAN_SIZE] of {bool};
chan sw_sense = [CHAN_SIZE] of {bool};
chan p_sense = [CHAN_SIZE] of {bool};
bool ns_lock = false, ne_lock = false, ew_lock = false, we_lock = false, sw_lock = false, p_lock = false;

bool fair_array[TRAFFIC_LIGHTS_NUM];


mtype = { red, green };
mtype ns_light = red, ne_light, ew_light, we_light = red, sw_light, p_light;

inline fair_check(pointer) {
    printf("pointer = %d", pointer);
    fair_array[pointer] = true;
    bool result = true;
    int i;
    for (i : 0 .. (TRAFFIC_LIGHTS_NUM - 1)) {
        if
            :: fair_array[i] == false -> printf("elem=%d", i); result = false;
            :: else -> skip;
        fi;
    };
    printf("result = %d", result);
    if
        :: result == true ->
            for (i : 0 .. (TRAFFIC_LIGHTS_NUM - 1)) {
                fair_array[i] = false;
        };
        :: else -> skip;
    fi;
}

active proctype NS() {
    printf("Start NS");
    do
       :: if
             :: len(ns_sense) > 0 && !fair_array[0] -> (!sw_lock && !we_lock && !ew_lock) -> ns_lock = true; ns_light = green;
                printf("ns light green"); ns_sense?ns_buf; ns_light = red; ns_lock = false; printf("ns light red");

          fi; fair_check(0);
    od;
}

active proctype NS_gen() {
    printf("ns gen start");
    do
         :: ns_sense!true; printf("ns new car generated");
    od;
}

active proctype WE() {
    do
    :: if
         :: len(we_sense) > 0 && !fair_array[1] -> (!ns_lock && !sw_lock && !p_lock) -> we_lock = true; we_light = green;
            printf("we light green"); we_sense?we_buf; we_light = red; we_lock = false; printf("we light red");
    fi; fair_check(1);
    od;
}

active proctype _gen() {
    printf("we gen start");
    do
         :: we_sense!true; printf("we new car generated");
    od;
}

active proctype EW() {
    printf("Start EW");
    int process_num = 2;
    do
       :: if
             :: len(ew_sense) > 0 && !fair_array[process_num] -> (!ns_lock && !ne_lock && !p_lock) -> ew_lock = true; ew_light = green;
                printf("ew light green"); ew_sense?ew_buf; ew_light = red; ew_lock = false; printf("ew light red");

          fi; fair_check(process_num);
    od;
}

active proctype EW_gen() {
    printf("ew gen start");
    do
         :: ew_sense!true; printf("ew new car generated");
    od;
}


ltl s1 {[] !((ns_light == green) && (sw_light == green) && (we_light == green) && (ew_light == green))};

ltl s2 {[] !((we_light == green) && (ns_light == green) && (sw_light == green) && (p_light == green))};

ltl s3 {[] !((ew_light == green) && (ns_light == green) && (ne_light == green) && (p_light == green))};

ltl l1 {(
            ([]<> !((ns_light == green) && ns_sense_nempty))
        ) -> (
            ([] ((ns_sense_nempty && (ns_light == red)) -> (<> (ns_light == green))))
        )};

ltl l2 {(
            ([]<> !((we_light == green) && we_sense_nempty))
        ) -> (
            ([] ((we_sense_nempty && (we_light == red)) -> (<> (we_light == green))))
        )};

ltl l3 {(
            ([]<> !((ew_light == green) && ew_sense_nempty))
        ) -> (
            ([] ((ew_sense_nempty && (ew_light == red)) -> (<> (ew_light == green))))
        )};