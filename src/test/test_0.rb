
require_relative './common'

simple_test [1] do
    'EMIT 1;'
end

simple_test [1, 2] do
    'EMIT 1; EMIT 2;'
end





