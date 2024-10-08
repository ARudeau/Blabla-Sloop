class Ride < ApplicationRecord
  belongs_to :sloop
  has_many :traveller_rides
  has_many :users, through: :traveller_rides
  validates :start_date, :end_date, presence: true
  validates :start_port, :end_port, presence: true
  validates :details, presence: true

  geocoded_by :start_port, latitude: :start_port_latitude, longitude: :start_port_longitude

  after_validation :geocode_start_port, if: :will_save_change_to_start_port?
  after_validation :geocode_end_port, if: :will_save_change_to_end_port?

  def max_capacity_reached?
    capacity == traveller_rides.where(validate_status: "accepted").count

    # if capacity == traveller_rides.where(validate_status: "accepted").count
    #   true
    # else
    #   false
    # end
  end

  def skipper
    sloop.user
  end

  # Retourne vrai si il existe un ride entre deux users
  def self.ride_exist?(user1, user2)
    # test1 => les deux users ont ils un ride en commun as voyageur
    user1_traveller_rides = user1.traveller_rides
    user2_traveller_rides = user2.traveller_rides
    test1 = user1_traveller_rides.any? { |traveller_ride| traveller_ride.ride.users.include?(user2) } || user2_traveller_rides.any? {|traveller_ride| traveller_ride.ride.users.include?(user1) }
    # test2 => le user1 a t il voyager avec le skipper user2?
    # tester si les user1.rides.exist?
    test2 = user1_traveller_rides.any? { |traveller_ride| traveller_ride.ride.skipper == user2 }
    test1 || test2
  end

  private

  def geocode_start_port
    geocode
  end

  # Méthode pour géocoder le port d'arrivée
  def geocode_end_port
    return if end_port.blank?

    results = Geocoder.search(end_port)
    self.end_port_latitude, self.end_port_longitude = results.first.coordinates
  end

end
