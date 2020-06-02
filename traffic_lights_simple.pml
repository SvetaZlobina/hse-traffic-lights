#define CHAN_SIZE 1
#define TRAFFIC_LIGHTS_NUM 6
#define ns_sense_nempty (len(ns_sense) != 0)
#define we_sense_nempty (len(we_sense) != 0)
#define ew_sense_nempty (len(ew_sense) != 0)
#define ne_sense_nempty (len(ne_sense) != 0)
#define sw_sense_nempty (len(sw_sense) != 0)
#define p_sense_nempty (len(p_sense) != 0)

bool ns_buf, we_buf, ew_buf, ne_buf, sw_buf, p_buf;
chan ns_sense = [CHAN_SIZE] of {bool};
chan ne_sense = [CHAN_SIZE] of {bool};
chan ew_sense = [CHAN_SIZE] of {bool};
chan we_sense = [CHAN_SIZE] of {bool};
chan sw_sense = [CHAN_SIZE] of {bool};
chan p_sense = [CHAN_SIZE] of {bool};

chan lock1 = [1] of {bool};
chan lock2 = [1] of {bool};
chan lock3 = [1] of {bool};
chan lock4 = [1] of {bool};
chan lock5 = [1] of {bool};
chan lock6 = [1] of {bool};
chan lock7 = [1] of {bool};
chan lock8 = [1] of {bool};
chan main_lock = [1] of {bool};

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
    int process_num = 0;
    do
       :: if
             :: len(ns_sense) > 0 && !fair_array[process_num] -> main_lock?ns_buf; lock1?ns_buf; lock3?ns_buf; lock4?ns_buf; main_lock!true; ns_light = green;
                printf("ns light green"); ns_sense?ns_buf; ns_light = red; lock1!true; lock3!true; lock4!true; printf("ns light red");

          fi; fair_check(process_num);
    od;
}

active proctype NS_gen() {
    main_lock!true;
    lock1!true;
    lock2!true;
    lock3!true;
    lock4!true;
    lock5!true;
    lock6!true;
    lock7!true;
    lock8!true;
    printf("ns gen start");
    do
         :: ns_sense!true; printf("ns new car generated");
    od;
}

active proctype WE() {
    int process_num = 1;
    do
    :: if
         :: len(we_sense) > 0 && !fair_array[process_num] -> main_lock?we_buf; lock4?we_buf; lock5?we_buf; lock8?we_buf; main_lock!true; we_light = green;
            printf("we light green"); we_sense?we_buf; we_light = red; lock4!true; lock5!true; lock8!true; printf("we light red");
    fi; fair_check(process_num);
    od;
}

active proctype WE_gen() {
    printf("we gen start");
    do
         :: we_sense!true; printf("we new car generated");
    od;
}

active proctype SW() {
    int process_num = 2;
    do
    :: if
         :: len(sw_sense) > 0 && !fair_array[process_num] -> main_lock?sw_buf; lock3?sw_buf; lock5?sw_buf; main_lock!true; sw_light = green;
            printf("sw light green"); sw_sense?sw_buf; sw_light = red; lock3!true; lock5!true; printf("sw light red");
    fi; fair_check(process_num);
    od;
}

active proctype SW_gen() {
    printf("sw gen start");
    do
         :: sw_sense!true; printf("sw new car generated");
    od;
}

active proctype EW() {
    int process_num = 3;
    do
    :: if
         :: len(ew_sense) > 0 && !fair_array[process_num] -> main_lock?ew_buf; lock1?ew_buf; lock2?ew_buf; lock6?ew_buf; main_lock!true; ew_light = green;
            printf("ew light green"); ew_sense?ew_buf; ew_light = red; lock1!true; lock2!true; lock6!true; printf("ew light red");
    fi; fair_check(process_num);
    od;
}

active proctype EW_gen() {
    printf("ew gen start");
    do
         :: ew_sense!true; printf("ew new car generated");
    od;
}

active proctype NE() {
    int process_num = 4;
    do
    :: if
         :: len(ne_sense) > 0 && !fair_array[process_num] -> main_lock?ne_buf; lock2?ne_buf; lock7?ne_buf; main_lock!true; ne_light = green;
            printf("ne light green"); ne_sense?ne_buf; ne_light = red; lock2!true; lock7!true; printf("ne light red");
    fi; fair_check(process_num);
    od;
}

active proctype NE_gen() {
    printf("ne gen start");
    do
         :: ne_sense!true; printf("ne new car generated");
    od;
}

active proctype P() {
    int process_num = 5;
    do
    :: if
         :: len(p_sense) > 0 && !fair_array[process_num] -> main_lock?p_buf; lock6?p_buf; lock7?p_buf; lock8?p_buf; main_lock!true; p_light = green;
            printf("p light green"); p_sense?p_buf; p_light = red; lock6!true; lock7!true; lock8!true; printf("p light red");
    fi; fair_check(process_num);
    od;
}

active proctype P_gen() {
    printf("p gen start");
    do
         :: p_sense!true; printf("p new car generated");
    od;
}


ltl s1 {[] !((ns_light == green) && ((sw_light == green) || (we_light == green) || (ew_light == green)))};

ltl s2 {[] !((we_light == green) && ((ns_light == green) || (sw_light == green) || (p_light == green)))};

ltl s3 {[] !((ew_light == green) && ((ns_light == green) || (ne_light == green) || (p_light == green)))};

ltl s4 {[] !((ne_light == green) && ((ew_light == green) || (p_light == green)))};

ltl s5 {[] !((sw_light == green) && ((we_light == green) || (ns_light == green)))};

ltl s6 {[] !((p_light == green) && ((ne_light == green) || (ew_light == green) || (we_light == green)))};

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
            ([]<> !((sw_light == green) && sw_sense_nempty))
        ) -> (
            ([] ((sw_sense_nempty && (sw_light == red)) -> (<> (sw_light == green))))
        )};

ltl l4 {(
            ([]<> !((ew_light == green) && ew_sense_nempty))
        ) -> (
            ([] ((ew_sense_nempty && (ew_light == red)) -> (<> (ew_light == green))))
        )};

ltl l5 {(
            ([]<> !((ne_light == green) && ne_sense_nempty))
        ) -> (
            ([] ((ne_sense_nempty && (ne_light == red)) -> (<> (ne_light == green))))
        )};

ltl l6 {(
            ([]<> !((p_light == green) && p_sense_nempty))
        ) -> (
            ([] ((p_sense_nempty && (p_light == red)) -> (<> (p_light == green))))
        )};