# debugging test program, for testing executor
#


require_relative 'cscript_executor'
require_relative 'cscript_parser'


parser = CScriptParser.new
parser.scan_string($stdin.read)

tree = parser.do_parse

tree.print
puts "=== message above is syntax tree ==="

executor = CScriptExecutor.new(tree)
executor.execute

puts "=== these above is program output ==="


