class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :following, :followers]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy
  # 事先過濾

  # 判斷使用者是否與登入的一樣
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

  def index
    # @users = User.paginate(page: params[:page])
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
    redirect_to root_url and return unless @user.activated?  
  end

  def create
    @user = User.new(user_params)

    if @user.save
      # log_in @user # 註冊同時登入

      # flash message
      # flash[:success] = "歡迎！"

      # 成功儲存
      # redirect_to @user # redirect_to user_url(@user)
      
      # UserMailer.account_activation(@user).deliver_now
      @user.send_activation_email
      flash[:info] = '請確認你的email驗證你的帳號'
      redirect_to root_url
    else
      render 'new'
    end
  end

  # 編輯使用者
  def edit
    @user = User.find(params[:id])
  end

  # 更新使用者資料
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      # 儲存成功
      flash[:success] = "更新成功"
      redirect_to @user
    else
      render 'edit'
    end
  end

 # 刪除使用者
  def destroy
      User.find(params[:id]).destroy
      flash[:success] = "刪除成功"
      redirect_to users_url
  end
  
  # 顯示某個用戶關注的人
  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end
  
  # 顯示關注某個用戶的人
  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  private
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
