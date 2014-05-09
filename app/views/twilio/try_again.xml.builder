xml.instruct!
xml.Response do
	xml.Gather(:numDigits => 4, :action => twilio_retrieve_invitation_path) {
		xml.Say "I'm sorry, that code doesn't seem to be valid. Please try again."
	}

	5.times do
		xml.Gather(:numDigits => 4, :action => twilio_retrieve_invitation_path) {
			xml.Say "I'm sorry, I didn't receive a valid number from you. Please enter your four digit invitation code now."
		}
	end

	xml.Say "I'm sorry, you seem to be having problems. Please try again later."
end