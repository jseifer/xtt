user_time = Time.utc 2007, 1, 1
User.class_eval do
  blueprint do
    site         { Site.make }
    name         { Faker::Name.name }
    email        { Faker::Internet.email(name.gsub(/[^\w]/, '').downcase) }
    activated_at { user_time += 1.minute }
    created_at   { activated_at }
    updated_at   { activated_at }
    salt             '356a192b7913b04c54574d18c28d46e6395428ab'
    crypted_password 'a8577d9ad3469a4be84694867eabe53131169b46' # monkey
  end
end