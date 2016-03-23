bison -d test.y
flex test.l
gcc -ll lex.yy.c test.tab.c
./a.out
