CC = gcc
CFLAGS = -std=gnu99

# Detect operating system and use correct library
UNAME := $(shell uname)
ifeq ($(UNAME), Darwin)
    LEXLIB = -ll      # macOS uses libl
else
    LEXLIB = -lfl     # Linux uses libfl
endif

scanner: lex.yy.o driver.o
	$(CC) $(CFLAGS) -o scanner lex.yy.o driver.o $(LEXLIB)

lex.yy.o: lex.yy.c
	$(CC) $(CFLAGS) -c lex.yy.c

lex.yy.c: scanner.l
	flex scanner.l    # PERSON 1: Use 'flex' explicitly

driver.o: driver.c tokendef.h
	$(CC) $(CFLAGS) -c driver.c

.PHONY: clean

clean:
	rm -f scanner lex.yy.c lex.yy.o driver.o *~