class ApplicationController < ActionController::Base
  protect_from_forgery

  #TODO move to ajax call when user clicks on notification button?
  def find_notifications
    if user_signed_in?
      @fresh_activities = current_user.get_new_notifications
      if @fresh_activities.count < 5
        @other_activities = current_user.activities.order('created_at DESC').first(5)
      end
    end
  end

  def check_admin
    unless current_user.is_admin
      redirect_to root_path, :alert => 'Unauthorized because you are not an administrator'
    end
  end

end
