rails-wedding-rsvp
==================

rails-wedding-rsvp is a Rails 3.2 app for an online wedding invitation and RSVP website. I whipped the app together when my wife and I were married in August 2013. Feel free to fork the project and use for your own personal use.

### Features

- Wedding splash page (responsive) with countdown and invitation lookup by guest name (you'll want to replace the photograph with your own ;))
- Mass send wedding invitations via email (using SendGrid)
- Email open tracking
- Send email reminders
- Easy-to-use RSVP response page with status and special requests for each guest
- RSVP response email alerts
- Optional RSVP response by phone using Twilio
- Admin reporting for invitation status and email open tracking

### Notes

- Quick and dirty implementation; in need of some refactoring/genericization. Feel free to contribute!
- I left our invitation content in place in case someone wants to use the template as an example, but you'll obviously want to replace the details with your own
- Variables like couple name, wedding title, date, etc. are set in config/application.yml (create your own from config/application.example.yml)
- Other constants like RSVP responses are defined in config/initializers/constants
- I just extracted these constants without testing anything, so there may be bugs! (Just wanted to get this up on github quickly for a friend)
- You'll want to replace the home/splash page with your own photo/style (see app/views/invitations/lookup.html.erb)
- You'll want to replace the invitation content/style with your own (see app/views/invitations/view.html.erb)
- No tests :(

### Twilio Notes

- You'll need to set up a phone endpoint in Twilio that points to http://yourdomain.com/phone/receive.xml

Feel free to submit a pull request with any feature additions/code cleanup if you'd like!
