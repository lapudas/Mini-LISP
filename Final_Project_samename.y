%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>

    //variable
    char* var_name[100];
    int var_value[100];
    char* var_type[100];
    int var_p=0;

    //error message
    void yyerror (const char *message);
%}

%code requires {
    //AST
    typedef struct node node;
    struct node{
        node* left;
        node* right;
        node* mid; //給if之類的用
        
        int value;
        char* id;
        char* btype;    //big type e.g. NUM-OP
        char* stype;    //small type e.g. PLUS
    };
}

%union{
    int ival;
    char* sval;
    node* nodeptr;
}

%{
    node* new_node(node* left, node* right);
    node* root;

    //function
    char* fun_name[100];
    node* fun_node[100];
    int fun_p=0;

%}

// 記得換成 node
%token <ival> number bool_val
%token <sval> ID 
%token print_num print_bool IF OR AND MOD NOT DEFINE fun
%type <nodeptr> NUM_OP PLUS PLUS_EXPS MINUS MULTIPLY MULTIPLY_EXPS DIVIDE MODULUS GREATER SMALLER EQUAL EQUAL_EXPS
%type <nodeptr> LOGICAL_OP AND_OP OR_OP NOT_OP AND_EXPS OR_EXPS
%type <nodeptr> IF_EXP TEST_EXP THEN_EXP ELSE_EXP EXP
%type <nodeptr> VARIABLE
%type <nodeptr> START PROGRAM STMT DEF_STMT PRINT_STMT
%type <nodeptr> FUN_CALL FUN_EXP FUN_IDs IDs FUN_BODY PARAM FUN_NAME

%%
START : PROGRAM {root=$1;};

PROGRAM : PROGRAM STMT  {$$ = new_node($1,$2);}
        | STMT  {$$ = new_node($1,NULL);}
        ;

STMT : EXP {$$=$1;}
    | DEF_STMT {$$=$1;}
    | PRINT_STMT {$$=$1;}
    ;

PRINT_STMT : '(' print_num EXP ')' {$$ = new_node($3,NULL);  $$->btype="print"; $$->stype="num";}
            | '(' print_bool EXP ')' {$$ = new_node($3,NULL); $$->btype="print"; $$->stype="bool";}
            ;

EXP : bool_val {$$ = new_node(NULL,NULL); $$->value=$1; $$->btype="bool_val";}
    | number {$$ = new_node(NULL,NULL); $$->value=$1; $$->btype="number";}
    | VARIABLE {$$ = $1;}
    | NUM_OP {$$ = $1; $$->btype="NUM_OP";}
    | LOGICAL_OP {$$ = $1; $$->btype="LOGICAL_OP";}
    | FUN_EXP {$$ = $1;}
    | FUN_CALL {$$ = $1;}
    | IF_EXP {$$ = $1;}
    ;

NUM_OP : PLUS {$$ = $1;}
    | MINUS {$$ = $1;}
    | MULTIPLY {$$ = $1;}
    | DIVIDE {$$ = $1;}
    | MODULUS {$$ = $1;}
    | GREATER {$$ = $1;}
    | SMALLER {$$ = $1;}
    | EQUAL {$$ = $1;}
    ;

PLUS : '(' '+' EXP PLUS_EXPS ')' {$$ = new_node($3,$4); $$->stype="PLUS";}
PLUS_EXPS : PLUS_EXPS EXP {$$ = new_node($1,$2); $$->stype="PLUS"; $$->btype="NUM_OP";}
            | EXP {$$=$1;};
MINUS : '(' '-' EXP EXP ')' {$$ = new_node($3,$4); $$->stype="MINUS";}
MULTIPLY : '(' '*' EXP MULTIPLY_EXPS ')' {$$ = new_node($3,$4); $$->stype="MULTIPLY";}
MULTIPLY_EXPS : MULTIPLY_EXPS EXP {$$ = new_node($1,$2); $$->stype="MULTIPLY"; $$->btype="NUM_OP";}
                | EXP {$$=$1;};
