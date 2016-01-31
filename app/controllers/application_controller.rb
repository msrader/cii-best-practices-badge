class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Limit time before must log in again.
  before_action :validate_session_timestamp
  after_action :persist_session_timestamp

  include SessionsHelper
end
