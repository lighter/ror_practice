module SessionsHelper
    #登入指定的用戶
    def log_in(user)
        session[:user_id] = user.id
    end

    #是否已經登入
    def logged_in?
       !current_user.nil?
    end

    #退出
    def log_out
       session.delete(:user_id)
       @current_user = nil
    end

    def remember(user)
        user.remember

        cookies.permanent.signed[:user_id] = user.id # 設定 cookies user_id
        cookies.permanent[:remember_token] = user.remember_token # 設定 cookies remenber_token
    end

    # 取回目前的登入使用者
    def current_user

        # 如果session 的還存在
        if (user_id = session[:user_id])
            @current_user ||= User.find_by(id: user_id)

        # 取用 cookie
        elsif (user_id = cookies.signed[:user_id])
            # raise # 測試仍能通過，所以沒有覆蓋這個分支
            # 是否從資料庫取得成功
            user = User.find_by(id: user_id)

            # 取出 user 並驗證 cookie 的 remember_token
            if user && user.authenticate?(:remember, cookies[:remember_token])
                log_in user
                @current_user = user
            end
        end
    end

    # 登出，忘記永久登入
    def forget(user)
        user.forget

        # 刪除cookies
        cookies.delete(:user_id)
        cookies.delete(:remember_token)
    end

    # 登出目前使用者
    def log_out
        forget(current_user)
        session.delete(:user_id)
        @current_user = nil
    end
    
    # 判斷是否與目前登入的使用者相同
    def current_user?(user)
        user == current_user
    end
    
    # 重新轉頁的判定
    def redirect_back_or(default)
        redirect_to(session[:forwarding_url] || default)
        session.delete(:forwarding_url)
    end
    
    # 儲存路徑
    def store_location
        session[:forwarding_url] = request.url if request.get?
    end
end
