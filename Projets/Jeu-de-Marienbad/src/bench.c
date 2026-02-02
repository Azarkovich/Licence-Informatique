#define _POSIX_C_SOURCE 199309L

#include "bench.h"
#include "ai.h"
#include <stdio.h>
#include <time.h>

double now_ms(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (double)ts.tv_sec * 1000.0 + (double)ts.tv_nsec / 1e6;
}

void bench_once(const State *s, int depth) {
    Stats st1, st2;

    double t1 = now_ms();
    Move m1 = ai_best_move(s, depth, false, &st1); // minimax
    double t2 = now_ms();

    double t3 = now_ms();
    Move m2 = ai_best_move(s, depth, true, &st2); // alpha-beta
    double t4 = now_ms();

    printf("Etat: ");
    state_print(s);
    printf("Depth=%d\n", depth);

    printf("Minimax   : move=(tas %d, -%d)  nodes=%llu  time=%.3f ms\n",
           m1.heap, m1.remove, (unsigned long long)st1.nodes, (t2 - t1));

    printf("AlphaBeta : move=(tas %d, -%d)  nodes=%llu  time=%.3f ms\n",
           m2.heap, m2.remove, (unsigned long long)st2.nodes, (t4 - t3));
}

static void state_to_string(const State *s, char *buf, int buflen) {
    int off = 0;
    for (int i = 0; i < s->n; i++) {
        int w = snprintf(buf + off, (off < buflen ? buflen - off : 0),
                         "%s%d", (i == 0 ? "" : "-"), s->heaps[i]);
        if (w < 0) break;
        off += w;
        if (off >= buflen) break;
    }
}

static int run_avg(const State *s, int depth, int reps, int use_ab,
                   double *avg_ms, unsigned long long *avg_nodes,
                   Move *chosen_move) {
    unsigned long long sum_nodes = 0;
    double sum_ms = 0.0;

    Move last = (Move){-1, 0};

    for (int i = 0; i < reps; i++) {
        Stats st;
        double t1 = now_ms();
        Move m = ai_best_move(s, depth, use_ab ? true : false, &st);
        double t2 = now_ms();
        sum_ms += (t2 - t1);
        sum_nodes += (unsigned long long)st.nodes;
        last = m;
    }

    *avg_ms = sum_ms / (double)reps;
    *avg_nodes = (unsigned long long)((double)sum_nodes / (double)reps);
    *chosen_move = last;
    return 0;
}

int bench_to_csv(const char *filename, const State *s, int reps, int depth_min, int depth_max) {
    FILE *f = fopen(filename, "w");
    if (!f) {
        perror("fopen");
        return 1;
    }

    char pos[128];
    state_to_string(s, pos, (int)sizeof(pos));

    fprintf(f, "position,heaps,depth,algo,reps,avg_nodes,avg_time_ms,move_heap,move_remove\n");

    for (int d = depth_min; d <= depth_max; d++) {
        // Minimax
        double mm_ms;
        unsigned long long mm_nodes;
        Move mm_move;
        run_avg(s, d, reps, 0, &mm_ms, &mm_nodes, &mm_move);

        fprintf(f, "%s,%d,%d,%s,%d,%llu,%.6f,%d,%d\n",
                pos, s->n, d, "minimax", reps,
                mm_nodes, mm_ms, mm_move.heap, mm_move.remove);

        // AlphaBeta
        double ab_ms;
        unsigned long long ab_nodes;
        Move ab_move;
        run_avg(s, d, reps, 1, &ab_ms, &ab_nodes, &ab_move);

        fprintf(f, "%s,%d,%d,%s,%d,%llu,%.6f,%d,%d\n",
                pos, s->n, d, "alphabeta", reps,
                ab_nodes, ab_ms, ab_move.heap, ab_move.remove);
    }

    fclose(f);
    return 0;
}
