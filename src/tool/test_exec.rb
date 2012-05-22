# debugging test program, for testing executor
#

$CS_DEBUG = true

require_relative '../cscript_runtime'
require_relative '../cscript_parser'
require_relative '../cscript_syntax_tree'


parser = CScriptParser.new
parser.scan_stdin

tree = parser.do_parse

puts tree.to_json
puts "=== message above is syntax tree ==="

CScriptRuntime.execute(tree)

puts "=== these above is program output ==="


