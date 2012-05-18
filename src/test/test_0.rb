
require_relative './common'

class TheTest < Test::Unit::TestCase
    def test_emit
        assert_emissions('EMIT 1;', 1)
    end
    def test_plus
        assert_emissions('EMIT 1+1;', 2)
    end
end




