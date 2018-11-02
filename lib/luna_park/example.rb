# frozen_string_literal: true

require_relative 'extensions/comparsionable'
require_relative 'extensions/comparsionable_debug'
require_relative 'entity'

require 'pry'

# # # # # #
# Example #
# # # # # #

class Money
  include LunaPark::Extensions::Comparsionable
  include LunaPark::Extensions::ComparsionableDebug

  attr_accessor :amount, :fractional, :currency

  def self.wrap(input)
    case input
    when self then input
    when Hash then new(**input)
    end
  end

  def self.wrap_usd(input)
    case input
    when self then input
    when Hash then new(input.merge(currency: 'USD'))
    end
  end

  def initialize(hash)
    @currency   = hash[:currency]
    @amount     = hash[:amount]      || (hash[:fractional] && (hash[:fractional] * 100.0))
    @fractional = (hash[:fractional] || (hash[:amount] / 100.0))&.floor
  end

  def ==(other)
    currency == other&.currency && amount == other&.amount && fractional == other&.fractional
  end

  def inspect
    to_s
  end

  def to_s
    "<Money: @amount=#{@amount}, @currency=#{@currency}>"
  end

  def to_h
    { amount: amount, currency: currency }
  end

  private

  def comparsion_attributes
    %i[currency amount fractional]
  end
end

class Foo < LunaPark::Entity
  include LunaPark::Extensions::ComparsionableDebug

  namespace :from do
    attr :account, Money, :wrap
    attr :charge,  Money, :wrap
    attr :usd,     Money, :wrap_usd

    namespace :foo do
      attr :bar
    end
  end

  namespace :to do
    attr :account, Money, :wrap
    attr :charge,  Money, :wrap
    attr :usd,     Money, :wrap_usd
  end

  namespace :commission do
    attr :charge, Money, :wrap
    attr :usd, Money, :wrap_usd
  end

  attr :created_at, comparsion: false

  def foo
    @foo ||= 'foo'
  end

  def to_h
    super.tap { |h| h.delete(:foo) }
  end
end

foo = Foo.new(
  from: {
    charge: { currency: 'USD', amount: 42 },
    usd:    { amount: 41 },
    foo: { bar: 1 }
  },
  commission: {
    charge: { currency: 'USD', amount: 42 },
    usd:    { amount: 41 }
  },
  created_at: Time.now.utc
)

bar = Foo.new(
  from: {
    charge: { currency: 'USD', amount: 42 },
    usd:  { amount: 42 }
  },
  commission: {
    charge: { currency: 'USD', amount: 42 },
    usd:  { amount: 42 }
  },
  created_at: Time.now.utc
)

baz = Foo.new(
  from: {
    charge: { currency: 'USD', amount: 43 },
    usd:    { amount: 44 }
  },
  commission: {
    charge: { currency: 'USD', amount: 42 },
    usd:    { amount: 42 }
  },
  created_at: Time.now.utc
)

puts
p foo         # => #<Foo from=#< charge=<Money: @amount=42, @currency=USD> usd=<Money: @amount=42, @currency=>> commission=<Money: @amount=42, @currency=USD> created_at=2018-10-26 16:22:00 UTC>
puts
puts foo.to_h # => {:from=>{:charge=>{:amount=>42, :currency=>"USD"}, :usd=>{:amount=>42, :currency=>nil}}, :commission=>{:amount=>42, :currency=>"USD"}, :created_at=>2018-10-26 16:22:00 UTC}
puts
pp foo.differences_structure bar
puts
pp foo.differences_structure baz

params = {
  from: {
    charge: { currency: 'USD', amount: 43 }
  },
  commission: {
    charge: { currency: 'USD', amount: 42 }
  },
  created_at: Time.now.utc
}

p Foo.new(params).to_h == params

p foo
