RACC=~/.gem/ruby/1.9.1/bin/racc

main_rule: cscript_yacc.y
	$(RACC) -d -v $<

.PHONY : clean
clean:
	rm -f *.tab.rb *.output

