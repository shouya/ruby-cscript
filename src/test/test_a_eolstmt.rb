
require_relative 'common'

# Testing EOL as statememt end (';')

more_simple_test [1, 2, 3, 4]

__END__

a = 1
b = 2
c = 3; d = 4

EMIT a
EMIT b
EMIT c
EMIT d

EMIT -> { "hello" }()


