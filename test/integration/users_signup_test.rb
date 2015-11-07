require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  
  def setup
    ActionMailer::Base.deliveries.clear
  end
  
  test "invalid signup information" do
    get signup_path

    assert_no_difference 'User.count' do
      post users_path, user: {name: "",
                              email: "test@test.com",
                              password: "1234",
                              password_confirmation: "123"
                             }
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.alert'
  end

  test "valid signup information" do
    get signup_path
    name = "test123"
    email = "test123@test.com"
    password = "test1234"

    assert_difference 'User.count', 1 do
      post_via_redirect users_path, user:{
        name: name,
        email: email,
        password: password,
        password_confirmation: password
      }
    end

    # assert_template 'users/show'
    # assert_not flash.empty?
    # assert is_logged_in? # 驗證是否已經登入
  end

  test "valid signup information with account activation" do
    get signup_path
    
    assert_difference 'User.count', 1 do
      post users_path, user: { name: "test",
                               email: "testtestabcd@test.com",
                               password: "test1234",
                               password_confirmation: "test1234"
                             }
    end
    
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    
    # 嘗試在驗證前登入
    log_in_as(user)
    assert_not is_logged_in?
    
    #驗證無效
    get edit_account_activation_path("invalid token")
    assert_not is_logged_in?
    
    #驗證正確，但email不對
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    
    #驗證有效
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end
end
