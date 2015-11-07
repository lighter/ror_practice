require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    # @user = User.new(name: "test", email: "test@test.com")
    @user = User.new(name: "test", email: "test123@test.com", password: "password", password_confirmation: "password")
  end
  
  test "should be valid" do 
    assert @user.valid?
  end
  
  test "name should be present" do
    @user.name = "   "
    assert_not @user.valid?
  end
  
  test "email should be present" do
    @user.email = "   "
    assert_not @user.valid?
  end
  
  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end
  
  test "email should not be too long" do
    @user.email = "a" * 255 + "@test.com"
    assert_not @user.valid?
  end
  
  test "email format should be valid" do
    valid_address = %w[user@example,com test,_MAIL@test.com abc+123@gmail www.google.com]
    
    valid_address.each do |valid_address_|
      @user.email = valid_address_
      assert_not @user.valid?, "#{valid_address_.inspect} should be valid"
    end
  end
  
  test "email addresses should be unique" do
    duplicate_user = @user.dup # 創建一個與@user一樣的
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end
  
  test "password should be presen nonblank" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end
  
  test "password should have a minmum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end
  
  test "email addresses should be saved as lowercase" do
    mixed_email = "TeSt123@TeSt.CoM"
    @user.email = mixed_email
    @user.save
    assert_equal mixed_email.downcase, @user.reload.email
  end
  

end