DIVIDE : '(' '/' EXP EXP ')'    {$$ = new_node($3,$4); $$->stype="DIVIDE";};
MODULUS : '(' MOD EXP EXP ')'   {$$ = new_node($3,$4); $$->stype="MODULUS";};

GREATER : '(' '>' EXP EXP ')'   {$$ = new_node($3,$4); $$->stype="GREATER";};
SMALLER : '(' '<' EXP EXP ')'   {$$ = new_node($3,$4); $$->stype="SMALLER";};
EQUAL : '(' '=' EXP EQUAL_EXPS ')'  {$$ = new_node($3,$4); $$->stype="EQUAL";};
EQUAL_EXPS : EXP EQUAL_EXPS {$$ = new_node($1,$2); $$->stype="EQUAL"; $$->btype="NUM_OP";}
            | EXP {$$ = new_node($1,NULL);};

LOGICAL_OP : AND_OP {$$=$1;}
            | OR_OP {$$=$1;}
            | NOT_OP {$$=$1;}
            ;
AND_OP : '(' AND EXP AND_EXPS ')'   {$$=new_node($3,$4); $$->stype="AND";};
AND_EXPS : AND_EXPS EXP {$$=new_node($1,$2); $$->stype="AND"; $$->btype="LOGICAL_OP";}
        | EXP {$$ = $1;};
OR_OP : '(' OR EXP OR_EXPS ')' {$$=new_node($3,$4); $$->stype="OR";};
OR_EXPS : OR_EXPS EXP   {$$=new_node($1,$2); $$->stype="OR"; $$->btype="LOGICAL_OP";}
        | EXP {$$ = $1;};
NOT_OP : '(' NOT EXP ')'    {$$=new_node($3,NULL); $$->stype="NOT";};

// func 的 token type 設定、 .l 那邊記得檢查
DEF_STMT : '(' DEFINE VARIABLE EXP ')'  {
    $$ = new_node($3,$4); $$->btype="define";
    };
VARIABLE : ID {$$=new_node(NULL,NULL); $$->btype="variable"; $$->id=$1;};
FUN_EXP : '(' fun FUN_IDs FUN_BODY ')' {$$=new_node($3,$4); $$->btype="func_exp";};
FUN_IDs : '(' IDs ')' {$$=$2;};
IDs : ID IDs {$$=new_node($2,NULL); $$->id=$1;}
    | {$$=NULL;};
FUN_BODY : EXP {$$=$1;};
FUN_CALL : '(' FUN_EXP PARAM ')' {$$=new_node($2,$3); $$->btype="func_call";}
        | '(' FUN_NAME PARAM ')' {
            $$=new_node($2,$3); $$->btype="func_call";}
        ;
PARAM : EXP PARAM  {$$=new_node($2,$1);}
        | {$$=NULL;}
        ;
FUN_NAME : ID {$$=new_node(NULL,NULL); $$->id=$1;}

IF_EXP : '(' IF TEST_EXP THEN_EXP ELSE_EXP ')' {$$=new_node($3,$5); $$->mid=$4; $$->btype="if";};
TEST_EXP : EXP {$$=$1;};
THEN_EXP : EXP {$$=$1;};
ELSE_EXP : EXP {$$=$1;};

%%
void traversal(node *n);

node* new_node(node* left, node* right){
    node* N = malloc(sizeof(node));
    N->left = left; N->right = right;
    N->mid = NULL;

    N->value = 0;
    N->id = NULL;
    N->btype = NULL;
    N->stype = NULL;
    return N;
}

void copy_node(node* a, node* b){
    a->left = b->left; a->right = b->right;
    a->mid = b->mid;
    a->value = b->value;
    a->id = b->id;
    a->btype = b->btype;
    a->stype = b->stype;
}

node* copy_root(node* a){
    if(a==NULL)
        return NULL;
    node* N = malloc(sizeof(node));
    N->left = copy_root(a->left); N->right = copy_root(a->right);
    N->mid = copy_root(a->mid);

    N->value = a->value; N->id = a->id;
    N->btype = a->btype; N->stype = a->stype;
    return N;
}

