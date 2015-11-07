class AccountActivationsController < ApplicationController
    def edit
        user = User.find_by(email: params[:email])
        if user && !user.activated? && user.authenticate?(:activation, params[:id])
            # user.update_attribute(:activated, true)
            # user.update_attribute(:activated_at, Time.zone.now)
            user.activate
            log_in user
            flash[:success] = "驗證成功"
            redirect_to user
        else
            flash[:danger] = "驗證失敗"
            redirect_to root_url
        end
    end
end
