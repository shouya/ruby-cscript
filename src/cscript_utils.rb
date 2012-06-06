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

        Kernel.send :define_method, :error_raise do |*args|
            raise RuntimeError, *args if String === args[0]
            raise *args
        end


        Kernel.send :define_method, :proc_to_lambda do |&blk|
            (tmp = Object.new).define_singleton_method(:_tmp, &blk)
            Proc.new &tmp.method(:_tmp).to_proc
        end

        Kernel.send :define_method, :generate_method do |&blk|
            BasicObject.class_eval do
                define_method :tmp_method, &blk
                m = instance_method :tmp_method
                undef_method :tmp_method
                m
            end
        end

        Kernel.send :define_method, :binding_call do |who, bind, *args, &blk|
            (cls = who.dup).singleton_class.class_eval do
                define_method :method_missing do |m, *args|
                    begin
                        return bind.eval("%s %s" % [m.to_s,
                                         args.map(&:inspect).join])
                    rescue NameError
                        super
                    end
                end
            end
            cls.instance_exec(*args, &blk)
        end


    end
end
