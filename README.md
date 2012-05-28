# The CScript Programming Language

***(The project is still under development.)***

## A brief history of cscript

### The inspiration
In June 2011 I quit my work from the past company, then I started to consider to design a programming language that is like C but support powerful functional programming features, as in that time I was attracted by LISP.

Frankly, the original cscript did not have a name and it is so different from C. I designed it as block-based, which means, block will be the most obvious characteristic in it, for example, you can assign a block, execute a block, pass it as argument to a function, etc. However, in that time I even did not know Ruby. 

### Practices

At the first trial, I met many problems of designing that I can't continue it.

So I decide to change something, basically, I was going to design a "scriptify" C, and the else stuff was just dropped, even contains the featured "functional programming". At the time, my idea is just want a flexible solution that could be designed normally.

But you know, C innately is not a good dynamic language. So I struggled in many places and finally could't help to decide to give it up.

Then it is the third trial, it was started in February 2012, and it lasted for 2 month. This version of cscript did many changes that make itself different from C. I rewrite the syntax rules with better styled as meanwhile I learned some detailed yacc and lex. And it is the first version that I could form the cscript code into a syntax tree. That was very exciting. But when I realized something should be added, I found the code is so hard to change something, as it have to almost rewrite all the code to do so. Then I was fed up using pure C to do it. I start to think to change my mind to using partial python into programming, for example, use python to execute code and generate the tree in C. Thus it would be better to write code more dynamically, especially, more elegantly.

The current cscript is the fourth version, I choose Ruby to write all parts of the code, but make them separable. The project mainly separated in two parts -- the parser and the executor, this structure is just designed from the third version and I did a bit improvement. However, for separate these apart, I specially reconstructed the code, just at few days ago. The purpose is make the interfaces looser. Now, the communication between these two parts uses a tree of JSON or Ruby Hash. From the benefit of Ruby, I could now write more beautiful code and make it friendly to read, and rapid to run.

## How to use this ruby lib
Please check the interface document for details.

As it is not started to be written yet, I'll briefly give you some suggest here.

First, as mentioned, the code needs to first pass through the parser to form to a syntax tree, as that time, you might need to use `CScript::Parser` class.

    parser = CScript::Parser.new
    parser.scan_file(codefile)
    syntax_tree = parser.do_parse

And to communicate with the executor part, you need then convert the tree into json, like:

    json_tree = syntax_tree.to_json

Then create a program object, which contains a runtime and relevant things.

    prog = CScript::Program.new

And then load the json in the program:

    prog.load_json(json_tree)

Then execute:

    prog.run

That's it. Quite easy isn't that?

If you want to debug something, such as output, you need to set the option `$CS_DEBUG` in advance; set it into a numeric value to enable specific level of debugging, or set to true to enable default level.

Then you can use `EMIT` instruction(implemented as macro) in the code, it will emit a value that could be seen outside the program.

You may read its emissions after the program stopped, like:

    ...
    prog.run
    output_list = prog.emissions

Then you'll get an `Array` of values (typical values but not internal cscript values). Do something as you like then.




## Setup & Run

It is a now just under development, so all you need to do is just compile the yacc file to generate parser, and then run the program.

1. run `make` to generate parser's code to file `cscript_parser.rb`.
2. run `make try` to try the code execution, it read code from stdin.

If you just want to try the separated parts of cscript, there are following tools:

* `tool/test_exec.rb` behaves the same as `make try`, just run the code.
* `tool/test_yacc.rb` will read from stdin also and generate a readable syntax tree, which is used for debugging whether the parser works.
* `tool/test_scanner.rb` test lexer, also read from stdin and just used for debugging. It will output a plain lexical scanning result.

## Features from C

### Dynamic typing
You don't need to concern about types' problems, as they are all managed automatically.

For example, assigning variables:

    foo = 1;
    bar = "string";
    foo = "another string";


### Direct run
You don't need a `main` function to indicate the start point, it will run from start of the file.

### No memory management
Everything inside is a reference, so you don't need consider any thing about managing memory. cscript has a powerful garbage collection system. (As now it relies on Ruby's GC)

### Preprocessor from C *(Not yet finished)*
You can still use the powerful preprocessor from C. As a typical C compiler does, it will still call `cpp` program for preprocessing.

### Debugging *(Implementing)*
You may trace every value, functions, even the tree nodes' sources. Where it is from in the code, and where it is assigned first time and recently, is all now transparent to you!

### Portable
No matter what platform you are using, cscript is compatible with most operating systems. (As now it relies on Ruby also)

### Functional programming *(Not yet finished)*
CScript provides powerful functional programming features. You can use it as well as commanding programming.

### Dynamic code tree
If you don't like to run the program with original executor. You can just use the syntax parser separately; the code can be exported as JSON and XML*(Not yet finished)* format. The parser part and the executor part is completely separate.

### Exceptions *(Not yet finished)*
Exceptions could be thrown and caught. It is a fast way to jump among functions, and widely used for error recovering.


## Contributors
* Original Founder: Shou Ya (<zxyzxy12321@gmail.com>)

## License
The project is published under GNU GENERAL PUBLIC LICENSE Version 3 (GPLv3)

Copyright 2012, Shou Ya




