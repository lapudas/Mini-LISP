%{
    #include <stdio.h>
    #include <string.h>
    char* var_name[100];
    int var_value[100];
    int var_p=0;
    int equal_tmp=1;
    void yyerror (const char *message);
%}

%union{
    int ival;
    char* sval;
}

%token <ival> number bool_val
%token <sval> ID 
%token print_num print_bool IF OR AND MOD NOT DEFINE
%type <ival> NUM_OP PLUS PLUS_EXPS MINUS MULTIPLY MULTIPLY_EXPS DIVIDE MODULUS GREATER SMALLER EQUAL EQUAL_EXPS
%type <ival> LOGICAL_OP AND_OP OR_OP NOT_OP AND_EXPS OR_EXPS
%type <ival> IF_EXP TEST_EXP THEN_EXP ELSE_EXP EXP
%type <sval> VARIABLE
%type <ival> PROGRAM STMT DEF_STMT PRINT_STMT

%%
PROGRAM : PROGRAM STMT {;}
        | {;}
        ;

STMT : EXP {;}
    | DEF_STMT {;}
    | PRINT_STMT {;}
    ;

PRINT_STMT : '(' print_num EXP ')'  {printf("%d\n",$3);}
            | '(' print_bool EXP ')'    {if($3==1) printf("#t\n"); else printf("#f\n");}
            ;

EXP : bool_val {$$=$1;}
    | number {$$=$1;}
    | VARIABLE {
        int i;
        for (i=0;i<var_p;i++) 
            if(strcmp($1,var_name[i])==0)
                $$ = var_value[i];
    }
    | NUM_OP {$$=$1;}
    | LOGICAL_OP {$$=$1;}
    | IF_EXP {$$=$1;}
    ;

NUM_OP : PLUS {$$=$1;}
    | MINUS {$$=$1;}
    | MULTIPLY {$$=$1;}
    | DIVIDE {$$=$1;}
    | MODULUS {$$=$1;}
    | GREATER {$$=$1;}
    | SMALLER {$$=$1;}
    | EQUAL {$$=$1;}
    ;

PLUS : '(' '+' EXP PLUS_EXPS ')' {$$ = $3 + $4;};
PLUS_EXPS : PLUS_EXPS EXP {$$ = $1 + $2;}
            | EXP {$$ = $1;};
MINUS : '(' '-' EXP EXP ')' {$$ = $3 - $4;};
MULTIPLY : '(' '*' EXP MULTIPLY_EXPS ')' {$$ = $3 * $4;};
MULTIPLY_EXPS : MULTIPLY_EXPS EXP {$$ = $1* $2;}
                | EXP {$$ = $1;};
DIVIDE : '(' '/' EXP EXP ')'    {$$ = $3 / $4;};
MODULUS : '(' MOD EXP EXP ')'   {$$ = $3 % $4;};

GREATER : '(' '>' EXP EXP ')'   {if($3>$4) $$=1;else $$=0;};
SMALLER : '(' '<' EXP EXP ')'   {if($3<$4) $$=1;else $$=0;};
EQUAL : '(' '=' EXP EQUAL_EXPS ')'  {if($3==$4 && equal_tmp) $$=1;else $$=0;};
EQUAL_EXPS : EXP EQUAL_EXPS {if($1!=$2) equal_tmp=0;$$=$1;}
            | EXP {$$=$1;equal_tmp=1;};

LOGICAL_OP : AND_OP {$$=$1;}
            | OR_OP {$$=$1;}
            | NOT_OP    {$$=$1;}
            ;
AND_OP : '(' AND EXP AND_EXPS ')'   {$$ = $3 && $4;};
AND_EXPS : AND_EXPS EXP {$$ = $1 && $2;}
        | EXP {$$=$1;};
OR_OP : '(' OR EXP OR_EXPS ')' {$$ = $3 || $4;};
OR_EXPS : OR_EXPS EXP   {$$ = $1 || $2;}
        | EXP {$$=$1;};
NOT_OP : '(' NOT EXP ')'    {$$ = ($3+1) % 2;};

DEF_STMT : '(' DEFINE VARIABLE EXP ')'  {
    int i; 
    for (i=0;i<var_p;i++) 
        if(strcmp($3,var_name[i])==0) {
            printf("Redefining is not allowed.\n");
            return 0;
        } 
    var_name[var_p]=$3;
    var_value[var_p]=$4;
    var_p+=1;};
VARIABLE : ID   {$$=$1;};

IF_EXP : '(' IF TEST_EXP THEN_EXP ELSE_EXP ')' {if($3==1) $$=$4; else $$=$5;};
TEST_EXP : EXP  {$$=$1;};
THEN_EXP : EXP  {$$=$1;};
ELSE_EXP : EXP  {$$=$1;};

%%
void yyerror (const char *message)
{
	fprintf(stderr,"%s\n",message);
}

int main(int argc,char *argv[]){
	yyparse();
	return(0);
}