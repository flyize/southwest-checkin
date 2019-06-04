require 'rails_helper'

RSpec.describe Flight, :type => :model do
  it { should validate_presence_of :departure_time }
  it { should validate_presence_of :arrival_time }
  it { should validate_presence_of :departure_city }
  it { should validate_presence_of :arrival_city }
  it { should validate_presence_of :payload }
  it { should validate_presence_of :flight_type }
  it { should validate_presence_of :position }
  it { should validate_presence_of :reservation }
  it { should validate_presence_of :departure_airport }
  it { should validate_presence_of :arrival_airport }

  it { should belong_to :reservation }
  it { should belong_to :departure_airport }
  it { should belong_to :arrival_airport }
  it { should have_many :passenger_checkins }

  it { should define_enum_for(:flight_type).with_values(%w{departure return}) }

  describe 'time zones' do
    fixtures :reservations, :flights, :airports
    let(:den_to_abq) { reservations(:denver).flights.first }
    let(:aus_to_den) { reservations(:denver).flights.second }

    describe '#local_departure_time' do
      it 'DEN is MST' do
        expect(den_to_abq.local_departure_time).to eql(Time.parse('Fri, 16 Jan 2015 22:05:00 MST -07:00'))
      end

      it 'AUS is CST' do
        expect(aus_to_den.local_departure_time).to eql(Time.parse('Fri, 16 Jan 2015 20:10:00 CST -06:00'))
      end
    end

    describe '#local_arrival_time' do
      it 'ABQ is MST' do
        expect(den_to_abq.local_arrival_time).to eql(Time.parse('Fri, 16 Jan 2015 23:25:00 MST -07:00'))
      end

      it 'DEN is MST' do
        expect(aus_to_den.local_arrival_time).to eql(Time.parse('Fri, 16 Jan 2015 21:25:00 MST -07:00'))
      end
    end
  end
end
