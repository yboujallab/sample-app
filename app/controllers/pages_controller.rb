class PagesController < ApplicationController
  def home
  	@titre = "Accueil"
    if signed_in?
      @micropost = Micropost.new
      @feed_items = current_user.feed.paginate(:page => params[:page])
    end
    #@micropost = Micropost.new if signed_in?
  end

  def contact
  	@titre = "Contact"
  end

   def about
   	@titre = "À Propos"
  end
   def help
    @titre = "Aide"
  end
end
