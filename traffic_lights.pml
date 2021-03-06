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
chan ns_working = [1] of {bool};
chan we_working = [1] of {bool};

mtype = { red, green };
mtype ns_light = red, ne_light, ew_light, we_light = red, sw_light, p_light;

proctype NS() {
    if
         :: len(ns_sense) > 0 -> (!sw_lock && !we_lock && !ew_lock) -> ns_lock = true; ns_light = green;
            printf("ns light green"); ns_sense?ns_buf; ns_light = red; ns_lock = false; printf("ns light red");
    fi;
    ns_working!false;
    printf("stop NS");
}

active proctype NS_gen() {
    printf("ns gen start");
    do
         :: ns_sense!true; printf("ns new car generated");
    od;
}

proctype WE() {
    if
         :: len(we_sense) > 0 -> (!ns_lock && !sw_lock && !p_lock) -> we_lock = true; we_light = green;
            printf("we light green"); we_sense?we_buf; we_light = red; we_lock = false; printf("we light red");
    fi;
    we_working!false;
    printf("stop WE");
}

active proctype WE_gen() {
    printf("we gen start");
    do
         :: we_sense!true; printf("we new car generated");
    od;
}

active proctype main() {
    bool buf_ns = false;
    bool buf_we = false;
    ns_working!true; we_working!true;
    do
        :: if
                :: nempty(ns_working) -> ns_working?buf_ns; printf("start NS"); run NS();
           fi;
           if
                :: nempty(we_working) -> we_working?buf_we -> printf("start WE"); run WE();
           fi;
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