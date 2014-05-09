xml.instruct!
xml.Response do
	if @invitation.invitees.empty?
		xml.Say "I'm sorry, I couldn't find a guest list for you. Please try again later. Goodbye."
	else
		xml.Say "Thanks. An invitation for #{@invitation.name} has been found."
		xml.Redirect twilio_set_invitee_attendance_path(@invitation.code, @invitation.invitees.first.id)
	end
end