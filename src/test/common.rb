# This file is just used for included by other test programs.
# It only includes some convenient operations for testing

$mode = :syntax if ARGF.argv[0] == 'syntax'
$mode = :lexer if ARGF.argv[0] == 'lexer'
$mode = :parse_lexer if ARGF.argv[0] == 'parse_lexer'
$mode = :cat if ARGF.argv[0] == 'cat'

require 'test/unit' unless $mode

$CS_DEBUG = 1
require_relative '../cscript'

begin
    require 'ap'
    alias :pp :ap

rescue LoadError
    require 'pp'
end


module Test; module Unit; module Assertions; end; end; end

module Test::Unit::Assertions
    def assert_cscript_emissions(prog, ems, msg = nil)
        parser = CScript::Parser.new
        parser.scan_string(prog)
        tree = parser.do_parse.to_json

        program = CScript::Program.new
        program.load_json(tree)
        program.run

        if ems.class != Array
            ems = [ems]
        end
        assert_equal(ems.flatten, program.emissions, msg)
    end
    def assert_cscript_raise(prog, exc)
        parser = CScript::Parser.new
        parser.scan_string(prog)
        tree = parser.do_parse.to_json

        assert_raise exc do
            prog = CScript::Program.new
            prog.load_json(tree)
            prog.run
        end
    end
end


def inc
    @_inc ||= 0
    return @_inc = @_inc.succ
end

class Test::Unit::TestCase; end
class MyTest < Test::Unit::TestCase
end

def simple_test(ems, name = inc)
    MyTest.class_eval do
        define_method "test_#{name}" do
            assert_cscript_emissions(yield, ems)
        end
    end
end

def simple_test_raise(exc, name = inc)
    MyTest.class_eval do
        define_method "test_#{name}" do
            assert_cscript_raise(yield, exc)
        end
    end
end

def more_simple_test(ems, name = inc)
    simple_test(ems, name) do
        eval('DATA.read')
    end
end

if ARGF.argv[0] == 'syntax'
    Object.send :remove_const, :MyTest
    Object.const_set(:MyTest, Class.new(BasicObject))

    def simple_test(exc = [], name = inc)
        parser = CScript::Parser.new
        parser.scan_string(yield)
#        ap parser.do_parse
        json = JSON.parse(parser.do_parse.to_json, :max_nesting => 1000)
        begin
            pp json, :indent => 2
        rescue ArgumentError
            pp json
        end
    end
elsif ARGF.argv[0] == 'lexer'
    Object.send :remove_const, :MyTest
    Object.const_set(:MyTest, Class.new(BasicObject))

    def simple_test(exc = [], name = inc)
        parser = CScript::Parser.new
        parser.scan_string(yield)

        until (token = parser.scanner.next_token) == [false, false] do
            puts token.inspect
        end
        puts '-' * 70
    end
elsif ARGF.argv[0] == 'cat'
    def simple_test(*args)
        @i ||= nil
        puts File.read($0) and @i = 1 unless @i
    end
elsif $mode == :parse_lexer
    def simple_test(*args)
        parser = CScript::Parser.new
        scanner = parser.scanner
        parser.yacc.singleton_class.class_eval do
            alias_method :next_token_surrounded, :next_token

            define_method :next_token do
                tok = next_token_surrounded

                disp_tok = tok.dup
                disp_tok = %{"#{disp_tok[0]}"} if disp_tok[1].nil?
                disp_tok = "#{disp_tok[0]}(#{disp_tok[1]})" \
                    if disp_tok.length == 2 and disp_tok.is_a? Array

                out = ''
                out << "(#{scanner.location[1..-1].join(':')}) ".rjust(8)
                out << disp_tok.to_s

                parsed = scanner.string[0..scanner.scanner.pos]
                rest = scanner.scanner.rest

                parsed.gsub! /.*\n/, ''
                parsed.sub! /(.*)./, '\1'
                rest.gsub! /\n.*/, ''

                puts "#{out.ljust(30, '-')}#{parsed}.#{rest}"

                tok
            end
            parser.scan_string(yield)
            parser.do_parse
        end
    end
end



