

$CS_VERSION = '1.0'

module CScript
    $LOAD_PATH << Dir.pwd

    class CScriptError <Exception; end
    class CScriptControl <Exception; end

    # Parser Part
    autoload :SyntaxTree, 'cscript_syntax_tree'
    autoload :Parser, 'cscript_parser'
    autoload :Scanner, 'cscript_scanner'

    # Executor Part
    autoload :Program, 'cscript_program'
    autoload :Runtime, 'cscript_runtime'
    autoload :RuntimeError, 'cscript_runtime'
    autoload :Dispatcher, 'cscript_dispatcher'
end

