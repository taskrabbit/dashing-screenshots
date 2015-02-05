require 'fileutils'

module Dashing
  class Screenshot
    def initialize(directory, options=nil)
      @directory = directory
      @options = options || {}
    end

    def capture!
      require 'selenium-webdriver'
      ::FileUtils.mkdir_p(@directory)

      @driver = Selenium::WebDriver.for :firefox
      Dir["dashboards/**/*.erb"].each do |file|
        file.gsub!(/^dashboards\//, "")
        file.gsub!(/\.erb$/, "")
        next if ["layout"].include?(file)
        snap(file)
      end
      @driver.quit
    end

    private

    def snap(path)
      puts "Fetching #{path}" if @options[:log]
      @driver.manage.window.resize_to(50,200)
      @driver.navigate.to "http://localhost:3030/#{path}"
      filename = File.join(@directory, "#{path.gsub("/", "__")}.png")
      puts "  saving: #{filename}" if @options[:log]
      sleep 2
      @driver.save_screenshot(filename)
    rescue Exception => e
      puts "        SCREENSHOT ERROR: #{e.message}"
    end
  end
end
