all:
	bison --report=all -d prolog.y
	flex prolog.l
	gcc -ll -ggdb lex.yy.c prolog.tab.c -o prolog

clean:
	rm ./*.tab.*
	rm ./lex.yy.c
	rm ./prolog