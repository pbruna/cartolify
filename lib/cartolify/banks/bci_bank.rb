# encoding: utf-8

class BCIBank < Bank
	attr_accessor :user, :password, :account_number
	attr_reader :session

	URL = "https://www.bci.cl/cl/bci/aplicaciones/seguridad/autenticacion/loginPersonas.jsf"
	LOGIN_FORM_NAME = "frm"
	BROWSER = "Mac FireFox"
	START_URL = "https://www.bci.cl/cuentaswls/ControladorCuentas?opcion=CTACTECARTOLA&objeto="

	def initialize(account = {})
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
		# The balance is in the 7 table, second td
		string_balance = session.page.root.css("table")[6].css("td")[1].text
		# Remove de $ simbol and the dots
		convert_money_to_integer(string_balance)
	end

	def transactions
		transactions = []
		# We go to the transactions page
		session.get("#{START_URL}#{self.account_number}")
		# Tables that hold the transactions, we select the tr's
		table_rows = session.page.root.css("table")[10].css("tr.blanco, tr.suave")
		table_rows.each do |row|
			values = row.css("td").map { |td| clean_string(td) }
			total = values[3].size > 0 ? values[3] : values[4]

			transaccion_info = {
				:date => Date.parse(values[0]),
				:description => values[1],
				:serial => values[2],
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

		form["frm"]="frm"
    	form["frm:canal"]="110"
    	form["frm:clave"]= self.password
	    form["frm:clave_aux"]=""
	    form["frm:dvCliente"] = self.user[-1] #digito verificador rut
    	form["frm:grupo"] = ""
    	form["frm:j_idt12"] ="Ingresar"
    	# Rut only numbers without verification
    	form["frm:rutCliente"]= self.user[0..-2].gsub(/[\--.]/,'')
    	form["frm:rut_aux"] = ""
    	form["frm:servicioInicial"]="SuperCartola"
    	form["frm:touch"] = "#{(Time.now.to_f*1000).to_i}"
    	form["frm:transaccion"] = ""
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