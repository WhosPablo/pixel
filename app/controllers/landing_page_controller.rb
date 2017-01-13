class LandingPageController < ApplicationController
  layout "landing"
  respond_to :js


  def index
  end

  def request_demo
    interested_party = Interest.new(demo_requests_params)

    respond_to do |format|
      if interested_party.save
        format.js
        format.html
      else
        @messages = interested_party.errors.full_messages
        format.js { render :error, status: :unprocessable_entity }
        format.html
      end
    end
  end

  def ssl_test
    render text: "W9kBtlE5lndyGbETGPJUFYYU6olaYycgJ-LCOWhQIz4.eK6KRF2gjWey4vZl7VMEdMs0sTPVQPqE0FdSvOAq8nI"
  end

  private

  def demo_requests_params
    params.permit(:email)
  end
end
