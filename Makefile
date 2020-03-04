bisonbrain: lex.yy.c bisonbrain.tab.c bisonbrain.tab.h
	cc -o $@ bisonbrain.tab.c lex.yy.c

bisonbrain.tab.c bisonbrain.tab.h: bisonbrain.y
	bison -v -d $<

lex.yy.c: bisonbrain.l bisonbrain.tab.h
	flex $<

clean:
	-rm *.o *.output bisonbrain bisonbrain.tab.c bisonbrain.tab.h bisonbrain lex.yy.c
