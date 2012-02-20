require 'helper'

class TestBank < Test::Unit::TestCase

  def setup
  	@bank = Bank.new("BCI", bank_account)
  end

  def test_new_bank_should_return_an_specfic_bank_Class_Instance
  	assert_equal(BCIBank, @bank.branch.class)
  end

  def test_url_should_return_and_https_url
  	assert_equal("https", URI(@bank.url).scheme)
  end

  def test_should_get_a_session
	session = @bank.session
	assert(session)
  end

  def test_balance_should_return_a_number
  	balance = @bank.balance
	  assert_equal(Fixnum, balance.class)
  end

  def test_transactions_should_return_an_array
    transactions = @bank.transactions
    assert_equal(Array, transactions.class)
  end


end
