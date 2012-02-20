class Bank 
	attr_reader :branch

	def initialize(bank_class, bank_account)
		require "cartolify/banks/#{bank_class.downcase}_bank"
		@branch = Object.const_get("#{bank_class.upcase}Bank").new(bank_account)
	end

	def url
		@branch.url
	end

	def balance
		@branch.balance
	end

	def session
		@branch.session
	end

	def transactions
		@branch.transactions
	end


end