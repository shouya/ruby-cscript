/* This program is intended to try the loop features:
    * next
    * break
    * redo
*/

/* test of redo & break */
b = 3;
a = 1;
while (a = a + 1)  { /* a: 1 + 1 => 2 */
    if (b = b - 1) { /* b: 2 -> 1 -> 0 (reject) */
        a = a + b; /* a: +2 -> +1 => 5 */
        % "now redo\n"; /* print this twice */
        redo;
    }
    % "now break\n"; /* and print this once */
    break;
}

% a; /* should output 5  */


a = 11;
while (a = a - 3) {
    if (a = a - 1) {
        % a;
        % "now next\n";
        next;
    }
    % "break\n";
    break; /* won't be triggered */
}

/* known problem, the loop control will fall through function calls,
   how to curb this?
   */

