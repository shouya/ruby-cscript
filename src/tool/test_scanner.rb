
require_relative '../cscript_scanner'


class MyScanner
    include CScript::Scanner
end

scanner = MyScanner.new
scanner.scan_stdin

until (scanned = scanner.next_token) == [false, false]
    puts scanned.inspect
end

