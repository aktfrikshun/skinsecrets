# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create sample services
services = [
  {
    name: "Classic Facial",
    description: "A rejuvenating facial treatment that includes deep cleansing, exfoliation, and hydration. Perfect for all skin types to restore natural radiance.",
    duration: 60,
    price: 85.00,
    active: true,
    featured: true
  },
  {
    name: "Anti-Aging Treatment",
    description: "Advanced facial treatment targeting fine lines and wrinkles using premium anti-aging products and techniques to restore youthful appearance.",
    duration: 90,
    price: 120.00,
    active: true,
    featured: true
  },
  {
    name: "Acne Clearing Facial",
    description: "Specialized treatment for acne-prone skin that includes deep pore cleansing, exfoliation, and blemish control to achieve clear, healthy skin.",
    duration: 75,
    price: 95.00,
    active: true,
    featured: false
  },
  {
    name: "Hydrating Facial",
    description: "Intensive hydration treatment for dry and dehydrated skin using moisture-rich products to restore skin's natural moisture balance.",
    duration: 60,
    price: 80.00,
    active: true,
    featured: false
  },
  {
    name: "Brightening Treatment",
    description: "Treatment designed to even skin tone and reduce hyperpigmentation, leaving skin brighter and more radiant.",
    duration: 75,
    price: 100.00,
    active: true,
    featured: false
  },
  {
    name: "Relaxation Facial",
    description: "A soothing and calming facial treatment that combines gentle cleansing with relaxation techniques for stress relief.",
    duration: 60,
    price: 75.00,
    active: true,
    featured: false
  },
  {
    name: "Deep Cleansing Treatment",
    description: "Intensive cleansing treatment that removes impurities and unclogs pores for clearer, healthier skin.",
    duration: 45,
    price: 65.00,
    active: true,
    featured: false
  },
  {
    name: "Sensitive Skin Care",
    description: "Gentle treatment specifically designed for sensitive skin types, using hypoallergenic products and soothing techniques.",
    duration: 60,
    price: 85.00,
    active: true,
    featured: false
  }
]

services.each do |service_data|
  Service.find_or_create_by!(name: service_data[:name]) do |service|
    service.description = service_data[:description]
    service.duration = service_data[:duration]
    service.price = service_data[:price]
    service.active = service_data[:active]
    service.featured = service_data[:featured]
  end
end

puts "Created #{Service.count} services"

# Create admin user
admin_user = User.find_or_create_by!(email: "admin@skinsecretsnc.com") do |user|
  user.first_name = "Admin"
  user.last_name = "User"
  user.phone = "9198970150"
  user.password = "skinsecrets"
  user.password_confirmation = "skinsecrets"
end

puts "Created admin user: #{admin_user.email} (password: skinsecrets)"

# Create a test user
test_user = User.find_or_create_by!(email: "test@example.com") do |user|
  user.first_name = "Test"
  user.last_name = "User"
  user.phone = "(919) 897-0150"
  user.password = "password123"
  user.password_confirmation = "password123"
end

puts "Created test user: #{test_user.email} (password: password123)"

# Create some sample appointments for the test user (only if they don't exist)
if test_user.appointments.empty?
  sample_appointments = [
    {
      service: Service.find_by(name: "Classic Facial"),
      appointment_date: Date.current + 3.days,
      appointment_time: Time.current.beginning_of_hour + 10.hours,
      status: "confirmed",
      notes: "First time visit, excited to try the classic facial!"
    },
    {
      service: Service.find_by(name: "Anti-Aging Treatment"),
      appointment_date: Date.current + 10.days,
      appointment_time: Time.current.beginning_of_hour + 14.hours,
      status: "pending",
      notes: "Interested in reducing fine lines around eyes"
    }
  ]

  sample_appointments.each do |appointment_data|
    next unless appointment_data[:service] # Skip if service doesn't exist

    Appointment.find_or_create_by!(
      user: test_user,
      service: appointment_data[:service],
      appointment_date: appointment_data[:appointment_date],
      appointment_time: appointment_data[:appointment_time]
    ) do |appointment|
      appointment.status = appointment_data[:status]
      appointment.notes = appointment_data[:notes]
    end
  end

  puts "Created #{test_user.appointments.count} sample appointments"
else
  puts "Test user already has appointments, skipping appointment creation"
end

# Create sample forum topics (only if they don't exist)
if ForumTopic.count == 0
  sample_topics = [
    {
      title: "Best Anti-Aging Products You've Tried",
      content: "I'm looking for recommendations for anti-aging products that actually work. I've tried several brands but haven't found the perfect combination yet. What products have you had success with? I'm particularly interested in serums and moisturizers that help with fine lines and skin texture.\n\nAlso, how long did it take you to see results? I know these things take time, but I'd love to hear about your experiences!"
    },
    {
      title: "Post-Facial Care Routine",
      content: "I just had my first facial treatment at Olga's Skin Secrets in New Bern and it was amazing! My skin feels so refreshed and clean. I want to make sure I'm taking proper care of it afterward.\n\nWhat's your post-facial routine? How long do you wait before applying makeup? Any specific products you avoid for the first few days? I'd love to hear your tips for maintaining that post-facial glow!"
    },
    {
      title: "Acne Treatment Success Stories",
      content: "I've been struggling with adult acne for the past year and it's really affecting my confidence. I'm considering booking an acne clearing facial but wanted to hear from others who have tried it.\n\nHas anyone here had success with professional acne treatments? How many sessions did it take to see improvement? Were there any side effects or things I should be aware of?\n\nI'm also curious about what you do between treatments to maintain results. Any advice would be greatly appreciated!"
    },
    {
      title: "Skincare Routine for Sensitive Skin",
      content: "I have very sensitive skin that tends to react to most products. I'm looking to build a gentle but effective skincare routine.\n\nWhat products do you recommend for sensitive skin? Are there any ingredients I should definitely avoid? I'm particularly interested in cleansers and moisturizers that won't cause irritation.\n\nAlso, has anyone with sensitive skin tried the treatments at Olga's Skin Secrets in New Bern? I'm a bit nervous about how my skin might react."
    }
  ]

  sample_topics.each do |topic_data|
    ForumTopic.find_or_create_by!(title: topic_data[:title]) do |topic|
      topic.user = test_user
      topic.content = topic_data[:content]
    end
  end

  puts "Created #{ForumTopic.count} sample forum topics"

  # Create some sample posts (only if they don't exist)
  topic = ForumTopic.first
  if topic && topic.forum_posts.empty?
    sample_posts = [
      {
        content: "I've been using a vitamin C serum from [brand] for the past 6 months and I've definitely noticed an improvement in my skin texture and brightness. It took about 3-4 weeks to see results, but it was worth the wait!"
      },
      {
        content: "For post-facial care, I usually wait at least 24 hours before applying makeup. I stick to gentle, fragrance-free products for the first few days and make sure to stay hydrated!"
      }
    ]

    sample_posts.each do |post_data|
      ForumPost.find_or_create_by!(
        user: test_user,
        forum_topic: topic,
        content: post_data[:content]
      )
    end

    puts "Created #{ForumPost.count} sample forum posts"
  end
else
  puts "Forum topics already exist, skipping forum content creation"
end

puts "\n🎉 Sample data created successfully!"
puts "\n📧 Admin user login:"
puts "   Email: admin@skinsecretsnc.com"
puts "   Password: skinsecrets"
puts "\n📧 Test user login:"
puts "   Email: test@example.com"
puts "   Password: password123"
puts "\n🌐 Visit http://localhost:3000 to explore your Olga's Skin Secrets website!"
