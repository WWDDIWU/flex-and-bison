%{
    #include "test.tab.h"
%}

digit [0-9]
var [_A-Z][A-Za-z0-9]*
label [a-z]+

%%
{var} {
    yylval.string_val = strdup(yytext);
    return VAR;
}
{label} {
    yylval.string_val = strdup(yytext);
    return LABEL;
}
-?{digit}+ {
    yylval.string_val = strdup(yytext);
    return INT;
}
" is " {return IS;}
\[ {return OBR;}
\] {return CBR;}
\. {return DOT;}
:- {return CD;}
; {return SEMICOLON;}
\( {return OPA;}
\) {return CPA;}
, {return COMMA;}
\>= {return GTE;}
\=< {return LTE;}
-> {return IF;}
\< {return LT;}
\> {return GT;}
= {return EQ;}
\| {return PIPE;}
\+ {return PLUS;}
- {return MINUS;}
\* {return MULTIPLY;}
\/ {return DIVIDE;}
\n {return LF;}
" "+ {;}
"~\n" {return slash;}
. {return WWDDIWU;}
