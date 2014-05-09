class Invitation < ActiveRecord::Base
  attr_accessible :name, :email, :requests, :address, :notes, :timestamps, :invitees_attributes
  attr_accessor :rsvp_validation
  has_many :invitees
  accepts_nested_attributes_for :invitees, :allow_destroy => true
  validates_presence_of :address, :if => lambda { self.rsvp_validation }
  validates_associated :invitees

  # include ActiveModel::Dirty

  def num_attending
  	self.invitees.where(:attending => RSVP_ATTENDING_VALUES).count
  end

  def num_not_attending
    self.invitees.where(:attending => RSVP_NOT_ATTENDING_VALUES).count
  end
  
  def deliver
  	InvitationMailer.invitation_email(self).deliver
  	self.sent_at = DateTime.now
    self.save
  end
  handle_asynchronously :deliver

  def remind
    InvitationMailer.reminder_email(self).deliver
    self.sent_at = DateTime.now
    self.save
  end
  handle_asynchronously :remind

  def custom_email(subject, body)
    InvitationMailer.custom_email(self, subject, body).deliver
    self.sent_at = DateTime.now
    self.save
  end
  handle_asynchronously :custom_email

  def send_rsvp_notification
  	InvitationMailer.rsvp_notification(self).deliver
  end
  handle_asynchronously :send_rsvp_notification

  def send_rsvp_confirmation
    InvitationMailer.rsvp_confirmation(self).deliver
  end
  handle_asynchronously :send_rsvp_confirmation

end
