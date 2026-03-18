# frozen_string_literal: true

require_relative '../lib/calculator'

RSpec.describe Calculator do
  let(:calculator) { Calculator.new }

  describe "#power" do
    it "calculates power correctly" do
      expect(calculator.power(2, 3)).to eq(8)
      expect(calculator.power(5, 2)).to eq(25)
      expect(calculator.power(10, 0)).to eq(1)
    end
  end

  describe "#square" do
    it "calculates square correctly" do
      expect(calculator.square(4)).to eq(16)
      expect(calculator.square(7)).to eq(49)
    end
  end

  describe "#cube" do
    it "calculates cube correctly" do
      expect(calculator.cube(3)).to eq(27)
      expect(calculator.cube(2)).to eq(8)
    end
  end

  describe "#absolute" do
    it "returns absolute value" do
      expect(calculator.absolute(-5)).to eq(5)
      expect(calculator.absolute(10)).to eq(10)
      expect(calculator.absolute(0)).to eq(0)
    end
  end
end
