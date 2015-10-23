require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
    def setup
        @user = users(:test)
    end

    test "login with valid information" do
        get login_path
        post login_path, session: { email: @user.email, password: 'abcd1234' }
        assert_redirected_to @user #檢查重新導向的網址是否正確
        follow_redirect! # 訪問重新導向的網址目標
        assert_template 'users/show'
        assert_select "a[href=?]", login_path, count: 0 # 確認登入連結消失
        assert_select "a[href=?]", logout_path
        assert_select "a[href=?]", user_path(@user)
    end

    test "login with invalid information" do
        get login_path
        assert_template 'sessions/new'
        post login_path, session: { email: "", password: "" }
        assert_template 'sessions/new'
        assert_not flash.empty?
        get root_path
        assert flash.empty?
    end

    test "login with valid information followed by logout" do
        get login_path
        post login_path, session: { email: @user.email, password: 'abcd1234' }
        assert is_logged_in? # 判斷是否登入
        assert_redirected_to @user
        follow_redirect!
        assert_template 'users/show'
        assert_select "a[href=?]", login_path, count: 0
        assert_select "a[href=?]", logout_path
        assert_select "a[href=?]", user_path(@user)
        delete logout_path # 登出
        assert_not is_logged_in? # 判斷是否登出
        assert_redirected_to root_url

        # 模擬用戶在另一個視窗點選登出
        delete logout_path

        follow_redirect!
        assert_select "a[href=?]", login_path
        assert_select "a[href=?]", logout_path, count: 0
        assert_select "a[href=?]", user_path(@user), count: 0
    end

    test "login with remember me" do
        log_in_as(@user, remember_me: '1')
    
        assert_equal assigns(:user).remember_token, cookies['remember_token']
        
        # cookies的remember_token 非 nil
        # assert_not_nil cookies['remember_token']
    end

    test "login without remember me" do
        log_in_as(@user, remember_me: '0')

        # cookies的remember_token 是 nil
        assert_nil cookies['remember_token']
    end
end
