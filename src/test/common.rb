# This file is just used for included by other test programs.
# It only includes some convenient operations for testing

require 'test/unit'

$CS_DEBUG = 1
require_relative '../cscript_parser'
require_relative '../cscript_runtime'

module Test::Unit::Assertions
    def assert_cscript_emissions(prog, ems, msg = nil)
        parser = CScriptParser.new
        parser.scan_string(prog)
        tree = parser.do_parse

        runtime = CScriptRuntime.new

        runtime.execute(tree)

        if ems.class != Array
            ems = [ems]
        end
        assert_equal(ems.flatten, runtime.emissions, msg)
    end
    def assert_cscript_raise(prog, exc)
        parser = CScriptParser.new
        parser.scan_string(prog)
        tree = parser.do_parse

        assert_raise exc do
            CScriptRuntime.execute(tree)
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


