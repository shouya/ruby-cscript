# debugging test program, for testing executor
#

$CS_DEBUG = true

require_relative '../cscript_runtime'
require_relative '../cscript_parser'
require_relative '../cscript_syntax_tree'


parser = CScript::Parser.new
parser.scan_stdin

tree = parser.do_parse

json = tree.to_json
#puts tree.to_json
#p tree.tree_hash


prog = CScript::Program.new
prog.load_json(json)
prog.run




