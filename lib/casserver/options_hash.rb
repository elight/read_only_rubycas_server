require "active_support"
require "active_record"
class OptionsHash < HashWithIndifferentAccess
	
	class EnvironmentMissing < Exception
	end	
	
	attr_accessor :environment
	
	def load_config file
		load file do |file|
			merge! HashWithIndifferentAccess.new(YAML.load file )[@environment]
		end
	end
	
	def load_database_config file
		load file do |file|
			self[:database] = HashWithIndifferentAccess.new(YAML.load file )[@environment]
		end
	end
	
	def inherit_authenticator_database!
		if self[:authenticator][:database] == "inherit"
			self[:authenticator][:database] = self[:database]
		end
	end
	
	
	protected
	
	def load file
		raise EnvironmentMissing if @environment.nil?
		
		case file
		when File
			# do nothing..
		when String
			file = File.open file
		else
			raise ArgumentError
		end
		yield file
	end
end
