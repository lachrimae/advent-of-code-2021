run:
	gcc -g -fPIC -shared  csv.c -o csv.so
	echo 'time,depth' > numbered.txt
	nl -w1 -s',' input.txt >> numbered.txt
	sqlite3 aoc.db < run.sql
	rm aoc.db
