module ApplicationHelper
  def authenticate_user!
    redirect_to root_url, :error => "You must be logged in to use this page." if current_user.nil?
  end

  def authenticate_admin!
    redirect_to root_url, :error => "You must be logged in as admin to use this page." if current_admin_user.nil?
  end

  def times_list
    times = []
    23.times.each do |ts|
      4.times.each do |tt|
        times << "#{'%02d' % ts}:#{'%02d' % (tt*15)}"
      end
    end
    times
  end

  def is_seller_or_admin_authenticate!
    if current_admin_user.present? or (current_user.present? and current_user.is_seller?)
      return true
    else
      redirect_to root_url, :notice => "You must be logged in as admin to use this page."
    end
  end
end
