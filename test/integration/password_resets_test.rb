require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base::deliveries.clear
    @user = users(:test)
  end

  test "password resets" do
    get new_password_reset_path
    assert_template 'password_resets/new'

    # email 無效
    post password_resets_path, password_reset: { email: "" }
    assert_not flash.empty?
    assert_template 'password_resets/new'

    # email 有效
    post password_resets_path, password_reset: { email: @user.email }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base::deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url

    # 密碼重設表
    user = assigns(:user)

    # email 的連結錯誤
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url

    # 使用者尚未驗證
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)

    # email 正確，驗證碼錯誤
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_url

    # email和驗證碼都正確
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", user.email

    # 密碼和確認密碼都不正確
    patch password_reset_path(user.reset_token), email: user.email, user: { password: 'test', password_confirmation: '1234' }
    assert_select 'div#error_explanation'

    # 密碼為空值
    patch password_reset_path(user.reset_token), email: user.email, user: { password: '', password_confirmation: '' }
    assert_not flash.empty?
    assert_template 'password_resets/edit'

    # 密碼和確認密碼都正確
    patch password_reset_path(user.reset_token), email: user.email, user: { password: 'test1234', password_confirmation: 'test1234' }
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to user
  end
  
  test "expired token" do
    get new_password_reset_path
    post password_resets_path, password_reset: { email: @user.email }
    
    @user = assigns(:user)
    @user.update_attribute(:reset_sent_at, 3.hours.ago)
    patch password_reset_path(@user.reset_token), email: @user.email, user: { password: "test1234", password_confirmation: "test1234" }
    
    assert_response :redirect
    follow_redirect!
    assert_match /忘記密碼/i, response.body
  end
end