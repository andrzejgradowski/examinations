class StaticPagesController < ApplicationController

  caches_page :home, :gzip => :best_speed

  def home
  end

end
