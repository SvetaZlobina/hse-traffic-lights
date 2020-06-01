#define CHAN_SIZE 5
#define ns_sense_nempty (len(ns_sense) != 0)
#define we_sense_nempty (len(we_sense) != 0)

bool ns_buf, we_buf;
chan ns_sense = [CHAN_SIZE] of {bool};
chan ne_sense = [CHAN_SIZE] of {bool};
chan ew_sense = [CHAN_SIZE] of {bool};
chan we_sense = [CHAN_SIZE] of {bool};
chan sw_sense = [CHAN_SIZE] of {bool};
chan p_sense = [CHAN_SIZE] of {bool};
bool ns_lock = false, ne_lock = false, ew_lock = false, we_lock = false, sw_lock = false, p_lock = false;

int critical = 0;

mtype = { red, green };
mtype ns_light = red, ne_light, ew_light, we_light = red, sw_light, p_light;

active proctype NS() {
    printf("Start NS");
    do
       :: critical == 0 -> if
                                :: len(ns_sense) > 0 -> (!sw_lock && !we_lock && !ew_lock) -> ns_lock = true; ns_light = green;
                                   printf("ns light green"); ns_sense?ns_buf; ns_light = red; ns_lock = false; printf("ns light red");

                            fi; critical = 1;
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
    :: critical == 1 -> if
         :: len(we_sense) > 0 -> (!ns_lock && !sw_lock && !p_lock) -> we_lock = true; we_light = green;
            printf("we light green"); we_sense?we_buf; we_light = red; we_lock = false; printf("we light red");
    fi; critical = 0;
    od;
}

active proctype WE_gen() {
    printf("we gen start");
    do
         :: we_sense!true; printf("we new car generated");
    od;
}

ltl s1 {[] !((ns_light == green) && (sw_light == green) && (we_light == green) && (ew_light == green))};

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