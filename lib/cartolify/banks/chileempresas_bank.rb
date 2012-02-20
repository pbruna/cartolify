class CHILEEMPRESASBank < Bank
	attr_accessor :user, :password, :account_number, :company_rut
	attr_reader :session

	URL = "https://www.empresas.bancochile.cl/cgi-bin/navega?pagina=enlinea/login_fus"
	LOGIN_FORM_NAME = "theform"
	BROWSER = "Mac FireFox"
	START_URL = "https://www.empresas.bancochile.cl/cgi-bin/cart_mn?consulta=Cart_Instantanea_MN&lst_cta=CTD&cta_cte="

	def initialize(account = {})
		@company_rut = account[:company_rut]
		@user = account[:user]
		@password = account[:password]
		@account_number = account[:number]
		@session = new_session
	end

	def url
		URL
	end

	def balance
		# We make sure we are on the first page
		session.get("#{START_URL}#{self.account_number}")
		# The value is inside a div#saldos in the second td
		string_balance = clean_string(session.page.root.css("#saldos").css("td")[1])
		# The above result has an ":" character that we need to remove
		string_balance.gsub!(/:/,'')
		# Remove de $ simbol and the dots
		convert_money_to_integer(string_balance)
	end

	def transactions
		transactions = []
		# We go to the transactions page
		session.get("#{START_URL}#{self.account_number}")
		# Tables that hold the transactions, we select the tr's. We remove the header tr
		session.page.root.css("table")[5].css("table")[4].css("tr")[0].remove
		table_rows = session.page.root.css("table")[5].css("table")[4].css("tr")

		table_rows.each do |row|
			values = row.css("td").map { |td| clean_string(td) }
			# the 4th value is a charge, the 5th is an income
			total = values[4].size > 0 ? "-#{values[4]}" : values[5]

			transaccion_info = {
				:date => Date.parse("#{values[0]}/#{Date.today.year}"),
				:description => values[1],
				:serial => values[3],
				:total => convert_money_to_integer(total)
			}
			transactions << Transaction.new(transaccion_info)
		end
		transactions
	end

	def new_session
		agent = Mechanize.new
		agent.user_agent_alias=BROWSER
		agent.get(URL)
		form = agent.page.form(LOGIN_FORM_NAME)

		form["rut_emp"] = self.company_rut[0..-2].gsub(/[\--.]/,'')
		form["dv_emp"] = self.company_rut[-1]
		form["rut_apo"] = self.user[0..-2].gsub(/[\--.]/,'')
		form["dv_apo"] =  self.user[-1]
		form["pin"] = self.password

		form.submit
		agent
	end

	private
	def clean_string(html_object)
		# We have to remove the special &nbsp character, which is not a \s+
		nbsp = Nokogiri::HTML("&nbsp;").text
		# This is the text of the html element
		text_of_html_el = html_object.children.text
		text_of_html_el.strip.gsub(nbsp,'').gsub(/\n/,'')
	end

	def convert_money_to_integer(money)
		int = money.gsub(/[\$.]/,'').gsub(/\s+/,'')
		int.to_i
	end

end