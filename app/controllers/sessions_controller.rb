class SessionsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)

    if @user && @user.authenticate(params[:session][:password])
      if @user.activated?
        # 用戶登入
        log_in @user
  
        # 是否有勾選紀錄登入狀態
        params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
  
        # redirect_to @user
        redirect_back_or @user # 判斷返回的路徑
      else 
        message = "帳號尚未驗證"
        message += "請確認你的email"
        flash[:warning] = message
        redirect_to root_url
      end
    else
      # 登入失敗
      flash.now[:danger] = '密碼或帳號錯誤'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
