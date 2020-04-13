class Patient < ApplicationRecord
  devise :database_authenticatable, :registerable, :rememberable, :authentication_keys => [:cpf]

  MAX_LOGIN_ATTEMPTS = 2.freeze

  has_many :appointments, dependent: :destroy
  belongs_to :main_ubs, class_name: 'Ubs'

  validates :name, presence: true
  validates :cpf, presence: true, uniqueness: true, cpf_format: true
  validates :mother_name, presence: true
  validates :birth_date, presence: true
  validates :phone, presence: true
  validates :neighborhood, presence: true

  after_initialize :set_main_ubs

  scope :bedridden, -> { where(bedridden: true) }

  def active_appointments
    appointments.select(&:active?)
  end

  def set_main_ubs
    self.main_ubs ||= Neighborhood.find_by(name: neighborhood)&.active_ubs&.sample || Ubs.active.sample
  end

  def email_required?
    false
  end

  def email_changed?
    false
  end

  def increase_login_attempts
    update!(login_attempts: login_attempts + 1)
  end

  def remaining_attempts
    MAX_LOGIN_ATTEMPTS - login_attempts
  end

  def blocked?
    login_attempts >= MAX_LOGIN_ATTEMPTS
  end

  def bedridden?
    bedridden == true
  end

  def unblock!
    update!(login_attempts: 0)
  end

  def encrypted_password
    ''
  end
end
