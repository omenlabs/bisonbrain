/* 
 * Simple Brainfuck implementation using Flex and Bison
 * Copyright 2020 John Hickey
 */
%{
	#include <stdio.h>
	#include "bisonbrain.tab.h"
%}

%option noyywrap

%%
[ \t\n] ; /*ignore whitespace */
">" { return INCR_PTR; }
"<" { return DECR_PTR; }
"+" { return INCR; }
"-" { return DECR; }
"." { return OUT_B; }
"," { return IN_B; }
"[" { return LOOP_S; }
"]" { return LOOP_E; }
 
%%
