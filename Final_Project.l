%{
    #include "Final_Project.tab.h"
%}

MODULUS "mod"
AND "and"
OR "or"
NOT "not"
IF "if"
DEFINE "define"
print_num "print-num"
print_bool "print-bool"
fun "fun"

separator [\t\n\r ]
letter [a-z]
digit [0-9]

number (0|[1-9]{digit}*|\-[1-9]{digit}*)
ID {letter}({letter}|{digit}|\-)*
bool_val ("#t"|"#f")

%%
[\+\-\*/><=\(\)] {return(yytext[0]);}
{print_num} {return(print_num);}
{print_bool} {return(print_bool);}
{separator} {;}
{MODULUS} {return(MOD);}
{AND} {return(AND);}
{OR} {return(OR);}
{NOT} {return(NOT);}
{IF} {return(IF);}
{fun} {return(fun);}
{number} {yylval.ival=atoi(yytext); return(number);}
{DEFINE} {return(DEFINE);}
{bool_val} {if(strcmp(yytext,"#t")==0) yylval.ival=1; else yylval.ival=0; return(bool_val);}
{ID} {yylval.sval=strdup(yytext); return(ID);}
. {;}

%%