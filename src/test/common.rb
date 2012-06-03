# This file is just used for included by other test programs.
# It only includes some convenient operations for testing

require 'test/unit'

$CS_DEBUG = 1
require_relative '../cscript'

begin
    require 'ap'
    alias :pp :ap

rescue LoadError
    require 'pp'
end

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

def very_simple_test(ems, name = inc)
    simple_test(ems, name) do
        eval('DATA.read')
    end
end

if ARGF.argv[0] == 'syntax'
    def simple_test(exc, name = inc)
        parser = CScript::Parser.new
        parser.scan_string(yield)
        json = parser.do_parse.as_json
        begin
            pp json, :indent => 2
        rescue ArgumentError
            pp json
        end
    end
end


