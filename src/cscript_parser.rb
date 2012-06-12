# parser (yacc mixin) module of cscript
#
# Shou Ya   11 Apr, 2012
#

# run `racc -E -v -ocscript_yacc.rb cscript_yacc.y' to generate this file

require_relative 'cscript'

$CS_PARSER_VERSION = '1.0'

module CScript
    class Yacc
        public :do_parse
    end
    class Parser
        attr_accessor :scanner, :yacc, :preprocessor
        attr_accessor :options # temporarily useless

        def initialize(options = {})
            @preprocessor = Preprocessor.new(self)
            scanner = @scanner = Scanner.new(self)
            @yacc = Yacc.new

            @yacc.define_singleton_method :next_token do
                scanner.next_token
            end
            @yacc.define_singleton_method :set_state do |*args|
                scanner.set_state(*args)
            end
            @yacc.define_singleton_method :on_error do |id, val, vstack|
                _, lineno, column = scanner.location
                lineno -= 1
                lines = scanner.string.lines \
                    .to_a[(lineno-1) .. (lineno+1)]

                puts ' CONTEXT '.center(70, "=")
                puts lines[0]
                puts lines[1]
                print '^'.rjust(column, '-')
                puts ''.ljust(lines[1].length - column - 2, '-')
                puts lines[2]
                puts ' END_OF_CONTEXT '.center(70, "=")

                puts "Syntax error at #{scanner.location.join(':')}, " \
                    "token #{token_to_str(id)} value #{val.inspect}"
                raise "Parse error!"
            end
            @yacc.instance_variable_set :@yydebug, true if $CS_DEBUG > 4

            @yacc.singleton_class.class_eval do
                include SyntaxTree.Shortcut do |node|
                    node.place = scanner.location
                end
            end

            @options = options
        end

        def preprocess
            return @preprocessor.preprocess
        end

        def scan_file(*args)
            return @scanner.scan_file(*args)
        end
        def scan_string(*args)
            return @scanner.scan_string(*args)
        end
        def scan_stdin(*args)
            return @scanner.scan_stdin(*args)
        end

        def do_parse(*args)
            tree = SyntaxTree::Tree.new(
                @yacc.do_parse, {
                :language => 'cscript',
                :version => $CS_VERSION,
                :filename => @scanner.instance_variable_get(:@filename),
                :directory => Dir.getwd,
                :parser => {
                    :name => 'SCI', # Shou ya's Cscript Implement
                    :version => $CS_PARSER_VERSION,
                    :options => @options
                },
                :optimizer => nil,
                :parse_date => Time.now()
            })
        end

        class << self       # Convenient methods
            def parse_file(file)
                parser = self.new
                parser.scan_file(file)
                parser.do_parse.to_json
            end
            def parse_string(string)
                parser = self.new
                parser.scan_string(string)
                parser.do_parse.to_json
            end
        end

    end
end




