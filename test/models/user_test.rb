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


  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "test content")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    user_test = users(:test)
    ancher = users(:ancher)
    assert_not user_test.following?(ancher)
    user_test.follow(ancher)
    assert user_test.following?(ancher)
    assert ancher.followers.include?(user_test) # 加上這行測試ancher的關注人有user_test嗎？
    user_test.unfollow(ancher)
    assert_not user_test.following?(ancher)
  end

  test "feed should have the right posts" do
    user_test = users(:test)
    ancher = users(:ancher)
    hogs = users(:hogs)

    # 關注的用戶發布的micropost
    hogs.microposts.each do |post_following|
      assert user_test.feed.include?(post_following)
    end

    # 自己的micropost
    user_test.microposts.each do |post_self|
      assert user_test.feed.include?(post_self)
    end

    # 未關注的用戶micropost
    ancher.microposts.each do |post_unfollowed|
      assert_not user_test.feed.include?(post_unfollowed)
    end
  end
end
