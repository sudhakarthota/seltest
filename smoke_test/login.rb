require   './test_helper.rb'

# = This class holds the testing of 'Login' testcase
# == In this testcase the following scenarios can be tested
# * Testing positive case by giving valid username and password.
# * Testing negative case by giving invalid username and password.
class Login < Test::Unit::TestCase 
  fixtures :users

# To open firefox browser and the application url
  def setup
    @driver = get_driver
    @accept_next_alert = true
    @verification_errors = [] 
  end
# Throws an assertion errors
  def teardown
    @driver.quit
    assert_equal [], @verification_errors
  end
  
# Test to login with valid credentials
  def test_login_with_correct_creds
    @driver.get(@base_url + "/")
    @driver.find_element(:id, "user_session_email").clear
    @driver.find_element(:id, "user_session_email").send_keys ""
    @driver.find_element(:id, "user_session_email").send_keys users(:sudhakar)["email"]
    @driver.find_element(:id, "user_session_password").clear
    @driver.find_element(:id, "user_session_password").send_keys ""
    @driver.find_element(:id, "user_session_password").send_keys users(:sudhakar)["password"] 
    @driver.find_element(:id, "login").click
    assert_equal "Success", @driver.find_element(:css, "h1").text
  end

# Test to login with invalid credentials
  def test_login_with_wrong_creds
    @driver.get(@base_url + "/")
    @driver.find_element(:id, "user_session_email").clear
    @driver.find_element(:id, "user_session_email").send_keys ""
    @driver.find_element(:id, "user_session_email").send_keys users(:sudhakar)["email"] 
    @driver.find_element(:id, "user_session_password").clear
    @driver.find_element(:id, "user_session_password").send_keys ""
    @driver.find_element(:id, "user_session_password").send_keys users(:sudhakar)["incorrect_password"] 
    @driver.find_element(:id, "login").click
    verify do
       assert_equal "Login failed!", @driver.find_element(:css, "p").text 
    end
  end
  
# To find the element and throws an error if element is not found.
  def element_present?(how, what)
    @driver.find_element(how, what)
    true
      rescue Selenium::WebDriver::Error::NoSuchElementError
    false
  end

# To see the alert is present and throws an error if no alert is present
  def alert_present?()
    @driver.switch_to.alert
    true
  rescue Selenium::WebDriver::Error::NoAlertPresentError
    false
  end
  
# To verify expected and actual values
# If assertion failed it throws an error
  def verify(&blk)
    yield
    rescue Test::Unit::AssertionFailedError => ex
    @verification_errors << ex
  end
  
# To close alerts
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
end
