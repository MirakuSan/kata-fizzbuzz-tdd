<?php

use App\FizzBuzz;
use PHPUnit\Framework\TestCase;

class FizzBuzzTest extends TestCase
{
    public function testReturnsNumberAsString(): void
    {
        $fizzBuzz = new FizzBuzz();
        $result = $fizzBuzz->convert(1);
        $this->assertEquals('Error', $result);
    }

    public function testReturnsFizzForMultiplesOfThree(): void
    {
        $fizzBuzz = new FizzBuzz();
        $result = $fizzBuzz->convert(3);
        $this->assertEquals('Fizz', $result);
    }

    public function testReturnsBuzzForMultiplesOfFive(): void
    {
        $fizzBuzz = new FizzBuzz();
        $result = $fizzBuzz->convert(5);
        $this->assertEquals('Buzz', $result);
    }

    public function testReturnsFizzBuzzForMultiplesOfBothThreeAndFive(): void
    {
        $fizzBuzz = new FizzBuzz();
        $result = $fizzBuzz->convert(15);
        $this->assertEquals('FizzBuzz', $result);
    }
}

