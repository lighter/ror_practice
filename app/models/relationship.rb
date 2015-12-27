class Relationship < ActiveRecord::Base
    belongs_to :follower, class_name: "User" # 關注我的
    belongs_to :followed, class_name: "User" # 我關注的
    
    validates :follower_id, presence: true
    validates :followed_id, presence: true
end
