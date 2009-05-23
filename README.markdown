Getting Started
===============

1. Using sqlite doesn't work due to the code using mysql-specific timezone conversion functions. So make sure you use mysql in database.yml
2. create the log directory and make it world-writable
3. Populate the database with rake db:schema:load
4. Add a user at http://localhost:3000/signup
5. If you don't get a confirmation email (which you likely won't since you don't have the mail sending configured), check log/development.log for a copy of the confirmation email that would have been sent to you, copy and paste the activation url from it into the browser toolbar (should look like the following: http://tt.entp.com/activate/db61f839776898cedee72fcb9f87465d797e2e93 - of course, replace tt.entp.com with your dev server address.