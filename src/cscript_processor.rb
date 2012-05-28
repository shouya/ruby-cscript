# Macro processor class for cscript project
#
# Shou Ya, morning 27 May, 2012
#

require_relative 'cscript'

module CScript
    class Processor
        class << self
            attr_reader :table
            def handle(name, &block)
                (@table ||= {}).store(name.to_s, block)
            end
        end

        def dispatch(callerx, tree)
            type = tree['type']
            assert_error 'No handler matched %s.' % type do
                self.class.table.has_key? type
            end

            self.instance_exec(callerx, tree, &self.class.table[type])

        end
        alias_method :process, :dispatch


        handle :DEBUG_EMIT do |c, t|
            (c.runtime.program.emissions ||= []) << \
                c.evaluate(t['operands'][0]).value
        end

    end
end


