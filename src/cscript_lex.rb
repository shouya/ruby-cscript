# Lexer for racc, cscript project
# Shou Ya, 8 Apr morning
#
# vim filetype=ruby

module CScriptScanner
    require 'strscan'

    def self.rules
        return @rules
    end
    #
    # Rules operatable operations
    #    text: matched text, read-only
    #    @state, @state= set current state as `new_stat`
    #    inc_lineno(), @lineno, @lineno=: [increase] current line number
    #
    # Rules explanation
    #    The `rules` is a Array, which including all matching rules.
    #    Each term should include three item:
    #      * Matching Pattern
    #          Which is the what to match. The type should be a regular
    #          expression.
    #      * Executable Code Block
    #          Which is what to be executed when matched. You should return a
    #          proper Array if it is needed, otherwise, those returning nil
    #          will be continued matched.
    #      * Match State
    #          Rule will only matched when it is in the certain state.
    #
    #    The order of rules are important, as the former one will test matching
    #    first and if it matched successfully, the others will be omitted.
    #

    @rules = [
# Basic Elements
        [/\d+/,                   """ [:INTEGER, text.to_i] """,     nil ],
        [/\"([^\"]|\\[nt\"])*\"/, """ [:STRING, text[1..-2]] """,    nil ],

# Comments
        [/\*\//,          """ @state = nil """,           :COMM ],
        [/\/\*/,          """ @state = :COMM; nil """,      nil ],
        [/\n/,            """ nil """,                    :COMM ],
        [/./,             """ nil """,                    :COMM ],

# Comparisons
        [/\</,            """ [:RELATION, '<'] """,         nil ],
        [/\>/,            """ [:RELATION, '>'] """,         nil ],
        [/\=\=/,          """ [:EQUALITY, '='] """,         nil ],
        [/\!\=/,          """ [:EQUALITY, '!'] """,         nil ],

# Keywords
        [/\bif\b/,            """ [:IF, nil] """,               nil ],
        [/\belse\b/,          """ [:ELSE, nil] """,             nil ],
        [/\bwhile\b/,         """ [:WHILE, nil] """,            nil ],
        [/\bfor\b/,           """ [:FOR, nil] """,              nil ],
        [/\bdo\b/,            """ [:DO, nil] """,               nil ],
        [/\breturn\b/,        """ [:RETURN, nil] """,           nil ],
        [/\bcase\b/,          """ [:CASE, nil] """,             nil ],
        [/\bswitch\b/,        """ [:SWITCH, nil] """,           nil ],
        [/\bdefault\b/,       """ [:DEFAULT, nil] """,          nil ],
        [/\bbreak\b/,         """ [:BREAK, nil] """,            nil ],
        [/\bcontinue\b/,      """ [:CONTINUE, nil] """,         nil ],
        [/\bin\b/,            """ [:IN, nil] """,               nil ],
        [/\bstruct\b/,        """ [:STRUCT, nil] """,           nil ],
        [/\benum\b/,          """ [:ENUM, nil] """,             nil ],
        [/\blambda\b/,        """ [:LAMBDA, nil] """,           nil ],
        [/\bimport\b/,        """ [:IMPORT, nil] """,           nil ],
        [/\bNULL\b/,          """ [:NULL, nil] """,             nil ],
        [/\bstr\b/,           """ [:STR, nil] """,              nil ],
        [/\bint\b/,           """ [:INT, nil] """,              nil ],
        [/\bauto\b/,          """ [:AUTO, nil] """,             nil ],
        [/\bextern\b/,        """ [:EXTERN, nil] """,           nil ],

# Some Other Symbols
        [/\+\+/,          """ [:INCREASE, nil] """,         nil ],
        [/\-\-/,          """ [:DECREASE, nil] """,         nil ],
        [/\&\&/,          """ [:LOGAND, nil] """,           nil ],
        [/\|\|/,          """ [:LOGOR, nil] """,            nil ],
        [/\<\</,          """ [:LSHIFT, nil] """,           nil ],
        [/\>\>/,          """ [:RSHIFT, nil] """,           nil ],

# Some Other Other Symbols With Only One Character
        [/\+/,            """ [text, nil] """,              nil ],
        [/\-/,            """ [text, nil] """,              nil ],
        [/\*/,            """ [text, nil] """,              nil ],
        [/\//,            """ [text, nil] """,              nil ],
        [/\%/,            """ [text, nil] """,              nil ],
        [/\;/,            """ [text, nil] """,              nil ],
        [/\,/,            """ [text, nil] """,              nil ],
        [/\(/,            """ [text, nil] """,              nil ],
        [/\)/,            """ [text, nil] """,              nil ],
        [/\[/,            """ [text, nil] """,              nil ],
        [/\]/,            """ [text, nil] """,              nil ],
        [/\!/,            """ [text, nil] """,              nil ],
        [/\?/,            """ [text, nil] """,              nil ],
        [/\&/,            """ [text, nil] """,              nil ],
        [/\|/,            """ [text, nil] """,              nil ],
        [/\^/,            """ [text, nil] """,              nil ],
        [/\~/,            """ [text, nil] """,              nil ],
        [/\=/,            """ [text, nil] """,              nil ],
        [/\./,            """ [text, nil] """,              nil ],
        [/\{/,            """ [text, nil] """,              nil ],
        [/\}/,            """ [text, nil] """,              nil ],
        [/\:/,            """ [text, nil] """,              nil ],


# Name tokens
        [/[a-zA-Z_][0-9a-zA-Z_]*/,""" [:NAME, text] """,    nil ],

# Something other omitted
        [/\r\n|\r|\n/,            """ inc_lineno """,               nil ],
        [/\s/,                    """ nil """,                      nil ],
    ]
    @rules.freeze

    class CScriptLexError < Exception
    end

    def scan_file(file_name)
        open file_name do |f|
            scan_string(f.read)
        end
    end
    def scan_string(string)
        @scanner = StringScanner.new(string)
        @rules = CScriptScanner.rules # UGLY

        @state = nil
        @lineno = 1
    end


    attr_accessor :state
    attr_accessor :lineno

    def inc_lineno
        @lineno += 1
        @colno = @scanner.pos
        nil
    end
    def column
        return @scanner.pos - @colno
    end

    def match_and_deal
        return [false, false] if @scanner.eos?
        state_accorded = @rules.find_all {|x| x[2] == @state}
        found = state_accorded.find(nil) { |x| @scanner.match? x[0] }
#        p "#{@scanner.rest} [#{state}]"

        if !found
            raise CScriptLexError,
                "Unmatched string in #{@lineno}:#{column}.",
                caller
        end

        text = @scanner.scan(found[0])

        ret = eval(found[1], binding)

        return ret if ret.class == Array
        nil
    end

    def next_token()
        if @scanner.eos?
            return [false, false]
        end
        ret = nil
        loop do
            ret = match_and_deal
            break if ret
        end
        return ret
    end

end
    
