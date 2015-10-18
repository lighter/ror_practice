ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/reporters'
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  include ApplicationHelper

  # 檢查是否登入
  def is_logged_in?
    !session[:user_id].nil? # 檢查 session中是否有user_id
  end

  # 登入測試用戶
  def log_in_as(user, options = {})
    password = options[:password] || 'abcd1234'
    remember_me = options[:remember_me] || '1'

    if integration_test?
      post login_path, session: { email: user.email,
                                  password: password,
                                  remember_me: remember_me }
    else
      session[:user_id] = user.id
    end
  end

  private
    # 是否為integration測試
    def integration_test?
      defined?(post_via_redirect) # post_via_redirect 發起 HTTP POST並跟蹤後續導向
    end
end
