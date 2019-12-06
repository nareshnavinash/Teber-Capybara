require 'allure-cucumber'
require 'selenium-webdriver'
require 'cucumber'
require 'require_all'
require 'pathname'
require 'fileutils'
require 'headless'
require "pry"
require "time"
require 'uri'
require 'active_support/time'
require 'parseconfig'
require 'capybara'
require 'capybara/cucumber'
require 'site_prism'
require 'OS'
# require 'capybara-screenshot/cucumber'
include AllureCucumber::DSL

if File.exist?('features/global-data/global.yml')
    $conf =  YAML.load_file('features/global-data/global.yml')
else
    puts "features/global-data/global.yml is not found !!!"
end
FileUtils.mkdir_p("#{Pathname.pwd}/#{$conf['screenshot_location']}")
$VERBOSE = nil
$drivers = []

# Capybara.register_driver :headless_chrome do |app|
#   capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
#     chromeOptions: { args: %w(headless disable-gpu) }
#   )

#   Capybara::Selenium::Driver.new app,
#     browser: :chrome,
#     desired_capabilities: capabilities
# end

if $conf['mode'] == "headless" or OS.linux? or ENV['mode'] == "headless"
  default_driver = "selenium_chrome_headless"
else
  default_driver = "selenium_chrome"
end

Capybara.configure do |config|
  config.default_max_wait_time = $conf['implicit_wait']
  config.ignore_hidden_elements = true
  config.automatic_reload = false
  config.save_path = "../../reports/screenshots"
  config.threadsafe = true
  # config.run_server = false
  config.default_driver = default_driver.to_sym
  # config.app_host = "https://www.google.com"
end
$drivers << Capybara.current_driver

AllureCucumber.configure do |c|
   c.output_dir = "reports/allure"
   c.clean_dir  = true
end

Cucumber::Core::Test::Step.module_eval do
  def name
    return text if self.text == 'Before hook'
    return text if self.text == 'After hook'
    "#{source.last.keyword}#{text}"
  end
end


Before do |scenario|
    # Have the test data corresponding to a feature in the path `/features/test-data/` in the .conf format
    # Name the file as same as the feature file and the below code will parse that file and have the variables in $param
    # Test data specific to that feature can be accessed with $param in that step definition file.
    feature = scenario.location
    feature_file_name = feature.to_s.rpartition('/').last.split('.feature')[0]
    test_variables_file_location = Dir.pwd + "/features/test-data/#{feature_file_name}.yml"
    if File.exists?("#{test_variables_file_location}")
      $param = YAML.load_file(test_variables_file_location)
    end
end
  

Before do
  # If needed
end

After do |scenario|
	if scenario.failed?
        begin
          d = $drivers
          d.each do |driver_sym|
            Capybara.current_driver = driver_sym
            file_name = "#{driver_sym.to_s}+#{(Time.now.to_f * 1000).to_i.to_s}+.png"
            save_screenshot("../../reports/screenshots/#{file_name}")
            attach_file("#{driver_sym}", "../../reports/screenshots/#{file_name}")
            Capybara.use_default_driver
          end
        rescue Exception => e
            puts e.message
        end
        # to quit the test run if any one of the scenario is failed
		    # Cucumber.wants_to_quit = true if scenario.failed?
	end
end

at_exit do
  # If needed
end