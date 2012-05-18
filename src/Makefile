RACC=~/.gem/ruby/1.9.1/bin/racc
OUTPUT=cscript_yacc.rb

main_rule: cscript_yacc.y
	$(RACC) -o$(OUTPUT) -d -v $<


try: exec
.PHONY : exec
exec: tool/test_exec.rb
	ruby $<

.PHONY : lexer
lexer: tool/test_lexer.rb
	ruby $<


.PHONY : clean
clean:
	rm -f *.tab.rb *.output $(OUTPUT)

