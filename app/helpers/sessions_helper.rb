module SessionsHelper 
  #Methode pour créer le cookies et y enregitrer la token 
	def sign_in(user)
    cookies.permanent.signed[:remember_token] = [user.id, user.salt]
    self.current_user = user
  end
  #Methode pour setter l'utilisateur courant lors de l'authentification
  def current_user=(user)
    @current_user = user
  end
  #Methode pour récuperer renseigner l'utilisateur courant à partir du cookies et faciliter la navigation entre les pages
def current_user
    @current_user ||= user_from_remember_token
  end
  #Methode pour vérifier si l'utilistauer est connecté 
   def signed_in?
    !current_user.nil?
  end
  #Methode pour supprimer les cookiens en cas de déconnexion
  def sign_out
    cookies.delete(:remember_token)
    self.current_user = nil
  end 
  #methode our vérifier que l'utilisateur courant et à la base de l'action
  def current_user?(user)
    user == current_user
  end
#Methode pour sécuriser l'acces au pages
  def deny_access
    store_location
    redirect_to signin_path, :notice => "Merci de vous identifier pour rejoindre cette page."
  end 
#redirection de l'utilisateur vers la page désirée aprés l'authentification
def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    clear_return_to
  end  
 private
  #Methode pour vérifier l'authentification avec le cookies
    def user_from_remember_token
      User.authenticate_with_salt(*remember_token)
    end

    def remember_token
      cookies.signed[:remember_token] || [nil, nil]
    end 
    def store_location
      session[:return_to] = request.fullpath
    end

    def clear_return_to
      session[:return_to] = nil
    end
end
