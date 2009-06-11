Project.blueprint do
  name { "Project #{rand(100)}" }
  user
  code { "abc#{rand(500)}" }
  # permalink { "Project-#{rand(100)}" }
end

Context.blueprint do
  user
  name { "My context #{rand(100)}" }
end

user_time = Time.utc 2007, 1, 1

User.blueprint do
  login        { Faker::Name.name.gsub(/[^\w]/, '') }
  email        { Faker::Internet.email(login.downcase) }
  aasm_state   { 'active' }
  activated_at { user_time += 1.minute }
  created_at   { activated_at }
  updated_at   { activated_at }
  salt             '356a192b7913b04c54574d18c28d46e6395428ab'
  crypted_password 'a8577d9ad3469a4be84694867eabe53131169b46' # monkey
  time_zone        'UTC'
  permalink    { "normal-user-#{rand(100)}" }
end

Membership.blueprint do
  project
  context_id { Context.make.id }
  user
  code { "abc#{rand(500)}" }
end