void replace_param(node* N, node* IDs, node* param){
    if(N==NULL)
        return;
    else if(N->btype && strcmp(N->btype,"func_call")==0){
        if(!N->left->btype){   // 將 fun_name 替換成對應 exp
            char* name=N->left->id; 
            node* tmp=NULL;
            int i;
            for(i=0;i<fun_p;i++)
                if(strcmp(fun_name[i],name)==0)
                    tmp=fun_node[i];
            if(tmp == NULL){
                printf("function not defined.\n");
                exit(0);
            }
            N -> left = copy_root(tmp);
        }
        replace_param(N->right,IDs,param);  //替換param裡上一層func的func_var
        node *tmps = IDs, *tmps1 = param;
        while(tmps){    //如果上一層func_var不會被這層func_var覆蓋，繼承上一層的func_var
            int bools = 0;
            node* tmps2 = N->left;
            while(tmps2->left){
                if(strcmp(tmps2->left->id,tmps->id)==0)
                    bools = 1;
                tmps2 = tmps2->left;
            }
            if(bools==0){
                tmps2->left = new_node(NULL,NULL);
                copy_node(tmps2->left,tmps);
                node* tmps4=N->right;
                while(tmps4->left)
                    tmps4 = tmps4->left;
                tmps4->left = new_node(NULL,NULL);
                copy_node(tmps4->left,tmps1);
            }
            tmps=tmps->left;
            tmps1=tmps1->left;
        }
        replace_param(N->left->right,N->left->left,N->right);
        traversal(N);   //先算好結果
        return;
    }

    if(N->btype && strcmp(N->btype,"variable")==0){
        char* name=N->id;
        node* tmp=IDs;
        int p=0;
        while(tmp && strcmp(tmp->id,name)!=0){
            p+=1;
            tmp = tmp->left;
            //printf("IDs: %d.\n",p);
        }
        if(tmp){
            tmp = param;
            while(p>0){
                p-=1;
                //printf("param: %d.\n",p);
                tmp = tmp->left;
                if(tmp==NULL){
                    printf("param lack.\n");
                    exit(0);
                }
            }
            traversal(tmp->right);
            copy_node(N,tmp->right);
        }
        else    //當一般變數(非fun_var)處理
            traversal(N);
    }
    else{
        replace_param(N->left,IDs,param);
        replace_param(N->right,IDs,param);
        replace_param(N->mid,IDs,param);
    }
}

void yyerror (const char *message)
{
	fprintf(stderr,"%s\n",message);
}

