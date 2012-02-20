class Transaction
	attr_reader :total, :date, :description, :type

	def initialize(hash)
		@total = hash[:total]
		@date = hash[:date]
		@description = hash[:description]
	end

	def income?
		total > 0
	end

	def outcome?
		total < 0
	end

end