require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "account_activation" do
    user = users(:test)
    user.activation_token = User.new_token
    mail = UserMailer.account_activation(user)
    assert_equal "帳號驗證", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match user.name, mail.body.encoded # 檢查是否有使用者的名字
    assert_match user.activation_token, mail.body.encoded # 檢查是否有使用者的驗證碼
    assert_match CGI::escape(user.email), mail.body.encoded # 使用者驗證url
  end

  test "password_reset" do
    user = users(:test)
    user.reset_token = User.new_token
    mail = UserMailer.password_reset(user)
    assert_equal "重設密碼", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match user.reset_token, mail.body.encoded
    assert_match CGI::escape(user.email), mail.body.encoded
  end

end
