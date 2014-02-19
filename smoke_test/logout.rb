require './test_helper.rb'

class Logout < Test::Unit::TestCase
  fixtures [:users]

	def setup
	  @driver = get_driver
      @accept_next_alert = true
      @verification_errors = [] 
	end

	def teardown
	  @driver.quit
	  assert_equal [], @verification_errors
	end

	def test_logout
      login_user(@driver, @base_url, users(:sudhakar))
      @driver.find_element(:link, "Logout").click
      assert !60.times{ break if (@driver.find_element(:css, "div.message.notice").text == "Successfully logged Out!" rescue false); sleep 1 }
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
end
