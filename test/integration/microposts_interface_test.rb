require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:test)
  end
  
  test "micropost interface" do
    log_in_as(@user)
    get root_path
    assert_select 'div.pagination'
    
    # 無效提交
    assert_no_difference 'Micropost.count' do
      post microposts_path, micropost: { content: "" }
    end
    assert_select 'div#error_explanation'
    
    # 有效提交
    content = 'test content'
    assert_difference 'Micropost.count', 1 do
      post microposts_path, micropost: { content: content }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
    
    # 刪除一篇micropost
    assert_select 'a', text: '刪除'
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
    
    # 訪問另一個用戶的資料頁面
    get user_path(users(:hogs))
    assert_select 'a', text: '刪除', count: 0
  end

  test "micropost sidebar count" do
    log_in_as(@user)
    get root_path
    assert_match '#span microposts', response.body
    
    # 使用者沒有發佈micropost
    other_user = users(:laalaa)
    log_in_as(other_user)
    get root_path
    assert_match "0 microposts", response.body
    
    other_user.microposts.create!(content: "test")
    
    get root_path
    assert_match '#span microposts', response.body
  end

end
