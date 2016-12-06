class ApplicationController < ActionController::Base
  protect_from_forgery
  before_action :find_notifications

  #TODO move to ajax call when user clicks on notification button?
  def find_notifications
    if user_signed_in?
      @fresh_activities = current_user.get_new_notifications
      if @fresh_activities.count < 5
        @other_activities = current_user.activities.order('created_at DESC').first(5)
      end
    end
  end

end
