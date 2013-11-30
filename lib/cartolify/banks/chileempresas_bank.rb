class CHILEEMPRESASBank < Bank
  attr_accessor :user, :password, :account_number, :company_rut
  attr_reader :session

  HOST = "www.empresas.bancochile.cl"
  URL = "https://#{HOST}/cgi-bin/navega?pagina=enlinea/login_fus"
  LOGIN_FORM_NAME = "theform"
  BROWSER = "Mac FireFox"
  START_URL = "https://www.empresas.bancochile.cl/CCOLSaldoMovimientosWEB/selectorCuentas.do?accion=initSelectorCuentas&moneda=CTD&cuenta="
  FONDOS_MUTUO_URL = "https://www.empresas.bancochile.cl/cgi-bin/cgiinvbanch"

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
    string_balance = clean_string(session.page.root.css("#estaCuen").css(".detalleSaldosMov").css("td")[1])
    # The above result has an ":" character that we need to remove
    string_balance.gsub!(/:/,'')
    # Remove de $ simbol and the dots
    convert_money_to_integer(string_balance)
  end

  def transactions
    transactions = []
    total = 0
    movements = get_transactions_json
    movements.each do |mov|
      
      if mov[4].empty? # Out money
        total = convert_money_to_integer(mov[5])
      else
        total = convert_money_to_integer(mov[4]) * -1 
      end
      
      saldo = convert_money_to_integer(mov[6])
      
      transaccion_info = {
				:date => Date.parse(mov[0]),
				:description => mov[1],
				:total => total,
				:saldo => saldo
			}
			transactions << Transaction.new(transaccion_info)
    end
    transactions
  end
  
  def balance_fondos_mutuos
    session.get(FONDOS_MUTUO_URL)
    string_balance = session.page.root.css("table")[4].css("tr")[2].css("td").last.text.lstrip
    convert_money_to_integer(string_balance)
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
    
    def get_transactions_json
      self.balance
      cookie = session.cookies.join("; ")
      path = "/CCOLSaldoMovimientosWEB/generadorMovimientosJSON.do"
      params = {
        "sEcho"=> "4",
        "iColumns" => "7",
        "iDisplayStart" => "0",
        "iDisplayLength" => "100"
      }
      http = Net::HTTP.new(HOST, 443)
      http.use_ssl = true
      request = Net::HTTP::Post.new(path)
      request.set_form_data(params)
      request.add_field("X-Requested-With", "XMLHttpRequest")
      request.add_field('Cookie', cookie)
      response = http.request(request)
      json = JSON.parse(response.body)
      clean_json(json["aaData"])
    end
    
    def clean_json(json)
      json.each do |arr|
        [4, 5, 6].each do |el|
          arr[el] = Nokogiri::HTML::parse(arr[el]).text # remove <p> tags
        end
      end
      json
    end

end
