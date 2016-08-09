class WeeklySchedulesController < ApplicationController
  before_filter :is_seller_or_admin_authenticate!
  before_action :set_seller

  def index
    render layout: false
  end

	def new
    @ws = WeeklySchedule.new
    @ws.time_schedules.build
	end

  def create
    @ws = @seller.weekly_schedules.new(ws_params)
    respond_to do |format|
      if @ws.save
        format.html { redirect_to schedule_setup_path(@seller) }
      else
        flash.now[:error] = @ws.errors.full_messages.to_sentence
        format.html { render :new  }
        format.json { render json: @ws.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @ws = WeeklySchedule.find(params[:id])
  end

  def update
    @ws = WeeklySchedule.find(params[:id])
    respond_to do |format|
      if @ws.update(ws_params)
        format.html { redirect_to schedule_setup_path(@seller) }
      else
        flash.now[:error] = @ws.errors.full_messages.to_sentence
        format.html { render :edit  }
        format.json { render json: @ws.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @ws = WeeklySchedule.find(params[:id])
    if @ws.destroy
      redirect_to schedule_setup_path(@seller), notice: "Deleted interval time"
    else
      redirect_to schedule_setup_path(@seller), notice: "Can not delete interval time"
    end
  end

  protected
  def set_seller
    @seller = User.find(params[:seller_id])
  end
  def ws_params
    params.require(:weekly_schedule).permit(
      :week,
      :work_day,
      :time_schedules_attributes=>[:id,:start_time, :end_time, :breacked_time, :name, :_destroy]
    )
  end
end
