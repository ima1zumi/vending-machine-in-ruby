# frozen_string_literal: true

require './lib/drink'

class VendingMachine
  attr_reader :sales_amount, :purchase_histories

  def initialize
    @sales_amount = 0
    @stocks = {}
    @purchase_histories = []
    create_stock(Drink.cola, 5)
    create_stock(Drink.redbull, 5)
    create_stock(Drink.water, 5)
  end

  def current_stocks
    @stocks.map do |name, drinks|
      drink = drinks.first
      next if drink.nil?
      {name: drink.name, price: drink.price, stock: drinks.count}
    end.compact
  end

  def stock_available?(name)
    @stocks[name].size > 0
  end

  def purchase(name, suica)
    return nil unless stock_available?(name)
    price = @stocks[name][0].price
    return nil if suica.balance < price
    drink = @stocks[name].shift
    @sales_amount += drink.price
    suica.withdraw(drink.price)
    save_purchase_history(drink, suica)
    drink
  end

  def stock_available_lists
    @stocks.keys
  end

  def find_purchase_histories(name)
    @purchase_histories.select { _1[:name] == name }
  end

  private
    def create_stock(drink, stock)
      stock.times do
        unless @stocks[drink.name]
          @stocks[drink.name] = []
        end
        @stocks[drink.name] << drink
      end
    end

    def save_purchase_history(drink, suica)
      @purchase_histories << {name: drink.name, time: Time.now, user_age: suica.user_age, user_sex: suica.user_sex}
    end
end
