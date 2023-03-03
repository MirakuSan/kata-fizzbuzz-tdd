<?php
 
namespace App;

class FizzBuzz
{
	public function convert(int $number): string
	{
        $string = 'Error';

        if ($number % 3 == 0 && $number % 5 == 0) {
            $string = "FizzBuzz";
        } elseif ($number % 3 == 0) {
            $string = "Fizz";
        } elseif ($number % 5 == 0) {
            $string = "Buzz";
        }

        return $string;
	}
}
