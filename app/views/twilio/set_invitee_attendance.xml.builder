xml.instruct!
xml.Response do
	count = 0
	5.times {
		xml.Gather(:numDigits => 1, :action => twilio_set_invitee_attendance_path(@invitation.code, @invitee.id)) {
			if @invalid_entry || count > 0
				xml.Say "I'm sorry, I didn't receive a valid entry."
			else
				xml.Say "Okay."
			end

			if @invitee.guest
				xml.Say "Will you be bringing a guest to the wedding? Enter 1 for yes, or 2 for no."
			else
				xml.Say "Will #{@invitee.first_name} be coming to the wedding? Enter 1 for yes, or 2 for no."
			end
		}
		count += 1
	}
end