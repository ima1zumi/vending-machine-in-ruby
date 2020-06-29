require 'minitest/autorun'
require './lib/vending_machine'

class VendingMachineTest < Minitest::Test
  def test_step_1
    machine = VendingMachine.new
    expected = [
      {
        name: 'コーラ',
        price: 120,
        stock: 5,
      }
    ]
    assert_equal expected, machine.current_stocks
  end

  def test_step_2_在庫があるか確認する
    machine = VendingMachine.new
    assert machine.stock_available?('コーラ')
  end

  def test_step_2_Suicaで購入する
    machine = VendingMachine.new
    suica = Suica.new(120)
    drink = machine.buy('コーラ', suica)
    assert_equal 'コーラ', drink.name
    expected = [
      {
        name: 'コーラ',
        price: 120,
        stock: 4,
      }
    ]
    assert_equal expected, machine.current_stocks
    assert_equal 120, machine.sales_amount
    assert_equal 0, suica.balance
  end

  def test_step_2_チャージ残高が足りない場合
    machine = VendingMachine.new
    assert machine.stock_available?('コーラ')
    suica = Suica.new(119)
    drink = machine.buy('コーラ', suica)
    assert_nil drink
    expected = [
      {
        name: 'コーラ',
        price: 120,
        stock: 5,
      }
    ]
    assert_equal expected, machine.current_stocks
    assert_equal 0, machine.sales_amount
    assert_equal 119, suica.balance
  end

  def test_step_2_在庫が足りない場合
    machine = VendingMachine.new
    assert machine.stock_available?('コーラ')
    suica = Suica.new(10000)
    machine.buy('コーラ', suica)
    machine.buy('コーラ', suica)
    machine.buy('コーラ', suica)
    machine.buy('コーラ', suica)
    assert machine.stock_available?('コーラ')
    machine.buy('コーラ', suica)
    refute machine.stock_available?('コーラ')
    assert_nil machine.buy('コーラ', suica)
    assert_equal 9400, suica.balance
    assert_equal 600, machine.sales_amount
    assert_equal [], machine.current_stocks
  end
end
