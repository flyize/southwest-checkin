class ReservationsController < ApplicationController
  before_action :authenticate_or_redirect_to_signup!, only: :new
  before_action :authenticate_user!, except: :new
  before_action :current_user_only!
  before_action :set_user, only: [:index, :create]
  before_action :set_reservation, only: [:show, :edit, :update, :destroy]
  rescue_from Southwest::RequestArgumentError, with: :southwest_argument_error #, only: :create 

  respond_to :html

  def index
    @reservations = reservations
    respond_with(@reservations)
  end

  def show
    respond_with(@reservation)
  end

  def new
    @reservation = Reservation.new
    respond_with(@reservation)
  end

  def edit
  end

  def create
    @reservation = @user.reservations.new(reservation_params)
    @reservation.save
    if @reservation.valid?
      flash[:notice] = 'Your reservation has been added! You will receive an email when the passengers on this reservation have been successfully checked in.'
    end
    respond_with(@reservation)
  end

  def update
    @reservation.update(reservation_params)
    respond_with(@reservation)
  end

  def destroy
    @reservation.destroy
    respond_with(@reservation)
  end

  private

  def reservations
    if current_user.admin? && show_all?
      query = Reservation
    else
      query = @user.reservations
    end

    query.includes(:flights).order("flights.departure_time DESC").page(params[:page])
  end

  def show_all?
    params[:all] == 'true'
  end
  helper_method :show_all?

  def authenticate_or_redirect_to_signup!
    if user_signed_in?
      return true
    else
      flash[:notice] = 'Start by creating an account to track your reservations.'
      flash[:from_reservations] = true
      redirect_to new_registration_path(User.new)
    end
  end

  def southwest_argument_error
    flash[:notice] = 'Confirmation number, first name, and last name are required.'
    respond_with(@reservation)
  end

  def southwest_request_error
    flash[:notice] = 'Sorry! There was an error communicating with Southwest. This has been reported. Please try to add your flight later.'
    respond_with(@reservation)
  end

  def set_user
    @user = params[:user_id] ? User.find(params[:user_id]) : current_user
  end

  def set_reservation
    @reservation = Reservation.includes({ flights: [{ passenger_checkins: [:passenger] }, :departure_airport, :arrival_airport] }, :passengers).find(params[:id])
  end

  def reservation_params
    params.require(:reservation).permit(:confirmation_number, :first_name, :last_name)
  end

  def current_user_only!
    if !current_user.admin? && params[:id] && Reservation.find(params[:id]).user_id != current_user.id
      raise ActionController::RoutingError.new('Not Found')
    end

    super(params[:user_id])
  end
end
