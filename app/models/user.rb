# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  nom        :string(255)
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#
require 'digest'
class User < ActiveRecord::Base

	attr_accessor :password
	has_many :microposts, :dependent => :destroy
	#relation standard pour les auteurs suiveurs
    has_many :relationships, :foreign_key => "follower_id",
                           :dependent => :destroy
	has_many :following, :through => :relationships, :source => :followed
	###Relations inversée pour les auteurs suivis 
	has_many :reverse_relationships, :foreign_key => "followed_id",
                                   :class_name => "Relationship",
                                   :dependent => :destroy
	has_many :followers, :through => :reverse_relationships, :source => :follower

	#attr_accessible :nom, :email, :password, :password_confirmation
	email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

	validates(:nom, :presence => true, :length   => { :maximum => 50 } )
			  
	validates(:email, :presence => true, :format   => { :with => email_regex },:uniqueness => { :case_sensitive => false })
	  # Crée automatique l'attribut virtuel 'password_confirmation'.
    validates :password, :presence     => true,
                       :confirmation => true,
                       :length       => { :within => 6..40 }
	before_save :encrypt_password

	  # Retour true (vrai) si le mot de passe correspond.
	  def has_password?(password_soumis)
	  	encrypted_password == encrypt(password_soumis)
	    # Compare encrypted_password avec la version cryptée de
	    # password_soumis.
	  end
	def self.authenticate(email, submitted_password)
		    user = find_by_email(email)
		    return nil  if user.nil?
		    return user if user.has_password?(submitted_password)
	 end
	 def self.authenticate_with_salt(id, cookie_salt)
		    user = find_by_id(id)
		    (user && user.salt == cookie_salt) ? user : nil
  	  end
  	def feed_old
        Micropost.where("user_id = ?", id)
  	end
  	def feed
    	 Micropost.from_users_followed_by(self)
  	end
	def following?(followed)
		relationships.find_by_followed_id(followed)
	end
	def follow!(followed)
	    relationships.create!(:followed_id => followed.id)
	end
	def unfollow!(followed)
    	relationships.find_by_followed_id(followed).destroy
  	end
	private

	    def encrypt_password
	        self.salt = make_salt if new_record?
      		self.encrypted_password = encrypt(password)
	    end

	    def encrypt(string)
	      secure_hash("#{salt}--#{string}")
	    end
		def make_salt
      		secure_hash("#{Time.now.utc}--#{password}")
    	end

    	def secure_hash(string)
      		Digest::SHA2.hexdigest(string)
    	end	    
end
