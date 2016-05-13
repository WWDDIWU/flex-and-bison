bison --report=all -d test.y
flex test.l
gcc -ll -ggdb lex.yy.c test.tab.c
./a.out
