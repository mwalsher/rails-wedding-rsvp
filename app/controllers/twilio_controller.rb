class TwilioController < ApplicationController
	before_filter :default_format_xml
	skip_before_filter :verify_authenticity_token

	def default_format_xml
	  request.format = "xml" # unless params[:format]
	end

	def receive

	end

	def retrieve_invitation
		@invitation = Invitation.where(:code => (params[:Digits].present? ? params[:Digits] : params[:code])).first

		if @invitation.nil?
			render "try_again"
			return
		else
			@invitation.phoned_in_at = DateTime.now
			@invitation.save
			session.delete :invitees_saved
			@invitation
		end
	end

	def set_invitee_attendance
		@invitation = Invitation.where(:code => params[:code]).first

		if session[:invitees_saved].nil?
			session[:invitees_saved] = []
		end

		@invitee = Invitee.find(params[:invitee_id])

		@invalid_entry = false
		if params[:Digits].present?
			case params[:Digits]
			when "1"
				@invitee.attending = RSVP_ATTENDING_VALUES.first
				@invitee.save
			when "2"
				@invitee.attending = RSVP_NOT_ATTENDING_VALUES.first
				@invitee.save
			else
				@invalid_entry = true
			end

			unless @invalid_entry
				session[:invitees_saved] << @invitee.id
				@invitee = @invitation.invitees.where(:invitation_id => @invitation.id).where("id not in (?)", session[:invitees_saved]).first
			end
		end

		if @invitee.nil?
			@invitation.responded_at = DateTime.now
			if @invitation.save
				@invitation.send_rsvp_notification
				render "finished"
			else
				render "error"
			end
		else
			@invitee
		end
	end
end