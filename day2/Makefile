part1:
	tac input.txt > input.txt.rev
	echo "struct Position terminal = EVAL(EXECUTE(" > input.h
	sed 's/\(\w\|\d\)\(\s\|$$\)/\1,\2/g' input.txt.rev >> input.h
	echo "));" >> input.h
	gcc  -std=c++2a -lstdc++ -D PART1 ./main.cpp

part2:
	tac input.txt > input.txt.rev
	echo "struct Position terminal = EVAL(EXECUTE(" > input.h
	sed 's/\(\w\|\d\)\(\s\|$$\)/\1,\2/g' input.txt.rev >> input.h
	echo "));" >> input.h
	gcc  -std=c++2a -lstdc++ ./main.cpp
