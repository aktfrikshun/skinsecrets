namespace :email do
  desc "Test Enveloop email functionality"
  task test_enveloop: :environment do
    puts "Testing Enveloop email functionality..."

    begin
      # Test ActionMailer with Enveloop
      if User.any?
        user = User.first
        puts "Testing ActionMailer with user: #{user.email}"

        EnveloopMailer.welcome_email(user).deliver_now
        puts "✅ ActionMailer test successful!"
      else
        puts "⚠️  No users found for ActionMailer test"
      end

    rescue => e
      puts "❌ ActionMailer test failed: #{e.message}"
      puts "Error class: #{e.class}"
      puts "Backtrace: #{e.backtrace.first(5).join("\n")}"
    end
  end
end
