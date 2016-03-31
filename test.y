%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    int yyerror(char *s);
    int yylex(void);

    int lineno = 0;
    int sum = 0;
%}

%union {
    int int_val;
    char *string_val;
}

%start entry

%left PLUS MINUS MULTIPLY DIVIDE GTE LTE LT GT
%token <int_val> INT
%token <string_val> LABEL
%token OPA CPA COMMA IF EQ PIPE LF WWDDIWU VAR OBR CBR IS DOT CD SEMICOLON

%%

list                : OBR innerlist CBR

innerlist           : element PIPE rest
                    | element

element             : intodervar
                    | intodervar COMMA endingelement
                    | // epsilon

endingelement       : intodervar
                    | intodervar COMMA endingelement

intodervar          : INT
                    | VAR
                    | OPA INT CPA

rest                : list
                    | element

entry               : function CD rulelist
                    | rule
                    | // epsilon

rulelist            : statement COMMA rulelist
                    | statement DOT LF entry

statement           : math
                    | function
                    | isstatement

math                : math mathsym math
                    | intodervar

isstatement         : VAR IS math

mathsym             : GTE
                    | LTE
                    | LT
                    | GT
                    | PLUS
                    | MINUS
                    | MULTIPLY
                    | DIVIDE

rule                :function DOT LF entry

function            : LABEL OPA args CPA

args                : args COMMA args
                    | intodervar
                    | LABEL
                    | list

%%

int yyerror(char *s)
{
  extern int yylineno;	// defined and maintained in lex.c
  extern char *yytext;	// defined and maintained in lex.c

  printf("Error: %s at symbol %s\n", s, yytext);
  exit(1);
}

int main() {
    yyparse();
    return 0;
}
