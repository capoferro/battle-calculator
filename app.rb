require 'json'
require 'pp'
require 'rubygems'
require 'sinatra'
require File.dirname(__FILE__) + '/calculator'

get '/' do
  haml :index
end

post '/calculate' do
  @one = Figure.new params[:one]
  @two = Figure.new params[:two]
  results = BattleCalculator::to_win_duel(@one, @two, 5)


  new_results = {}
  results.each do |key, value|
    new_results[key] = "%.#{decimal_places_of BattleCalculator::ACCURACY}f" % (value*100)
  end
  new_results.to_json
end

private

def decimal_places_of float
  str = float.to_s
  position_of_point = str.index('.')
  if position_of_point.nil?
    0
  else
    str.size - (position_of_point + 1)
  end
end

