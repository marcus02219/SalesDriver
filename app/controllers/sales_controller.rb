class SalesController < ApplicationController
  before_filter :is_seller_or_admin_authenticate!
  before_action :set_sales, only: [:schedule_setup, :interval_setup, :weekly_setup, :monthly_setup,
        :set_interval_setup, :set_weekly_setup, :set_monthly_setup]

  def index
    @users = User.all
  end

  def schedule_setup
    @ts = TimeSchedule.new
  end

  def interval_setup
    @ts = TimeSchedule.new
    render layout: false
  end
  def weekly_setup
    render layout: false
  end
  def monthly_setup
    render layout: false
  end

  protected
  def set_sales
    @seller = User.find(params[:id])
  end

  
end
