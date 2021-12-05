run:
	gcc -g -fPIC -shared  csv.c -o csv.so
	nl -w1 -s',' input.txt > numbered.txt
	sqlite3 aoc.db < run.sql
	rm aoc.db
