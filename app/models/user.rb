class User < ActiveRecord::Base
    # 建立一個可以訪問user.remember_token的屬性
    attr_accessor :remember_token, :activation_token, :reset_token

    # before_save {self.email = email.downcase} # self.email = self.email.downcase
    # before_save { email.downcase! }
    before_save :downcase_email
    before_create :create_activation_digest


    validates :name, presence: true, length: { maximum: 50 }

    # VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

    validates :email, presence: true, length: { maximum: 255 },
                                      format: { with: VALID_EMAIL_REGEX},
                                      uniqueness: { case_sensitive: false }

    has_secure_password # 添加密碼驗證

    validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

    class << self
        #指定回傳的hash
        def digest(string)
            cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
                        #   要計算hash的字串, 決定計算hash消耗的資源
            BCrypt::Password.create(string, cost: cost)
        end

        #產生一個隨機token
        def new_token
            SecureRandom.urlsafe_base64 #回傳的字串長度為22
        end
    end

    #為了紀錄持續登入狀態，在資料庫中記住User
    def remember
        self.remember_token = User.new_token
        update_attribute(:remember_digest, User.digest(remember_token))
    end

    # def authenticate?(remember_token)
        # return false if remember_digest.nil?
        # 判斷 remember_digest 跟 remember_token 是否相同
        # BCrypt::Password.new(remember_digest).is_password?(remember_token)
    # end

    def authenticate?(attribute, token)
       digest = send("#{attribute}_digest")
       return false if digest.nil?
       BCrypt::Password.new(digest).is_password?(token)
    end

    # 使用者登出
    def forget
       update_attribute(:remember_digest, nil)
    end

    # 驗證帳號
    def activate
        # update_attribute(:activated, true)
        # update_attribute(:activated_at, Time.zone.now)
        update_columns(activated: true, activated_at: Time.zone.now)
    end

    # 發送驗證信
    def send_activation_email
       UserMailer.account_activation(self).deliver_now
    end

    # 設定密碼重設的相關設定
    def create_reset_digest
        self.reset_token = User.new_token
        # update_attribute(:reset_digest, User.digest(reset_token))
        # update_attribute(:reset_sent_at, Time.zone.now)
        update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
    end

    # 送出email
    def send_password_reset_email
       UserMailer.password_reset(self).deliver_now
    end

    # 驗證重設密碼時間是否失效
    def password_reset_expired?
       reset_sent_at < 2.hours.ago
    end

    private

        # email 轉小寫
        def downcase_email
           self.email = email.downcase
        end

        # 建立驗證token和驗證碼
        def create_activation_digest
           self.activation_token = User.new_token
           self.activation_digest = User.digest(activation_token)
        end
end