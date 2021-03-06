# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create!(name: "test",
             email: "test@test.com",
             password: "test1234",
             password_confirmation: "test1234",
             admin: true,
             activated: true,
             activated_at: Time.zone.now)

99.times do |n|
   name = Faker::Name.name
   email = "example-#{n+1}@test.com"
   password = "passowrd"

    User.create!(name: name,
                email: email,
                password: password,
                password_confirmation: password,
                activated: true,
                activated_at: Time.zone.now)
end

# 只為前六個使用者新增
# 太多使用者新增會太久
users = User.order(:created_at).take(6)
50.times do
    content = Faker::Lorem.sentence(5)
    users.each { |user| user.microposts.create!(content: content) }
end

# 關聯
users = User.all
user = User.find_by(name: "test")
following = users[2..50]
followers = users[3..40]
following.each { |followed| user.follow(followed) }
followers.each { |follower| follower.follow(user) }