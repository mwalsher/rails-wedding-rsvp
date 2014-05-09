class InvitationMailer < ActionMailer::Base
	include SendGrid
	sendgrid_enable :opentrack
	default :from => "#{ENV['COUPLE_NAME']} <#{ENV['RSVP_EMAIL_FROM_ADDRESS']}>"

	def invitation_email(invitation)
		@invitation = invitation
		sendgrid_category "invitations"
		sendgrid_unique_args :invitation_id => invitation.id

		#attachments.inline["envelope.jpg"] = File.read(Rails.root.join('app/assets/images/envelope.jpg'))

		mail(:to => invitation.email, :subject => "You're invited to #{ENV['WEDDING_TITLE']}!")
	end

	def reminder_email(invitation)
		@invitation = invitation
		sendgrid_category "reminders"
		sendgrid_unique_args :invitation_id => invitation.id

		mail(:to => invitation.email, :subject => "Reminder: Please RSVP for #{ENV['COUPLE_NAME']}'s Wedding")
	end

	def custom_email(invitation, subject, body)
		@invitation = invitation
		sendgrid_category "miscellaneous"
		sendgrid_unique_args :invitation_id => invitation.id
		@body = body

		mail(:to => invitation.email, :subject => subject)
	end

	def rsvp_notification(invitation)
		@invitation = invitation
		sendgrid_category "notifications"
		sendgrid_unique_args :invitation_id => invitation.id

		mail(:from => "#{@invitation.name} <#{ENV['RSVP_EMAIL_FROM_ADDRESS']}>", :to => ENV['RSVP_NOTIFICATION_ADDRESS'], :subject => "RSVP response from " << @invitation.name)
	end

	def rsvp_confirmation(invitation)
		@invitation = invitation
		sendgrid_category "confirmations"
		sendgrid_unique_args :invitation_id => invitation.id

		mail(:to => @invitation.email, :subject => "Your RSVP has been received, thanks!")
	end
end