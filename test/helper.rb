require 'rubygems'
require 'bundler'
require	'turn'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'lib/cartolify',
 'lib/cartolify/banks'))
require 'cartolify'

class Test::Unit::TestCase

	def bank_account
		account = {
			:user => ENV['bank_user'],
			:password => ENV['bank_password'],
			:number => ENV['bank_account_number']
		}
	end

end
