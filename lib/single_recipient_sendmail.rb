module SingleRecipientSendmail
  def self.included(clazz)
    clazz.class_eval do
      cattr_accessor :single_recipient_sendmail_settings
    end
  end
 
  def perform_delivery_single_recipient_sendmail(mail)
    mail.to = single_recipient_sendmail_settings[:to]
    mail.cc = nil
    mail.bcc = nil
    perform_delivery_sendmail mail
  end
end