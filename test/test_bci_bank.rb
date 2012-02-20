# encoding: utf-8
require 'helper'
require 'cartolify/banks/bci_bank'

class TestBCIBank < Test::Unit::TestCase

	def setup
		@bank = BCIBank.new( bank_account )
	end

	def test_user_should_not_be_nil
		assert_not_nil(@bank.user)
	end

	def test_password_should_not_be_nil
		assert_not_nil(@bank.password)
	end

	# Comment for now because it may block the account
	# def test_wrong_login_should_be_false
	# 	bank = BCIBank.new({:user => "13.834.853-9", :password => "mdoad"})
	# 	session = bank.login
	# 	assert(!session, "Should be False")
	# end

	def test_should_get_a_session
		session = @bank.session
		assert(session)
	end

	def test_balance_should_return_an_Fixnum
		balance = @bank.balance
		assert_equal(Fixnum, balance.class)
	end

end