# program class for cscript project
#
# shou, 24 May, 2012
#

require 'json'
require_relative 'cscript'

module CScript
    class Program
        attr_accessor :meta_info, :program_tree
        attr_accessor :dispatcher

        if $CS_DEBUG
            attr_accessor :emissions
        end

        def load_json(json_str)
            load_program(JSON.load(json_str))
        end
        def load_program(program_tree)
            assert_error 'Not a valid program tree' do
                program_tree['nodetype'] == tree
            end

            @meta_info = program_tree['meta_info']
            @program_tree = program_tree
        end
        def run
            @dispatcher = Dispatcher.new
            @dispatcher.run(@program_tree)
        end
    end
end
