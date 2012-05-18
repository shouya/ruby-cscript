
require_relative './common'

simple_test 2 do
    'EMIT (4+2)/3; /* output 2 */'
end

simple_test 1 do
    'EMIT (4-2)/2;'
end
