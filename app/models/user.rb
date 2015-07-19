class User < ActiveRecord::Base

  has_secure_password
  has_many :proposals, dependent: :destroy
  acts_as_voter  # thumbs_up gem

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }
  validates :password, length: { minimum: 6 }, if: :password_required?

  before_save { self.email = email.downcase; self.political_party = political_party.delete(' ').upcase }
  before_create :create_remember_token

  default_scope -> { order('created_at DESC') }


  def first_name
    if is_name_public
      self.name.split(' ').first
    else 'Anónimo'
    end
  end

  def last_name
    if is_name_public
      self.name.split(' ').last
    else ''
    end
  end

  def short_name
    if(first_name != last_name)
      first_name + ' ' + last_name
    else
      first_name
    end
  end

  def welcome_name
    self.name.split(' ').first # ignores is_public_name
  end


  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.password_reset(self).deliver
  end


  private

    def password_required?
      new_record? || password.present?
    end

    def generate_token(column)
      begin
        self[column] = SecureRandom.urlsafe_base64
      end while User.exists?(column => self[column])
    end

    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end

end
