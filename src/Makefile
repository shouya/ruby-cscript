RACC=~/.gem/ruby/1.9.1/bin/racc
OUTPUT=cscript_yacc.rb

main_rule: cscript_yacc.y
	$(RACC) -o$(OUTPUT) -d -v $<


.PHONY : try
try: test_exec.rb
	ruby $<


.PHONY : clean
clean:
	rm -f *.tab.rb *.output $(OUTPUT)

