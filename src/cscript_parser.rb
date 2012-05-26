# parser (yacc mixin) module of cscript
#
# Shou Ya   11 Apr, 2012
#

# run `racc -E -v -ocscript_yacc.rb cscript_yacc.y' to generate this file

require_relative 'cscript_yacc'
require_relative 'cscript'

$CS_PARSER_VERSION = '1.0'

module CScript
    Parser.class_eval do
        include Scanner
        # include SyntaxTree
        include SyntaxTree.Shortcut {|node| node.place = where? }

        alias_method :do_parse_without_building_tree, :do_parse
        def do_parse
            tree = SyntaxTree::Tree.new(
                do_parse_without_building_tree, {
                    :language => 'cscript',
                    :version => $CS_VERSION,
                    :filename => file,
                    :parser => {
                        :name => 'sci', # Shou ya's Cscript Implement
                        :version => $CS_PARSER_VERSION,
                        :options => []
                    },
                    :optimizer => nil,
                    :parse_date => Time.now()
                })
            return tree
        end
    end
end




