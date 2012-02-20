# encoding: utf-8

class BCIMobiBank < Bank
	attr_accessor :user, :password
	attr_reader :session

	URL = "https://bci.mobi"
	LOGIN_FORM_NAME = "loginform"
	BROWSER = "Mac FireFox"
	START_URL = "https://bci.mobi/supercartola.do"

	def initialize(account = {})
		@user = account[:user]
		@password = account[:password]
		@session = new_session
	end

	def url
		URL
	end

	def balance
		# We make sure we are on the first page
		session.get(START_URL)
		# The balance is in the 5 table, second tr, second td inside a div
		string_balance = session.page.root.css("table")[4].css("tr")[1].css("td")[1].children.text
		# Remove de $ simbol and the dots
		string_balance.gsub!(/[\$-.]/,'')
		# Return Integer
		string_balance.to_i
	end

	def get_transactions
		transactions = []
		# We go to the transactions page
		session.get(START_URL)
		# Go to transaction pages
		# 4 link, the first that reads "Más"
		session.page.links[3].click
		# Tables that hold the transactions, 3 tables per page
		tables = session.page.root.css("table")[5].css("tr")[1].css("td").css("table")
		tables.each do |table|
			h = {
				:date => table.css("tr")[0].css("td")[1].text,
				:description => table.css("tr")[1].css("td")[1].text,
				:serial => table.css("tr")[2].css("td")[1].text,
				:total => table.css("tr")[3].css("td")[1].text
			}
			transactions << h
		end
		transactions
	end

	def new_session
		agent = Mechanize.new
		agent.user_agent_alias=BROWSER
		agent.get(URL)
		form = agent.page.form(LOGIN_FORM_NAME)
		form.rut = self.user
		form.clave = self.password
		form.canal = "901"
		form.menu_opcion="targetSupercartola"
		form.submit
		agent
		if agent.page.root.css("table").first.css("h1").text.eql?("Autentificación Inválida")
		 	false
		elsif agent.page.root.css("table").first.css("h1").text.eql?("Clave bloqueada")
			false
		elsif agent.page.root.css("table").first.css("h1").text.eql?("Error desconocido.")
			false
		else
		 agent
		end
	end

	private

end