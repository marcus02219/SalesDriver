class MonthlySchedulesController < ApplicationController
  before_filter :is_seller_or_admin_authenticate!
  before_action :set_seller

  def index
    year = params[:start_date].present? ? params[:start_date].to_date.year : Time.now.year
    month = params[:start_date].present? ? params[:start_date].to_date.month : Time.now.month
    @blocked_days = @seller.monthly_schedules.blocked_days(year, month)
    # render layout: false
  end

  def create
    @monthly_schedule = @seller.monthly_schedules.new(ms_params)
    if @monthly_schedule.save
      render json: {stats: :success, message: "set blocked day successfully"}
    else
      render json: {stats: :faild, message: @monthly_schedule.errors}
    end
  end

  def edit
    @monthly_schedule = @seller.monthly_schedules.where(blocked_day: params[:id]).first
    if @monthly_schedule.nil?
      @monthly_schedule = MonthlySchedule.new blocked_day: params[:id]
    end
    render layout: false
  end

  def update
    @monthly_schedule = @seller.monthly_schedules.find(params[:id])
    if @monthly_schedule.update(ms_params)
      render json: {stats: :success, message: "set blocked day successfully"}
    else
      render json: {stats: :faild, message: @monthly_schedule.errors}
    end
  end
 # TimeSchedule.where(:created_at.lt=>Time.now).count

  protected
  def set_seller
    @seller = User.find(params[:seller_id])
  end
  def ms_params
    params.require(:monthly_schedule).permit(:blocked_day, :repeat)
  end
end
