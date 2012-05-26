# Utilities lib for cscript project
#
# Shou, 24 May, 2012


module CScript
    module Utilities
        def debug(debug_level = 2)
            return unless $CS_DEBUG
            if $CS_DEBUG.is_a? TrueClass
                yield
            elsif $CS_DEBUG.is_a? Integer
                yield if debug_level <= $CS_DEBUG
            end
        end
        def assert_warn(warning_message, file=__FILE__, line=__LINE__)
            warn "#{warning_message} at #{file}:#{line}" \
                if (!yield and $CS_DEBUG)
        end

        Kernel.send :define_method, :assert_error do |exception, &blk|
            return if blk.call
            if String === exception then
                raise CScriptError, exception, caller[0..-2]
            elsif exception.is_a? CScriptError
                raise exception, '', caller[0..-2]
            else
                assert_error "Unknown exception type(#{exception})" do
                    nil # must fail and the exception and be raised
                end
            end
        end


    end
end
