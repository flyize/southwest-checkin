require 'rails_helper'

RSpec.describe Reservation, type: :model do
  fixtures :airports

  def recorded(cassette='record locator view multi LAX 2016-03-18')
    VCR.use_cassette(cassette) { yield }
  end

  let(:valid_attributes) {
    {
      confirmation_number: "ABC123",
      first_name: "Fuu",
      last_name: "Bar"
    }
  }

  describe 'creating a reservation' do
    describe 'with invalid attributes' do
      subject { Reservation.create }
      let(:invalid_attributes) {
        {
          confirmation_number: "ABC123",
          first_name: "Fuu",
          last_name: "Bar"
        }
      }

      # it { recorded { should accept_nested_attributes_for :user } }
      # it { recorded { should validate_presence_of :first_name } }
      # it { recorded { should validate_presence_of :last_name } }
      # it { recorded { should validate_presence_of :confirmation_number } }
      # it { recorded { should ensure_length_of(:confirmation_number).is_equal_to(6) } }

      context 'bad reservation information' do
        let(:cassette) { 'record locator view invalid 2016-03-18' }

        subject { Reservation.create(invalid_attributes) }

        it 'raise a validation error' do
          VCR.use_cassette(cassette) do
            expect(subject.valid?).to eql(false)
            expect(subject.errors[:base]).to eql [
              "Hmm, we can't find this reservation. Please double-check your information."
            ]
          end
        end
      end

      context 'viewAirReservation cancelled' do
        let(:cassette) { 'viewAirReservation cancelled' }

        subject { Reservation.create(invalid_attributes) }

        skip 'raise a validation error' do
          VCR.use_cassette(cassette) do
            expect(subject.errors[:base].first).to_not be_nil
          end
        end
      end

      # Confirmation numbers may be re-used
      context 'reservation already exists' do
        # Flight checkins are not scheduled unless they are in the future
        let(:before_all_departure_times) { Time.zone.parse('1 Jan 2015') }
        let(:cassette) { 'record locator view multi LAX 2016-03-18' }

        around :each do |example|
          VCR.use_cassette(cassette, allow_playback_repeats: true) do
            Timecop.freeze(before_all_departure_times) do
              example.run
            end
          end
        end

        let!(:existing_reservation) { Reservation.create!(valid_attributes) }
        subject(:duplicate_reservation) { Reservation.create(valid_attributes) }

        it 'does not support an already scheduled reservation' do
          expect(subject.errors[:confirmation_number]).to include('is already scheduled')
        end

        context 'when existing reservation has already been processed' do
          before { existing_reservation.checkins.update_all(completed_at: Time.now) }

          it { is_expected.to be_valid }
        end
      end
    end

    context 'international flight' do
      let(:cassette) { 'international flight Punta Cana DO' }
      subject { Reservation.create(valid_attributes) }

      skip "does not allow international flights (until they are supported)" do
        VCR.use_cassette(cassette) do
          expect(subject.valid?).to eql(false)
          expect(subject.errors[:base].first).to match /international flights are not yet supported/
        end
      end
    end

    shared_examples 'with valid attributes' do
      subject { Reservation.create(valid_attributes) }
      let(:passenger) { subject.passengers.first }

      it { VCR.use_cassette(cassette) { should be_valid } }

      it 'upcases the confirmation number' do
        VCR.use_cassette(cassette) do
          expect(subject.confirmation_number).to eql('ABC123')
        end
      end

      it 'creates at least one passenger' do
        VCR.use_cassette(cassette) do
          expect(passenger).to be_persisted
          expect(passenger.first_name).to_not be_nil
          expect(passenger.last_name).to_not be_nil
          expect(passenger.full_name).to_not be_nil
        end
      end

      it 'each passenger has a full name' do
        VCR.use_cassette(cassette) do
          subject.passengers.each do |passenger|
            expect(passenger.full_name).to_not be_nil
          end
        end
      end

      it 'each flight has a flight number' do
        VCR.use_cassette(cassette) do
          subject.flights.each do |flight|
            expect(flight.flight_number).to_not be_nil
          end
        end
      end
    end

    context 'one passenger, direct, 2 flights' do
      let(:cassette) { 'record locator view multi LAX 2016-03-18' }

      subject { Reservation.create(valid_attributes) }

      it_behaves_like 'with valid attributes'

      it 'creates two flights' do
        VCR.use_cassette(cassette) do
          expect(subject.flights.count).to eql(2)
        end
      end

      it 'creates one passenger' do
        VCR.use_cassette(cassette) do
          expect(subject.passengers.count).to eql(1)
        end
      end

      it 'schedules 2 checkins for both flights' do
        ActiveJob::Base.queue_adapter = :test
        VCR.use_cassette(cassette) do
          Timecop.freeze(Time.zone.parse('1 Jan 2015')) do
            expect{
              subject
            }.to have_enqueued_job.on_queue("checkin").exactly(:twice)
          end
        end
      end

      it 'enqueues the checkin 24hrs before departure' do
        ActiveJob::Base.queue_adapter = :test
        VCR.use_cassette(cassette) do
          Timecop.freeze(Time.zone.parse('1 Jan 2015')) do
            #Queue outgoing
            expect{
              subject
            }.to have_enqueued_job.on_queue("checkin")
            .at(Time.zone.parse("Wed, 23 Mar 2016 22:05:00 UTC +00:00")).exactly(:once)
            .at(Time.zone.parse("Sun, 27 Mar 2016 12:35:00 UTC +00:00")).exactly(:once)
            # Queue return trip
          end
        end
      end

      it 'does not enqueue flights in the past' do
        ActiveJob::Base.queue_adapter = :test
        VCR.use_cassette(cassette) do
          Timecop.freeze(Time.zone.parse('1 Apr 2016')) do
            expect{
              subject
            }.to have_enqueued_job.on_queue("checkin").exactly(0)
          end
        end
      end
    end
  end

  describe 'destroying a reservation that has been checked in' do
    let(:reservation_cassette) { 'record locator view multi LAX 2016-03-18' }
    let(:checkin_cassette) { 'record locator checkin LAX 2016-03-18' }
    let(:reservation) {
      Reservation.create({
        confirmation_number: "ABC123",
        first_name: "Fuu",
        last_name: "Bar"
      })
    }
    let(:flight) { reservation.flights.where(position: 1).first }

    # Flight checkins are not scheduled unless they are in the future
    let(:before_all_departure_times) { Time.zone.parse('1 Jan 2015') }

    before do
      VCR.use_cassette reservation_cassette do
        Timecop.freeze(before_all_departure_times) do
          reservation
        end
      end

      VCR.use_cassette checkin_cassette do
        perform_enqueued_jobs do
          CheckinJob.perform_later(flight)
        end
      end
    end

    it 'creates 4 flight checkins' do
      expect { reservation.destroy }.to_not raise_error
    end
  end
end
