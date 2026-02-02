CC=gcc
CFLAGS=-Wall -Wextra -O2 -std=c11
SRC=src/main.c src/nim.c src/ai.c src/bench.c
OUT=marienbad

all: $(OUT)

$(OUT): $(SRC)
	$(CC) $(CFLAGS) $(SRC) -o $(OUT)

clean:
	rm -f $(OUT)
