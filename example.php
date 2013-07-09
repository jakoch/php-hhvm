<?php
/**
 * Let's throw some random PHP features at HHVM's static analyzer for testing purposes.
 */

/**
 * Global Vars are not forbidden, but BAD!
 */
$global_variable_a = 'Hello';
echo $global_variable_a . ' Static Analyzer!';;

/**
 * Dynamic Variable Access
 */
$$global_variable_a = ' World!'; // takes the value of $global_variable_a and uses it as the new variable name (= new var $Hello)

// all outputs are the same: "Hello World!"
echo "$a ${$a}";
echo "$a $Hello";
echo "$a $hello"; // variable names are not case sensitve

?>