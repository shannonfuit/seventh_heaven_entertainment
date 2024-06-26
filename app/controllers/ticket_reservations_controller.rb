class TicketReservationsController < ApplicationController
  before_action :set_event, only: %i[new create show]

  def show
    @ticket_reservation = TicketReservation.find_by!(reference: params[:reservation_reference])

    respond_to do |format|
      format.html { render :show }
    end
  end

  def new
    @ticket_reservation = TicketReservation.new

    respond_to do |format|
      format.html { render :new }
    end
  end

  def create
    reservation_reference = SecureRandom.uuid

    TicketSaleService.reserve_tickets(
      event_id: params[:event_id],
      quantity: reservation_params[:quantity],
      reference: reservation_reference
    )
    @ticket_reservation = TicketReservation.find_by!(reference: reservation_reference)
    add_reservation_reference_to_session

    respond_to do |format|
      format.html { redirect_to event_ticket_reservation_path(@event, @ticket_reservation) }
    end
    # rescue => e
    #   TODO: handle errors from ticketsaleservice, like invalid quantity
  end

  def expire
    TicketReservation.find_by(reference: params[:reservation_reference])&.destroy
    remove_reservation_reference_from_session

    respond_to do |format|
      format.html { redirect_to root_path, notice: I18n.t("reservation.expired") }
    end
  end

  def cancel
    TicketReservation.find_by(reference: params[:reservation_reference])&.destroy
    remove_reservation_reference_from_session

    respond_to do |format|
      format.html { redirect_to root_path, notice: I18n.t("reservation.no_availability") }
    end
  end

  private

  def add_reservation_reference_to_session
    Rails.cache.write(@ticket_reservation.reference, true, expires_in: 1.hour)
    session[:reservation_reference] = @ticket_reservation.reference
  end

  def remove_reservation_reference_from_session
    return unless session[:reservation_reference]
    Rails.cache.delete(session[:reservation_reference])
    session.delete(:reservation_reference)
  end

  def set_event
    @event = Event.find(params[:event_id])
  end

  def reservation_params
    params.require(:ticket_reservation).permit(:quantity)
  end
end
