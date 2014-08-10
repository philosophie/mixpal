class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include Mixpal::Integration
  mixpanel_identity :current_user, :email

  private

  def current_user
    Struct.new(:email).new('nick@gophilosophie.com')
  end
end
