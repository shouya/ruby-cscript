
def func(a, b) {
    return a + b;
    % "WTF\n";  /* won't print this */
}

def func_prn(a, b) {
    % func(a, b);
    "hello\n"; /* if not returns explicitly, it will return the last value */
}


% func(1, func(2, 3)); /* will print:
    6
*/
% func_prn(1, 1); /* will print:
    2
    hello
*/

def no_arg()
{
   "just with a empty arg list\n";
}
% no_arg();

/* redefining */
def sum(a) {
    if (a) {
        a + sum(a - 1);
    } else {
        0;
    }
}
% sum(10);

def deep(a) {
    if (a) {
        deep(a - 1);
    } else {
        % b; /* crash: for stack printing */
    }
}

deep(10);

/*
Correct output(totally) << HERE
6
2
hello
just with a empty arg list
55
if: <stdin>:36:12: Variable `b' not found! (CScriptRuntimeError)
	from func_call: <stdin>:35:5
	from [deep (a: 0) at <stdin>:34:20]
	from if: <stdin>:34:20
	from func_call: <stdin>:35:5
	from [deep (a: 1) at <stdin>:34:20]
	from if: <stdin>:34:20
	from func_call: <stdin>:35:5
	from [deep (a: 2) at <stdin>:34:20]
	from if: <stdin>:34:20
	from func_call: <stdin>:35:5
	from [deep (a: 3) at <stdin>:34:20]
	from if: <stdin>:34:20
	from func_call: <stdin>:35:5
	from [deep (a: 4) at <stdin>:34:20]
	from if: <stdin>:34:20
	from func_call: <stdin>:35:5
	from [deep (a: 5) at <stdin>:34:20]
	from if: <stdin>:34:20
	from func_call: <stdin>:35:5
	from [deep (a: 6) at <stdin>:34:20]
	from if: <stdin>:34:20
	from func_call: <stdin>:35:5
	from [deep (a: 7) at <stdin>:34:20]
	from if: <stdin>:34:20
	from func_call: <stdin>:35:5
	from [deep (a: 8) at <stdin>:34:20]
	from if: <stdin>:34:20
	from func_call: <stdin>:35:5
	from [deep (a: 9) at <stdin>:34:20]
	from if: <stdin>:34:20
	from func_call: <stdin>:35:5
	from [deep (a: 10) at <stdin>:40:9]
	from root: <stdin>:40:9
HERE
*/

