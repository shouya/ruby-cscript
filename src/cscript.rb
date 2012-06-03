

$CS_VERSION = '1.0'

require_relative 'cscript_utils'

module CScript
    $LOAD_PATH << File.dirname(__FILE__)

    class CScriptError <Exception; end
    class CScriptControl <Exception; end

    # Parser Part
    autoload :Preprocessor, 'cscript_cpp'
    autoload :SyntaxTree, 'cscript_syntax_tree'
    autoload :Parser, 'cscript_parser'
    autoload :Scanner, 'cscript_scanner'

    # Executor Part
    autoload :Program, 'cscript_program'
    autoload :Runtime, 'cscript_runtime'
    autoload :RuntimeError, 'cscript_runtime'
    autoload :RunStack, 'cscript_runstack'
    autoload :Evaluator, 'cscript_evaluator'
    autoload :Executor, 'cscript_executor'
    autoload :Value, 'cscript_value'
    autoload :Function, 'cscript_function'
    autoload :SymbolTable, 'cscript_symbol_table'
    autoload :Processor, 'cscript_processor'
    autoload :CallStack, 'cscript_callstack'

end

