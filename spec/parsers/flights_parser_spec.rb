require 'rails_helper'

RSpec.describe FlightsParser do
  fixtures :airports

  let(:last_name) { 'Bar' }
  let(:first_name) { 'Fuu' }
  let(:record_locator) { 'ABC123' }
  let(:cassette) { 'record locator view multi LAX 2016-03-18' }
  let(:response) {
    Southwest::Reservation.retrieve_reservation(
      last_name: last_name,
      first_name: first_name,
      record_locator: record_locator)
  }

  subject {
    VCR.use_cassette cassette do
      FlightsParser.new(response.body)
    end
  }

  it 'extracts two flights' do
    expect(subject.flights.count).to eql(2)
  end

  it 'flight 1 is correct' do
    flight = subject.flights.first
    expect(flight[:departure_time]).to eql("2016-03-24T17:05:00.000-05:00")
    expect(flight[:arrival_time]).to eql("2016-03-24T18:40:00.000-07:00")
    expect(flight[:departure_city]).to eql("Kansas City Intl")
    expect(flight[:arrival_city]).to eql("Los Angeles Intl")
    expect(flight[:payload]).to_not be_nil
    expect(flight[:departure_airport].iata).to eql("MCI")
    expect(flight[:arrival_airport].iata).to eql("LAX")
    expect(flight[:flight_type]).to eql('departure')
    expect(flight[:position]).to eql(1)
    expect(flight[:flight_number]).to eql('1001')
  end

  it 'flight 2 is correct' do
    flight = subject.flights.second
    expect(flight[:departure_time]).to eql("2016-03-28T05:35:00.000-07:00")
    expect(flight[:arrival_time]).to eql("2016-03-28T10:50:00.000-05:00")
    expect(flight[:departure_city]).to eql("Los Angeles Intl")
    expect(flight[:arrival_city]).to eql("Kansas City Intl")
    expect(flight[:payload]).to_not be_nil
    expect(flight[:departure_airport].iata).to eql("LAX")
    expect(flight[:arrival_airport].iata).to eql("MCI")
    expect(flight[:flight_type]).to eql('return')
    expect(flight[:position]).to eql(1)
    expect(flight[:flight_number]).to eql('1002')
  end
end
