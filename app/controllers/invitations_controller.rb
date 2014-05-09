class InvitationsController < ApplicationController
  # layout Proc.new{ ['lookup', 'view', 'rsvp', 'thanks'].include?(action_name) ? 'public' : 'application' }
  layout "public", :only => [:lookup, :view, :rsvp, :thanks, :engagement_story]
  before_filter :authenticate_user!, :except => [:lookup, :view, :rsvp, :thanks, :track, :engagement_story]
  load_resource :except => [:index, :create, :lookup, :view, :rsvp, :thanks, :track, :engagement_story]
  authorize_resource :except => [:lookup, :view, :rsvp, :thanks, :track, :engagement_story]
  helper_method :sort_column, :sort_direction

  def index
    case params[:filter]
    when "not_responded"
      @invitations = Invitation.where(:responded_at => nil).order(sort_column + " " + sort_direction)
    when "responded"
      @invitations = Invitation.where("responded_at IS NOT NULL").order(sort_column + " " + sort_direction)
    when "attending"
      @invitations = Invitation.joins(:invitees).where(:invitees => { :attending => RSVP_ATTENDING_VALUES }).group("invitations.id").order(sort_column + " " + sort_direction)
    when "not_attending"
      @invitations = Invitation.joins(:invitees).where(:invitees => { :attending => RSVP_NOT_ATTENDING_VALUES }).group("invitations.id").order(sort_column + " " + sort_direction)
    else
      @invitations = Invitation.order(sort_column + " " + sort_direction)
    end

    respond_to do |format|
      format.js { }
      format.html {
        # index.html.erb
        @num_invitees = Invitee.all.count
        @num_attending = Invitee.where(:attending => RSVP_ATTENDING_VALUES).count
        @num_not_attending = Invitee.where(:attending => RSVP_NOT_ATTENDING_VALUES).count
      }
      # format.json { render json: @invitations }
    end
  end

  def show
    @invitation = Invitation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      # format.json { render json: @invitation }
    end
  end

  def new
    @invitation = Invitation.new

    respond_to do |format|
      format.html # new.html.erb
      # format.json { render json: @invitation }
    end
  end

  def edit
    @invitation = Invitation.find(params[:id])
  end

  def create
    @invitation = Invitation.new(params[:invitation])
    @invitation.code = Random.new.rand(1000..9999)
    reset_guest_names

    respond_to do |format|
      if @invitation.save
        format.html { redirect_to invitations_url, notice: 'Invitation was successfully created.' }
        # format.json { render json: @invitation, status: :created, location: @invitation }
      else
        format.html { render action: "new" }
        # format.json { render json: @invitation.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @invitation = Invitation.find(params[:id])

    @invitation.assign_attributes(params[:invitation])
    reset_guest_names

    respond_to do |format|
      if @invitation.save
        format.html { redirect_to invitations_url, notice: 'Invitation was successfully updated.' }
        # format.json { head :no_content }
      else
        format.html { render action: "edit" }
        # format.json { render json: @invitation.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @invitation = Invitation.find(params[:id])
    @invitation.destroy

    respond_to do |format|
      format.html { redirect_to invitations_url }
      # format.json { head :no_content }
    end
  end

  def deliver
    @invitation = Invitation.find(params[:id])
    @invitation.deliver

    respond_to do |format|
        format.html { redirect_to invitations_url, notice: "Invitation will be sent shortly" }
        # format.json { render json: @invitation, status: :created, location: @invitation }
    end
  end

  def email_multiple
    respond_to do |format|
      # render :text => params.inspect
      # return 
      if params[:invitation_ids].blank? || params[:invitation][:email_type].blank?
        format.html { redirect_to invitations_url, :flash => { error: "Please ensure you've selected at least one invitation and an email type" } }
      else
        case params[:invitation][:email_type]
        when "invitation"
          email_method = :deliver
        when "reminder"
          email_method = :remind
        when "custom"
          email_method = :custom_email
          send_params = [params[:invitation][:email_subject], params[:invitation][:email_body]]
        end

        params[:invitation_ids].each do |invitation_id|
          Invitation.where(:id => invitation_id).first.send(email_method, *send_params)
        end
        format.html { redirect_to invitations_url, notice: "Emails will be sent shortly" }
      end
    end
  end

  def remind
    @invitation = Invitation.find(params[:id])
    @invitation.remind

    respond_to do |format|
        format.html { redirect_to invitations_url, notice: "Reminder will be sent shortly" }
    end
  end

  def track
    @invitation = Invitation.where(:code => params[:code]).first
    @invitation.opened_at = DateTime.now
    @invitation.save
    send_file Rails.root.join("app/assets/images/pixel.png"), type: "image/png", disposition: "inline"
  end

  def lookup
    if request.post? and params[:invitee].present?
      
      if params[:invitee][:first_name].blank? or params[:invitee][:last_name].blank?
        @error_message = "Please enter your first and last name below"
        render action: "lookup"
        return
      end

      invitee = Invitee.where("lower(first_name) = ? and lower(last_name) = ?", params[:invitee][:first_name].downcase, params[:invitee][:last_name].downcase).first
      if invitee.nil?
        @error_message = "Your invitation could not be found :( Please check the spelling or try another name."
        render action: "lookup"
        return
      else
        redirect_to view_invitation_path(invitee.invitation.code)
      end
    end
  end

  def view
    @invitation = Invitation.where(:code => params[:code]).first || not_found
    
    if !user_signed_in?
      @invitation.last_viewed_at = DateTime.now
      @invitation.save
    end
  end

  def rsvp
    @invitation = Invitation.where(:code => params[:code]).first || not_found
    @invitation.rsvp_validation = true
    @invitation.invitees.each do |invitee| invitee.rsvp_validation = true end

    if params[:invitation]
      @invitation.assign_attributes(params[:invitation])
      @invitation.responded_at = DateTime.now
      if @invitation.save
        @invitation.send_rsvp_notification
        @invitation.send_rsvp_confirmation
        redirect_to rsvp_thanks_path(@invitation.code)
      else
        flash.now[:error] = "Please correct the errors highlighted in red below"
        render action: "rsvp"
      end
    end
  end

  def thanks
    @invitation = Invitation.where(:code => params[:code]).first || not_found
  end

  def engagement_story
    if params[:code] and Invitation.where(:code => params[:code]).first
      @code = params[:code]
    end
  end

  private

  def reset_guest_names
    @invitation.invitees.each do |invitee|
      if invitee.guest
        invitee.first_name = nil
        invitee.last_name = nil
      end
    end
  end

  def sort_column
    Invitation.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

end
