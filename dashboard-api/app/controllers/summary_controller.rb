require 'uri'
require 'net/http'

class SummaryController < ApplicationController
  def show
    render json: {"message": "Welcome to the Summary Dashboard"}
    return 
  end
end
