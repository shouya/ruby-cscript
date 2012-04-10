require 'test/unit'
require_relative '../cscript_lex'

class MyTest < Test::Unit::TestCase
    include CScriptScanner

    def test_scan_mixed
        scan_string('''A Lazy dog jump 6 "ver" /* a fox */;''')
        assert_equal next_token, [:NAME, 'A']
        assert_equal next_token, [:NAME, 'Lazy']
        assert_equal next_token, [:NAME, 'dog']
        assert_equal next_token, [:NAME, 'jump']
        assert_equal next_token, [:INTEGER, 6]
        assert_equal next_token, [:STRING, 'ver']
        assert_equal next_token, [';', nil]
        assert_equal next_token, [false, false]
    end

    def test_scan_comments
        scan_string(''' /* Wtf do /* /* /*/ */pa do  /*/ */''')
        assert_equal next_token, ['*', nil]
        assert_equal next_token, ['/', nil]
        assert_equal next_token, [:NAME, 'pa']
        assert_equal next_token, [:DO, nil]
    end

    def test_scan_symbols
        scan_string(''', . ; / => /* /* /*/ */''')
        assert_equal next_token, [',', nil]
        assert_equal next_token, ['.', nil]
        assert_equal next_token, [';', nil]
        assert_equal next_token, ['/', nil]
        assert_equal next_token, ['=', nil]
        assert_equal next_token, [:RELATION, '>']
        assert_equal next_token, ['*', nil]
        assert_equal next_token, ['/', nil]
    end

    def test_scan_complex_symbols
        scan_string('''++--b++c==d!=e''')
        assert_equal next_token, [:INCREASE, nil]
        assert_equal next_token, [:DECREASE, nil]
        next_token
        assert_equal next_token, [:INCREASE, nil]
        next_token
        assert_equal next_token, [:EQUALITY, '=']
        next_token
        assert_equal next_token, [:EQUALITY, '!']
    end

    def test_scan_names
        scan_string('''abc 2efg hij L4K''')
        assert_equal next_token, [:NAME, 'abc']
        assert_equal next_token, [:INTEGER, 2]
        assert_equal next_token, [:NAME, 'efg']
        assert_equal next_token, [:NAME, 'hij']
        assert_equal next_token, [:NAME, 'L4K']
        assert_equal next_token, [false, false]
    end

    def test_scan_newlines
        scan_string("""line1; line1; \n line2 \n line3 \r line4""")
        assert_equal lineno, 1
        assert_equal next_token, [:NAME, 'line1']
        assert_equal next_token, [';', nil]
        next_token; next_token; # line1, ';'
        assert_equal next_token, [:NAME, 'line2']
        assert_equal lineno, 2
        next_token; # line3
        assert_equal next_token, [:NAME, 'line4']
        assert_equal lineno, 4
    end

end

