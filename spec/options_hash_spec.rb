# encoding: UTF-8
require File.dirname(__FILE__) + '/spec_helper'
# Hmmm.. Should I need to do this?
require 'casserver/options_hash'

describe OptionsHash do

	describe "creation" do
		it "should not raise" do
			lambda {OptionsHash.new}.should_not raise_error
		end
	end
	
	describe "environment method" do
		before :each do
			@options = OptionsHash.new
		end
		it "should store an environment attribute" do
			@options.environment = :development
			@options.environment.should == :development
		end
	end
	
	describe "load_config method," do
		before :each do
			@options = OptionsHash.new
		end
		it "should raise when it doesn't know the environment" do
			lambda {@options.load_config "spec/default_config.yml"}.should raise_error(OptionsHash::EnvironmentMissing)
		end
		describe "given a set environment," do
			before :each do
				@options.environment = :development
			end
			it "should raise an argument error when you pass something silly in" do
				lambda {@options.load_config :silly}.should raise_error(ArgumentError)
				lambda {@options.load_config 51117}.should raise_error(ArgumentError)
			end
			it "should load a config file string without error" do
				lambda {@options.load_config "spec/default_config.yml"}.should_not raise_error
			end
			it "should load a config file without error" do
				file = File.new "spec/default_config.yml"
				lambda {@options.load_config file}.should_not raise_error
			end

			describe "data loading" do
				before :each do
					@options.environment = :development
					@options.load_config "spec/default_config.yml"
				end
				it "should assign things correctly from all" do
					@options[:port].should == 6543
				end
				it "should assign environment specific options" do
					@options[:server].should == "apache"
					production_options = OptionsHash.new
					production_options.environment = :production
					production_options.load_config "spec/default_config.yml"
					production_options[:server].should == "thin"
				end
			end
			
		end
	end
	
	describe "load_database_config method" do
		before :each do
			@development_options = OptionsHash.new
			@production_options = OptionsHash.new
		end
		it "should not work without assignment of environment" do
			lambda {@development_options.load_database_config "spec/database.yml"}.should raise_error(OptionsHash::EnvironmentMissing)
		end
		describe "when environment attribute is assigned" do
		
			before :each do
				@development_options.environment = :development
				@production_options.environment = :production
			end	
			
			it "should not raise when a filename string is passed in" do
				lambda {@development_options.load_database_config "spec/database.yml"}.should_not raise_error
			end
			
			it "should not raise when a file is passed in" do
				file = File.new "spec/database.yml"
				lambda {@development_options.load_database_config file}.should_not raise_error
			end
			
			describe "post data loading should have the appropriate data loaded" do
				before :each do
					@development_options.load_database_config "spec/database.yml"
					@production_options.load_database_config "spec/database.yml"
				end
				it "for development" do
					@development_options[:database][:adapter].should == "sqlite3"
				end
				it "for production" do
					@production_options[:database][:adapter].should == "postgresql"
				end
			end
			
			describe "primary configuration overriding" do
				before :each do
					@production_options.load_config "spec/default_config.yml"
				end
				it "should work" do
					@production_options[:database][:adapter].should == "sqlite3"
					@production_options.load_database_config "spec/database.yml"
					@production_options[:database][:adapter].should == "postgresql"
				end
			end
			
		end
	end
	
	describe "inherit_authenticator_database! method" do
		before :each do
			@options = OptionsHash.new
			@options.environment = :production
			@options.load_config "spec/default_config.yml"
		end
		it "should work" do
			@options[:authenticator][:database].should == "inherit"
			@options.inherit_authenticator_database!
			@options[:authenticator][:database].should_not == "inherit"
			@options[:authenticator][:database][:adapter].should == "sqlite3"
		end
		it "should work after loading database.yml" do
			@options.load_database_config "spec/database.yml"
			@options[:authenticator][:database].should == "inherit"
			@options.inherit_authenticator_database!
			@options[:authenticator][:database].should_not == "inherit"
			@options[:authenticator][:database][:adapter].should == "postgresql"
		end
		it "should do nothing when it should do nothing" do
			options = OptionsHash.new
			options.environment = :development
			options.load_config "spec/default_config.yml"
			options[:authenticator][:database][:adapter].should == "mysql"
			options.inherit_authenticator_database!
			options[:authenticator][:database][:adapter].should == "mysql"
		end
	end
end
