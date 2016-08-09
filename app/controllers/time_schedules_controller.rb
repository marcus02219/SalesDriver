class TimeSchedulesController < ApplicationController
  before_filter :is_seller_or_admin_authenticate!
  before_action :set_seller

  def index
    render layout: false
  end

	def new
    @ts = TimeSchedule.new
	end

  def create
    @ts = @seller.time_schedules.new(ts_params)
    respond_to do |format|
      if @ts.save
        format.html { redirect_to schedule_setup_path(@seller) }
      else
        flash.now[:error] = @ts.errors.full_messages.to_sentence
        format.html { render :new  }
        format.json { render json: @ts.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @ts = TimeSchedule.find(params[:id])
  end

  def update
    @ts = TimeSchedule.find(params[:id])
    respond_to do |format|
      if @ts.update(ts_params)
        format.html { redirect_to schedule_setup_path(@seller) }
      else
        flash.now[:error] = @ts.errors.full_messages.to_sentence
        format.html { render :edit  }
        format.json { render json: @ts.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @ts = TimeSchedule.find(params[:id])
    if @ts.destroy
      redirect_to schedule_setup_path(@seller), notice: "Deleted interval time"
    else
      redirect_to schedule_setup_path(@seller), notice: "Can not delete interval time"
    end
  end
  protected
  def set_seller
    @seller = User.find(params[:seller_id])
  end
  def ts_params
    params.require(:time_schedule).permit(:start_time, :end_time, :breacked_time, :name)
  end
end
