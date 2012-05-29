class Transaction
	attr_reader :total, :date, :description, :type, :saldo

	def initialize(hash)
		@total = hash[:total]
		@date = hash[:date]
		@description = clean_utf(hash[:description])
		@saldo = hash[:saldo]
	end

	def income?
		total > 0
	end

	def outcome?
		total < 0
	end
	
	private
	def clean_utf(string)
	 string.encode('UTF-16', 'UTF-8', :invalid => :replace, :replace => '').encode!('UTF-8','UTF-16')
	end

end