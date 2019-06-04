require 'rails_helper'

RSpec.describe ReservationsController, :type => :controller do
  fixtures :airports

  let(:user) { User.create(email: 'foo@bar.com', password: 'password') }

  let(:valid_attributes) {
    {
      confirmation_number: "ABC123",
      first_name: 'Fuu',
      last_name: 'Bar'
    }
  }

  let(:invalid_attributes) {
    {
      confirmation_number: "ABC123",
    }
  }

  let(:valid_session) { {} }

  before do
#    sign_in :user, user
    sign_in user, scope: :user
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Reservation" do
        VCR.use_cassette 'record locator view multi LAX 2016-03-18' do
          expect {
            post :create, params: {:reservation => valid_attributes}, session: valid_session
          }.to change(Reservation, :count).by(1)
        end
      end

      it "it is the current user's reservation" do
        VCR.use_cassette 'record locator view multi LAX 2016-03-18' do
          expect {
            post :create, params: {:reservation => valid_attributes}, session: valid_session
          }.to change(Reservation, :count).by(1)
        end
      end

      it 'creates two new flights' do
        VCR.use_cassette 'record locator view multi LAX 2016-03-18' do
          expect {
            post :create, params: {:reservation => valid_attributes}, session: valid_session
          }.to change(user.reservations, :count).by(1)
        end
      end

      it 'creates one passenger' do
        VCR.use_cassette 'record locator view multi LAX 2016-03-18' do
          expect {
            post :create, params: {:reservation => valid_attributes}, session: valid_session
          }.to change(Passenger, :count).by(1)
        end
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved reservation as @reservation" do
        VCR.use_cassette 'record locator view multi LAX 2016-03-18' do
          post :create, params: {:reservation => invalid_attributes}, session: valid_session
          expect(assigns(:reservation)).to be_a_new(Reservation)
        end
      end

      it "re-renders the 'new' template" do
        VCR.use_cassette 'record locator view multi LAX 2016-03-18' do
          post :create, params: {:reservation => invalid_attributes}, session: valid_session
          expect(flash[:notice]).to eql('Confirmation number, first name, and last name are required.')
        end
      end
    end
  end

  # describe "GET index" do
  #   it "assigns all reservations as @reservations" do
  #     reservation = Reservation.create! valid_attributes
  #     get :index, {}, valid_session
  #     expect(assigns(:reservations)).to eq([reservation])
  #   end
  # end

  # describe "GET show" do
  #   it "assigns the requested reservation as @reservation" do
  #     reservation = Reservation.create! valid_attributes
  #     get :show, {:id => reservation.to_param}, valid_session
  #     expect(assigns(:reservation)).to eq(reservation)
  #   end
  # end

  # describe "GET new" do
  #   it "assigns a new reservation as @reservation" do
  #     get :new, {}, valid_session
  #     expect(assigns(:reservation)).to be_a_new(Reservation)
  #   end
  # end

  # describe "GET edit" do
  #   it "assigns the requested reservation as @reservation" do
  #     reservation = Reservation.create! valid_attributes
  #     get :edit, {:id => reservation.to_param}, valid_session
  #     expect(assigns(:reservation)).to eq(reservation)
  #   end
  # end

  # describe "PUT update" do
  #   describe "with valid params" do
  #     let(:new_attributes) {
  #       skip("Add a hash of attributes valid for your model")
  #     }

  #     it "updates the requested reservation" do
  #       reservation = Reservation.create! valid_attributes
  #       put :update, {:id => reservation.to_param, :reservation => new_attributes}, valid_session
  #       reservation.reload
  #       skip("Add assertions for updated state")
  #     end

  #     it "assigns the requested reservation as @reservation" do
  #       reservation = Reservation.create! valid_attributes
  #       put :update, {:id => reservation.to_param, :reservation => valid_attributes}, valid_session
  #       expect(assigns(:reservation)).to eq(reservation)
  #     end

  #     it "redirects to the reservation" do
  #       reservation = Reservation.create! valid_attributes
  #       put :update, {:id => reservation.to_param, :reservation => valid_attributes}, valid_session
  #       expect(response).to redirect_to(reservation)
  #     end
  #   end

  #   describe "with invalid params" do
  #     it "assigns the reservation as @reservation" do
  #       reservation = Reservation.create! valid_attributes
  #       put :update, {:id => reservation.to_param, :reservation => invalid_attributes}, valid_session
  #       expect(assigns(:reservation)).to eq(reservation)
  #     end

  #     it "re-renders the 'edit' template" do
  #       reservation = Reservation.create! valid_attributes
  #       put :update, {:id => reservation.to_param, :reservation => invalid_attributes}, valid_session
  #       expect(response).to render_template("edit")
  #     end
  #   end
  # end

  # describe "DELETE destroy" do
  #   it "destroys the requested reservation" do
  #     reservation = Reservation.create! valid_attributes
  #     expect {
  #       delete :destroy, {:id => reservation.to_param}, valid_session
  #     }.to change(Reservation, :count).by(-1)
  #   end

  #   it "redirects to the reservations list" do
  #     reservation = Reservation.create! valid_attributes
  #     delete :destroy, {:id => reservation.to_param}, valid_session
  #     expect(response).to redirect_to(reservations_url)
  #   end
  # end
end
