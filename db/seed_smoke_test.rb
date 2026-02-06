# Smoke Test Seed Data
# Usage: SEED=seed_smoke_test bin/rails db:seed:replant
# OR: bin/rails runner "load Rails.root.join('db/seed_smoke_test.rb')"
#
# This creates minimal data needed to test Telnyx SMS integration end-to-end:
# - Real Telnyx phone number on Agency
# - Real personal mobile number for Client
# - Policies with documents for testing card requests

puts "🧪 Starting smoke test seed..."

# Clear existing data
puts "🧹 Clearing existing data..."
[ AuditEvent, Delivery, MessageLog, Request, Document, Policy, Client, ConversationSession, User, Agency, Account ].each(&:destroy_all)

# Create Account (no Stripe required)
puts "🏦 Creating test account..."
account = Account.create!(
  name: "Smoke Test Agency",
  subscription_status: "active"
)

# Create Agency with REAL Telnyx number
puts "🏢 Creating agency with Telnyx number..."
agency = Agency.create!(
  name: "Smoke Test Insurance",
  phone_sms: "+12087108182",  # Real Telnyx number
  account: account,
  active: true
)

# Create owner User for admin access
puts "👤 Creating owner user..."
user = User.create!(
  account: account,
  first_name: "Smoke",
  last_name: "Test",
  email: "smoke@test.example",
  password: "password123",
  role: "owner"
)

# Create Client with REAL personal mobile number
puts "📱 Creating client with real phone number..."
client = Client.create!(
  agency: agency,
  first_name: "Test",
  last_name: "User",
  phone_mobile: "+19716783297"  # Real personal number for testing
)

# Create Policies for testing card requests
puts "📋 Creating test policies..."
policy1 = Policy.create!(
  client: client,
  label: "2020 Toyota Camry",
  policy_type: "auto",
  expires_on: 6.months.from_now
)

policy2 = Policy.create!(
  client: client,
  label: "2019 Honda Civic",
  policy_type: "auto",
  expires_on: 4.months.from_now
)

policy3 = Policy.create!(
  client: client,
  label: "789 Test Street",
  policy_type: "homeowners",
  expires_on: 8.months.from_now
)

# Create Documents with attached insurance cards
puts "📄 Creating insurance card documents..."
fixture_path = Rails.root.join("test/fixtures/files/sample_insurance_card.pdf")

[ policy1, policy2, policy3 ].each do |policy|
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

puts "\n✅ Smoke test seed complete!"
puts "\n📊 Summary:"
puts "  - Account: #{account.name}"
puts "  - Agency: #{agency.name}"
puts "  - Agency SMS: #{agency.phone_sms}"
puts "  - User Email: #{user.email}"
puts "  - User Password: password123"
puts "  - Client: #{client.first_name} #{client.last_name}"
puts "  - Client Phone: #{client.phone_mobile}"
puts "  - Policies: #{Policy.count} (#{client.policies.pluck(:label).join(', ')})"
puts "  - Documents: #{Document.count}"

puts "\n🧪 Testing Instructions:"
puts "  1. Text 'MENU' from #{client.phone_mobile} to #{agency.phone_sms}"
puts "  2. Watch logs with: kamal app logs --follow (production)"
puts "  3. Or watch with: bin/dev (local development)"
puts "  4. Test card request conversation flow"
puts "  5. Verify MMS with PDF attachment is received"
puts "\n📝 Admin Login:"
puts "  Email: #{user.email}"
puts "  Password: password123"
