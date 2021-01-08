defmodule NumeralArchive.MathTest do
  use ExUnit.Case

  describe "mean/2" do
    test "when sum is nil" do
      assert nil == NumeralArchive.Math.mean(nil, 0)
    end

    test "when count is nil" do
      assert nil == NumeralArchive.Math.mean(500, nil)
    end

    test "when count is 0" do
      assert nil == NumeralArchive.Math.mean(500, 0)
    end

    test "when two numbers are provided" do
      assert 250 == NumeralArchive.Math.mean(500, 2)
    end
  end

  describe "mean/1" do
    test "an array of numbers" do
      assert 57.5 == NumeralArchive.Math.mean([20, 50, 70, 90])
    end

    test "an array of numbers with nil points" do
      assert 57.5 == NumeralArchive.Math.mean([20, nil, 50, 70, nil, 90, nil, nil])
    end
  end
end
