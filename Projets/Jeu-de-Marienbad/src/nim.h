#ifndef NIM_H
#define NIM_H

#include <stdbool.h>

#define MAX_HEAPS 8

typedef struct {
    int heaps[MAX_HEAPS];
    int n;              
} State;

typedef struct {
    int heap;           
    int remove;         
} Move;

void state_init(State *s, const int *heaps, int n);
void state_print(const State *s);

bool state_is_terminal(const State *s);     
int  state_total(const State *s);           
bool move_is_legal(const State *s, Move m);
void apply_move(State *s, Move m);

int  generate_moves(const State *s, Move *out_moves, int max_out);

#endif
