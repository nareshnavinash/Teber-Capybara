module Library
    # other code that prepares capybara to work with selenium

    def scroll_to(element)
      script = <<-JS
        arguments[0].scrollIntoView(true);
      JS
  
      Capybara.current_session.driver.browser.execute_script(script, element.native)
    end

    def get_registered_drivers
      Capybara.drivers
    end

    def self.new_driver(name)
      
      case $conf['browser']

      when 'chrome'
        Capybara.register_driver name.to_sym do |app|
          if $conf['mode'] == "headless" or OS.linux? or ENV['mode'] == "headless"
            Capybara::Selenium::Driver.new(app, :browser => :chrome, args: ['headless', 'disable-infobars', 'disable-gpu', 'disable-dev-shm-usage', 'no-sandbox'])
          else
            Capybara::Selenium::Driver.new(app, :browser => :chrome)
          end
        end
        $drivers << name.to_sym
        return $drivers.last
      
      when 'firefox'
        # to be added

      when 'ie'
        # to be added

      when 'edge'
        # to be added

      when 'safari'
        # to be added

      else
        raise ArgumentError, "Specify a proper browser while initiating a driver \n \n#{browser.inspect}"
      end

    end
    
    def self.get_drivers_list
      $drivers
    end

    def self.get_last_driver
      $drivers.last
    end

    class Screenshot
      @@path = ""
      def self.set_path(str_path)
        @@path = str_path
      end
      
      def self.path
        return @@path
      end
    end

    # Capybara.current_driver = :webkit
    # Capybara.use_default_driver

    # page.all(:css, '.block').each do |el|
    #     puts el.text
    # end
    
end