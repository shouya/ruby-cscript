/* testing variables definition and use */


a = 3; /* global */

b = 4; /* global */

if (c = 2 /* local */ ) { 
    % -1;  /* just print stack */
    % a + b + c + 1; /* print: 10 */
}

/* % c; /* cannot print c here */

% a + b; /* should print: 7 */

% c;     /* crash here */


