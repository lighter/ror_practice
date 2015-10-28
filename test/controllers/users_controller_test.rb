require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  
  def setup
    @user = users(:test)  
    @hogs = users(:hogs)
  end
  
  test "should get new" do
    get :new
    assert_response :success
  end
  
  test "should redirect edit when not logged in" do
    get :edit, id: @user
    assert_redirected_to login_url
  end
  
  test "should redirect update when not logged in" do
    patch :update, id: @user, user: { name: @user.name, email: @user.email }
    assert_redirected_to login_url
  end
  
  test "should redirect edit when logged in wrong user" do
    log_in_as(@hogs)
    get :edit, id: @user
    assert_redirected_to root_url
  end
  
  test "should redirect update when logged in wrong user" do
    log_in_as(@hogs)
    patch :update, id: @user, user: { name: @user.name, email: @user.email }
    assert_redirected_to root_url
  end
  
  test "should redirect index when not logged in" do
    get :index
    assert_redirected_to login_url
  end
  
  # 當沒登入刪除時會導頁到登入頁面
  test "should redirect destroy when not logged in" do
    assert_no_difference 'User.count' do
      delete :destroy, id: @user
    end
    
    assert_redirected_to login_url
  end
  
  # 沒有權限刪除時會導入到首頁
  test "should redirect destroy when logged in as non-domain" do
    log_in_as(@hogs)
    assert_no_difference 'User.count' do
      delete :destroy, id: @user
    end
    
    assert_redirected_to root_url
  end
  
  # 測試真的擁有管理者權限刪除後
  test "realy delete user" do
    log_in_as(@user)
    # 刪除後的變化量是-1
    assert_difference 'User.count', -1 do
      delete :destroy, id: @hogs
    end
  end
end
