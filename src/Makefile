RACC=~/.gem/ruby/1.9.1/bin/racc
OUTPUT=cscript_yacc.rb

yacc: cscript_yacc.y
	$(RACC) -o$(OUTPUT) -d -v $<

debug: cscript_yacc.y
	$(RACC) -o$(OUTPUT) -d -g -v $<


try: exec
.PHONY : exec
exec: tool/test_exec.rb
	ruby $<

.PHONY : lexer
lexer: tool/test_lexer.rb
	ruby $<

test:
	test/test_all.sh

.PHONY : clean
clean:
	rm -f *.tab.rb *.output $(OUTPUT)

