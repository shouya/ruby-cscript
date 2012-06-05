# C Preprocessor Shell of cscript project
#
# Shou Ya, Evening, 30 May, 2012
#
#
require 'cscript'


module CScript
    class Preprocessor
        class << self
            attr_reader :handler_table
            def handle(regexp, &block)
                @handler_table ||= []

                Object.send(:define_method, :tmp_method, &block)
                method = Object.instance_method(:tmp_method)
                Object.send(:remove_method, :tmp_method)

                @handler_table.push([regexp, method])
            end
        end

        attr_reader :parser
        attr_accessor :cpp, :options
        def initialize(parser, extern_program = 'cpp', options = '')
            @parser = parser
            @cpp = extern_program
            @options = Array == options ? options : options.split(/\s+/)
        end

        def extern_preprocess(code)
            IO.popen([@cpp, *@options], 'r+') do |io|
                io.write(code)
                io.close_write
                io.read
            end
        end

        def preprocess(scanner)
            dispatch(scanner)
        end

        def dispatch(scanner)
            behavior = nil
            self.class.handler_table.each do |(regexp, method)|
                if scanner.match?(regexp)
                    scanned = scanner.scan(regexp)
                    behavior = method.bind(self) \
                        .call(regexp.match(scanned))
                    break
                end
            end
            return behavior || :PASS
        end

        handle %r{\#\s*import\s*\"(.*)\"} do |m|# Importing(local-path)
            return [:IMPORT_LOC, m[1]]
        end
        handle %r{\#\s*import\s*\<(.*)\>} do |m|# Importing(system-path)
            return [:IMPORT_SYS, m[1]] # TODO: not handled in executor
        end
        handle %r{\#\s+(\d+)\s+\"(.*)\".*} do |m| # File/line mark
            @parser.instance_eval do
                @lineno = m[1].to_i - 1
                @colno = 0 # TODO: a valid value
            end
            # * $2 # The filename, ('<stdin>', '<command-line>' expected)
                   # The second one could be omitted
            return :DROP
        end
        handle %r{\#\s*file\s*auto} do |m|
            @parser.instance_eval do
                @file = $0
            end
        end
        handle %r{\#\s*file\s*\"(.*)\"} do |m|
            @parser.instance_eval do
                @file = m[1]
            end
        end
        handle %r{\#.*} do |*| # Regard as a comment
            return :DROP
        end

    end
end

