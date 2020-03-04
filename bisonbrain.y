/* 
 * Simple Brainfuck implementation using Flex and Bison
 * Copyright 2020 John Hickey
 */
%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <err.h>
	#include <sysexits.h>

	char array[30000];
	char *ptr = array;

	extern int yylex();
	extern int yyparse();
	extern FILE *yyin;
	void yyerror(const char *s);

	struct op_list {
		int op;
		struct op_list *next;
		struct op_list *sublist; /* For loops */
	};
	struct op_list *mk_op(int op, struct op_list *next, struct op_list *sublist);
	struct op_list *append_op(struct op_list *list, struct op_list *next);
	void free_op(struct op_list *list);
	void execute(struct op_list *list);
%}

%union {
	struct op_list *op_list;
}

%token INCR_PTR INCR DECR_PTR DECR IN_B OUT_B LOOP_S LOOP_E LOOP
%type <op_list> op op_list

%%
program: /* empty */
	| op_list { execute($1); free_op($1); }
;

op_list:
	op { $$ = $1; }
	| op_list op { $$ = append_op($1, $2); }
;
op: 
	INCR_PTR { $$ = mk_op(INCR_PTR, NULL, NULL); }
	| INCR { $$ = mk_op(INCR, NULL, NULL); }
	| DECR_PTR { $$ = mk_op(DECR_PTR, NULL, NULL); }
	| DECR { $$ = mk_op(DECR, NULL, NULL); }
	| IN_B { $$ = mk_op(IN_B, NULL, NULL); }
	| OUT_B { $$ = mk_op(OUT_B, NULL, NULL); }
	| LOOP_S op_list LOOP_E { $$ = mk_op(LOOP, NULL, $2); }
;
%%

struct op_list *mk_op(int op, struct op_list *next, struct op_list *sublist) {
	struct op_list *new = calloc(1, sizeof(struct op_list));
	new->op = op;
	new->next = next;
	new->sublist = sublist;

	return new;
}

struct op_list *append_op(struct op_list *list, struct op_list *next) {
	struct op_list *head = list;
	// Move to the end of the list
	while (list->next) {
		list = list->next;
	}
	list->next = next;

	return head;
}

void free_op(struct op_list *list) {
	struct op_list *cur = list;
	struct op_list *prev;

	while (cur) {
		if (cur->sublist) {
			free_op(cur->sublist);
		}
		prev = cur;
		cur = cur->next;
		free(prev);
	}
}

void execute(struct op_list *list) {
	if (!list)
		return;

	struct op_list *cur_op = list;

	while (cur_op) {
		switch (cur_op->op) {
		case LOOP:
			while(*ptr) {
				execute(cur_op->sublist);
			}
			break;
		case INCR_PTR: 
			ptr++;
			break;
		case INCR:
			(*ptr)++;
			break;
		case DECR_PTR:
			ptr--;
			break;
		case DECR:
			(*ptr)--;
			break;
		case IN_B:
			*ptr = getchar();
			break;
		case OUT_B:
			putchar(*ptr);
			break;
		}

		cur_op = cur_op->next;
	}
}

int main(int argc, char **argv) {
	FILE *f;
	if (argc == 2) {
		f = fopen(argv[1], "r");
		if (!f)
			errx(EX_USAGE, "Unable to open file %s", argv[1]);
		yyin = f;
	}
	yyparse();
	if (argc == 2)
		fclose(f);
}

void yyerror(const char *s) {
	fprintf(stderr, "Error: %s\n", s);
}