void traversal(node *n){
    if(n==NULL)
        return;
    else if(n->btype &&( strcmp(n->btype,"number")==0 || strcmp(n->btype,"bool_val")==0))
        return;
    else if(!n->btype){
        traversal(n->left);
        traversal(n->right);
        return;
    }

    if(strcmp(n->btype,"NUM_OP")==0){
        traversal(n->left);
        traversal(n->right);
        if(strcmp(n->stype,"PLUS")==0){
            n->value = n->left->value + n->right->value;
            n->btype = "number";
        }
        else if(strcmp(n->stype,"MINUS")==0){
            n->value = n->left->value - n->right->value;
            n->btype = "number";
        }
        else if(strcmp(n->stype,"MULTIPLY")==0){
            n->value = n->left->value * n->right->value;
            n->btype = "number";
        }
        else if(strcmp(n->stype,"DIVIDE")==0){
            n->value = n->left->value / n->right->value;
            n->btype = "number";
        }
        else if(strcmp(n->stype,"MODULUS")==0){
            n->value = n->left->value % n->right->value;
            n->btype = "number";
        }
        else if(strcmp(n->stype,"GREATER")==0){
            n->value = (n->left->value > n->right->value);
            n->btype = "bool_val";
        }
        else if(strcmp(n->stype,"SMALLER")==0){
            n->value = (n->left->value < n->right->value);
            n->btype = "bool_val";
        }
        else if(strcmp(n->stype,"EQUAL")==0){   //要確認type可以再加
            traversal(n->left); //left是要比較的EXP，right是指向下一個EQUAL發生點
            int tmp=n->left->value,bool_tmp=1;
            node* p=n;
            while(p->right){
                traversal(p->right->left);
                if(tmp!=p->right->left->value){
                    bool_tmp=0;
                    break;
                }
                p = p->right;
            }
            n->value=bool_tmp;
            n->btype="bool_val";
        }
        else
            printf("NUM_OP stype error\n");
    }
    else if(strcmp(n->btype,"LOGICAL_OP")==0){
        traversal(n->left);
        traversal(n->right);
        if(strcmp(n->stype,"AND")==0){
            n->value = n->left->value && n->right->value;
            n->btype = "bool_val";
        }
        else if(strcmp(n->stype,"OR")==0){
            n->value = n->left->value || n->right->value;
            n->btype = "bool_val";
        }
        else if(strcmp(n->stype,"NOT")==0){
            n->value = !(n->left->value);
            n->btype = "bool_val";
        }
        else
            printf("LOGICAL_OP stype error\n");
    }
    else if(strcmp(n->btype,"print")==0){
        traversal(n->left);
        traversal(n->right);
        if(strcmp(n->stype,"num")==0)
            printf("%d\n",n->left->value);
        else if(strcmp(n->stype,"bool")==0){
            if(n->left->value==1)
                printf("#t\n");
            else
                printf("#f\n");
        }
        else
            printf("print stype error\n");
    }
    else if(strcmp(n->btype,"if")==0){
        traversal(n->left);
        if(n->left->value == 1){
            traversal(n->mid);
            copy_node(n,n->mid);
        }
        else{
            traversal(n->right);
            copy_node(n,n->right);
        }
    }
    else if(strcmp(n->btype,"define")==0){
        int i;
        char* name= n->left->id;
        for(i=0;i<fun_p;i++) //不能redifined
            if(strcmp(fun_name[i],name)==0){
                printf("redefining is not allowed.\n");
                exit(0);
            }
        for(i=0;i<var_p;i++)
            if(strcmp(var_name[i],name)==0){
                printf("redefining is not allowed.\n");
                exit(0);
            }

        if(strcmp(n->right->btype,"func_exp")==0) {
            fun_name[fun_p] = name;
            fun_node[fun_p] = n->right;
            fun_p += 1;
        }
        else{
            traversal(n->right);
            var_name[var_p] = name;
            var_value[var_p] = n->right->value;
            var_type[var_p] = n->right->btype;
            var_p += 1;
        }
    }
    else if(strcmp(n->btype,"variable")==0){
        int i;
        for(i=0;i<var_p;i++)
            if(strcmp(var_name[i],n->id)==0){
                n->value=var_value[i];
                n->btype=var_type[i];
                break;
            }
        if(i==var_p){
            printf("variable not defined.\n");
            exit(0);
        }
    }
    else if(strcmp(n->btype,"func_call")==0){ 
        //printf("before copy_root.\n");
        if(!n->left->btype){   // 將 fun_name 替換成對應 exp
            char* name=n->left->id; 
            node* tmp=NULL;
            int i;
            for(i=0;i<fun_p;i++)
                if(strcmp(fun_name[i],name)==0)
                    tmp=fun_node[i];
            if(tmp == NULL){
                printf("function not defined.\n");
                exit(0);
            }
            n -> left = copy_root(tmp);
        }
        //printf("before replace_param.\n");
        replace_param(n->left->right, n->left->left, n->right); //替換fun_exp內的變數
        //printf("before traversal.\n");
        traversal(n->left->right);  //跑fun_exp
        //printf("before copy_func_result.\n");
        copy_node(n,n->left->right);
    }
    else
        printf("btype error.\n");
}

int main(int argc,char *argv[]){
	yyparse();
    traversal(root);
	return(0);
}