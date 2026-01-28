# frozen_string_literal: true

class MarketingController < ApplicationController
  skip_before_action :require_authentication, only: [ :index ]

  def index
    # Public marketing homepage
  end
end
