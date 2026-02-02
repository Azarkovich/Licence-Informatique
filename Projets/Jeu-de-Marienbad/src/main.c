#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#include "nim.h"
#include "ai.h"
#include "bench.h"

static void usage(const char *prog) {
    printf("Usage:\n");
    printf("  %s play <depth> <algo> <h1> <h2> ...\n", prog);
    printf("     algo: mm (minimax) | ab (alpha-beta)\n");
    printf("     exemple: %s play 6 ab 3 4 5\n", prog);
    printf("\n");
    printf("  %s bench <depth> <h1> <h2> ...\n", prog);
    printf("     exemple: %s bench 8 3 4 5\n", prog);
    printf("\n");
    printf("  %s benchcsv <csvfile> <reps> <depth_min> <depth_max> <h1> <h2> ...\n", prog);
    printf("     exemple: %s benchcsv results.csv 30 2 10 3 4 5\n", prog);

}

static bool parse_heaps(int argc, char **argv, int start, State *s) {
    int n = argc - start;
    if (n <= 0 || n > MAX_HEAPS) return false;

    int heaps[MAX_HEAPS];
    for (int i = 0; i < n; i++) {
        heaps[i] = atoi(argv[start + i]);
        if (heaps[i] < 0) return false;
    }
    state_init(s, heaps, n);
    return true;
}

static void play_game(State s, int depth, bool use_ab) {
    printf("=== Marienbad (Nim) ===\n");
    printf("Regle: a ton tour tu retires 1..k allumettes d'un tas. Si tu ne peux pas jouer, tu PERDS.\n\n");

    // MAX = IA, MIN = humain (par choix)
    bool max_to_play = false; 
    while (!state_is_terminal(&s)) {
        state_print(&s);

        if (!max_to_play) {
            // tour humain
            printf("Ton coup (format: tas remove) > ");
            int heap, rem;
            if (scanf("%d %d", &heap, &rem) != 2) {
                printf("Entree invalide.\n");
                // purge stdin
                int c; while ((c = getchar()) != '\n' && c != EOF) {}
                continue;
            }
            Move m = {heap, rem};
            if (!move_is_legal(&s, m)) {
                printf("Coup illegal.\n");
                continue;
            }
            apply_move(&s, m);
        } else {
            // tour IA
            Stats st;
            Move best = ai_best_move(&s, depth, use_ab, &st);
            printf("IA joue: tas %d, retire %d (nodes=%llu)\n",
                   best.heap, best.remove, (unsigned long long)st.nodes);
            apply_move(&s, best);
        }

        max_to_play = !max_to_play;
        printf("\n");
    }

    // état terminal atteint : le joueur dont c'est le tour perd
    if (max_to_play) {
        printf("IA ne peut plus jouer => IA PERD. Tu GAGNES.\n");
    } else {
        printf("Tu ne peux plus jouer => tu PERDS. IA GAGNE.\n");
    }
}

int main(int argc, char **argv) {
    if (argc < 2) {
        usage(argv[0]);
        return 1;
    }

    if (strcmp(argv[1], "benchcsv") == 0) {
        if (argc < 8) { usage(argv[0]); return 1; }

        const char *csvfile = argv[2];
        int reps = atoi(argv[3]);
        int depth_min = atoi(argv[4]);
        int depth_max = atoi(argv[5]);

        if (reps <= 0 || depth_min <= 0 || depth_max < depth_min) {
            printf("Parametres invalides (reps>0, depth_min>0, depth_max>=depth_min)\n");
            return 1;
        }

        State s;
        if (!parse_heaps(argc, argv, 6, &s)) {
            printf("Heaps invalides.\n");
            return 1;
        }

        int err = bench_to_csv(csvfile, &s, reps, depth_min, depth_max);
        if (err == 0) {
            printf("CSV ecrit dans: %s\n", csvfile);
        }
        return err;
    }

    if (strcmp(argv[1], "play") == 0) {
        if (argc < 6) { usage(argv[0]); return 1; }
        int depth = atoi(argv[2]);
        bool use_ab = (strcmp(argv[3], "ab") == 0);

        State s;
        if (!parse_heaps(argc, argv, 4, &s)) {
            printf("Heaps invalides.\n");
            return 1;
        }
        play_game(s, depth, use_ab);
        return 0;
    }

    if (strcmp(argv[1], "bench") == 0) {
        if (argc < 5) { usage(argv[0]); return 1; }
        int depth = atoi(argv[2]);

        State s;
        if (!parse_heaps(argc, argv, 3, &s)) {
            printf("Heaps invalides.\n");
            return 1;
        }
        bench_once(&s, depth);
        return 0;
    }

    usage(argv[0]);
    return 1;
}
