module Agency::Readiness
  extend ActiveSupport::Concern

  def subscription_ready?
    account.subscription_active?
  end

  def phone_ready?
    phone_sms.present?
  end

  def fully_ready?
    subscription_ready? && phone_ready?
  end
end
