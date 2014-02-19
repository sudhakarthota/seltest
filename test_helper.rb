require "selenium-webdriver"
gem "test-unit"
require "test/unit"
require 'rubygems'
require 'time'
require "active_support"
#gem 'minitest'
#require 'minitest'
#require 'turn/autorun'

#Minitest.autorun
require 'yaml'

APPLICATION_CONFIG = YAML.load_file("config.yaml")

# Fixtures support
class Test::Unit::TestCase 
  @@fixtures = {}
  @@config = {}
  def self.fixtures list
    [list].flatten.each do |fixture|
      self.class_eval do
        # add a method name for this fixture type
        define_method(fixture) do |item|
          # load and cache the YAML
          @@fixtures[fixture] ||= YAML::load_file("fixtures/#{fixture.to_s}.yaml")
          @@fixtures[fixture][item.to_s]
        end
      end
    end
  end
end

def element_present?(how, what)
      @driver.find_element(how, what)
      true
        rescue Selenium::WebDriver::Error::NoSuchElementError
      false
end

def alert_present?()
      @driver.switch_to.alert
      true
        rescue Selenium::WebDriver::Error::NoAlertPresentError
      false
end

def verify(&blk)
      yield
      rescue Test::Unit::AssertionFailedError => ex
      @verification_errors << ex
end

def close_alert_and_get_its_text(how, what)
      alert = @driver.switch_to().alert()
      alert_text = alert.text
      if (@accept_next_alert) then
        alert.accept()
      else
        alert.dismiss()
      end
      alert_text
      ensure
      @accept_next_alert = true
end

# get webdriver object
def get_driver
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile['browser.download.dir'] = Dir.pwd+"/downloads"
    profile['browser.download.folderList'] = 2
    profile['browser.helperApps.neverAsk.saveToDisk'] = "application/octet-stream,application/pdf"
    profile['pdfjs.disabled'] = true
    profile['pdfjs.firstRun'] = false
    @driver= Selenium::WebDriver.for :firefox, :profile => profile
    # @driver = Selenium::WebDriver.for(:firefox)
    @base_url = "localhost:3000/admin" 
    
    @driver.manage.timeouts.implicit_wait = 30
    @driver.manage.window.maximize
    @wait = Selenium::WebDriver::Wait.new(:timeout => 20)
    @driver 
end

def login_user(driver, base_url, user)
    driver.get(base_url + "/")
    driver.find_element(:id, "user_session_email").clear
    driver.find_element(:id, "user_session_email").send_keys ""
    driver.find_element(:id, "user_session_email").send_keys user["email"]
    driver.find_element(:id, "user_session_password").clear
    driver.find_element(:id, "user_session_password").send_keys ""
    driver.find_element(:id, "user_session_password").send_keys user["password"] 
    driver.find_element(:css, "button.button").click
    assert_equal "Demo", driver.find_element(:css, "h1.store_name").text
end



def wait_for_ajax(driver)
   wait = Selenium::WebDriver::Wait.new(:timeout => 30)
   wait.until { driver.execute_script("return jQuery.active == 0") } 
end

def check_and_accept_alert(driver)
  driver.switch_to.alert.accept rescue Selenium::WebDriver::Error::NoAlertOpenError
end

def dropdown_list(driver, element_id, option_value)
    element = driver.find_element(:id, element_id)
    options = element.find_elements(:tag_name, "option")
    select_element = options.find {|o| o.text == option_value }
    select_element.click
end


def dropdown_list_gsub(driver, element_id, option_value)
    element = driver.find_element(:id, element_id)
    options = element.find_elements(:tag_name, "option")
    select_element = options.find {|o| o.text.gsub(/[(\d*)]/,"").strip == option_value}
    select_element.click
    wait_for_ajax(driver)
end


def dropdown_list_css(driver, element_id, option_value)
    element = driver.find_element(:css, element_id)
    options = element.find_elements(:tag_name, "option")
    select_element = options.find {|o| o.text == option_value }
    select_element.click
end


def dropdown_list_xpath(driver, element_id, option_value)
    element = driver.find_element(:xpath, element_id)
    options = element.find_elements(:tag_name, "option")
    select_element = options.find {|o| o.text == option_value }
    select_element.click
end




def check(state, element_id)
  element=@driver.find_element(:id, element_id)
  if element.selected? != state
    element.click
  end
end





def gmail_user(driver, email)
  email_url=APPLICATION_CONFIG["email_url"] 
  driver.get(email_url)
  page_url = driver.current_url
  if(page_url=="https://mail.google.com/intl/en/mail/help/about.html")
    driver.find_element(:id,"gmail-sign-in").click
  end
  driver.find_element(:id, "Email").clear
  driver.find_element(:id, "Email").send_keys email["username"]
  driver.find_element(:id, "Passwd").clear
  driver.find_element(:id, "Passwd").send_keys email["password"]       
  driver.find_element(:id, "signIn").click
end

# logout Gmail
def logout_gmail
    @driver.find_element(:id,"gbgs4dn").click
    @driver.find_element(:id,"gb_71").click
end

# method to search Inbox for the given subject,sender(optional),time_sent(optional)
def search_inbox(subject_to_find=nil,sender_expected=nil,time_sent=nil)
        puts "Searching...mail"
        xpath_start="//*[@class='F cf zt']/tbody[1]/tr["
        xpath_end="]/td[6]"
        status_new=0
        diff =0
        for o in 0..50
            # to exit from outer loop
            if(status_new==1)
                break
            end
            for i in 1..10
                element=@driver.find_element(:xpath,xpath_start+i.to_s+xpath_end) 
                subject=element.text
                subject_contain = subject_to_find
                time_received= @driver.find_element(:xpath,xpath_start+i.to_s+"]/td[8]").text
                if(time_sent!= nil)
                    diff= (Time.parse(time_received) - Time.parse(time_sent))/60
                end
                # check Inbox and pick matched subject mail
                if((subject.include? subject_contain) && ((diff <5 && diff >=0) || time_sent==nil))
                    sender = @driver.find_element(:xpath,xpath_start+i.to_s+"]/td[5]").text
                    if((sender_expected == nil) || (sender.include? sender_expected))
                        puts "Subject matched for i:#{i} and o:#{o}, "+" Receieved is #{time_received}"
                        return element
                    end     
                end
            end
            # To refresh Inbox (optional)
            #@driver.find_element(:xpath,"//*[@id=':5']/div/div[1]/div[1]/div/div/div[4]/div/div/div")
            sleep(3)
            if (o==30 && status_new!=1)
                    puts "Didn't receive any mail"
                    element = nil
            end
        end
        element
    end

# def check(order_no, state, element_id)
#   element=@driver.find_element(:id, element_id)
#   if order_no=@driver.find_element(:link, order_no).text
#   unless element.selected? != state
#     element.click
#   end
#   end
# end


# def check(invoice_no, state, element_id)
#   element=@driver.find_element(:id, element_id)
#   if invoice_no=@driver.find_element(:link, invoice_no).text
#   unless element.selected? != state
#     element.click
#   end
#   end
# end
