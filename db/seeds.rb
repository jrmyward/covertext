# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Clear existing data
puts "🧹 Clearing existing data..."
[ AuditEvent, Delivery, MessageLog, Request, Document, Policy, Contact, ConversationSession, User, Agency ].each(&:destroy_all)

# Create Agency
puts "🏢 Creating agency..."
agency = Agency.create!(
  name: "Reliable Insurance Agency",
  sms_phone_number: "+15551234567"  # Placeholder E.164 number for testing
)

# Create admin User
puts "👤 Creating admin user..."
user = User.create!(
  agency: agency,
  first_name: "John",
  last_name: "Admin",
  email: "john@reliableinsurance.example",
  password: "password123",
  role: "admin"
)

# Create Contacts
puts "📱 Creating contacts..."
contact1 = Contact.create!(
  agency: agency,
  first_name: "Alice",
  last_name: "Johnson",
  mobile_phone_e164: "+15559876543"
)

contact2 = Contact.create!(
  agency: agency,
  first_name: "Bob",
  last_name: "Smith",
  mobile_phone_e164: "+15559876544"
)

# Create Policies for each contact
puts "📋 Creating policies..."
policies = []

# Alice's policies
policies << Policy.create!(
  contact: contact1,
  label: "2018 Honda Accord",
  policy_type: "auto",
  expires_on: 6.months.from_now
)

policies << Policy.create!(
  contact: contact1,
  label: "2020 Toyota Camry",
  policy_type: "auto",
  expires_on: 8.months.from_now
)

policies << Policy.create!(
  contact: contact1,
  label: "2015 Ford F-150",
  policy_type: "auto",
  expires_on: 3.months.from_now
)

# Bob's policies
policies << Policy.create!(
  contact: contact2,
  label: "2019 Chevrolet Silverado",
  policy_type: "auto",
  expires_on: 4.months.from_now
)

policies << Policy.create!(
  contact: contact2,
  label: "2021 Tesla Model 3",
  policy_type: "auto",
  expires_on: 10.months.from_now
)

policies << Policy.create!(
  contact: contact2,
  label: "2017 Subaru Outback",
  policy_type: "auto",
  expires_on: 2.months.from_now
)

# Create Documents with attached files for each policy
puts "📄 Creating documents with insurance cards..."
fixture_path = Rails.root.join("test/fixtures/files/sample_insurance_card.pdf")

policies.each do |policy|
  doc = Document.create!(
    policy: policy,
    kind: "auto_id_card"
  )
  doc.file.attach(
    io: File.open(fixture_path),
    filename: "insurance_card_#{policy.label.parameterize}.pdf",
    content_type: "application/pdf"
  )
end

puts "\n✅ Seed data created successfully!"
puts "\n📊 Summary:"
puts "  - Agencies: #{Agency.count}"
puts "  - Users: #{User.count}"
puts "  - Contacts: #{Contact.count}"
puts "  - Policies: #{Policy.count}"
puts "  - Documents: #{Document.count}"
puts "  - Documents with files: #{Document.joins(:file_attachment).count}"
puts "\n📱 Test Phone Numbers:"
puts "  - Agency SMS: #{agency.sms_phone_number}"
puts "  - Alice Johnson: #{contact1.mobile_phone_e164}"
puts "  - Bob Smith: #{contact2.mobile_phone_e164}"
puts "\n👤 Admin Login:"
puts "  - Email: #{user.email}"
puts "  - Password: password123"
