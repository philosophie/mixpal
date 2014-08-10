class RedirectsController < ApplicationController
  def new
    mixpanel.track 'Root'
  end

  def to_root
    mixpanel.track 'Redirecting back to root'
    redirect_to root_path
  end
end
