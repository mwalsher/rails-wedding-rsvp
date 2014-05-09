class Invitee < ActiveRecord::Base
  attr_accessible :guest, :first_name, :last_name, :position, :attending
  attr_accessor :rsvp_validation

  belongs_to :invitation

  validates_presence_of :attending, :if => lambda { self.rsvp_validation }
  validates_presence_of :first_name, :last_name, :unless => proc { |i| i.guest }, :message => "is required"
  
end
