class Emailer < ActionMailer::Base  
  helper :application
  helper :observations
  helper :taxa
  helper :users

  SUBJECT_PREFIX = "[#{APP_CONFIG[:site_name]}]"

  default :from =>     "#{APP_CONFIG[:site_name]} <#{APP_CONFIG[:noreply_email]}>",
          :reply_to => APP_CONFIG[:noreply_email]
  
  def invite(address, params, current_user) 
    setup_email
    Invite.create(:user => current_user, :invite_address => address)
    content_type "text/plain"
    recipients address
    @subject << "#{params[:sender_name]} wants you to join them on iNaturalist" 
    @body = {
      :personal_message => params[:personal_message], 
      :sending_user => params[:sender_name], 
      :current_user => current_user
    }
    template "invite_send" 
  end
  
  def project_invitation_notification(project_invitation)
    return unless project_invitation
    return if project_invitation.observation.user.prefers_no_email
    obs_str = project_invitation.observation.to_plain_s(:no_user => true, 
      :no_time => true, :no_place_guess => true)
    @subject = "#{SUBJECT_PREFIX} #{project_invitation.user.login} invited your " + 
      "observation of #{project_invitation.observation.species_guess} " + 
      "to #{project_invitation.project.title}"
    @project = project_invitation.project
    @observation = project_invitation.observation
    @user = project_invitation.observation.user
    @inviter = project_invitation.user
    mail(:to => project_invitation.observation.user.email, :subject => @subject)
  end
  
  def updates_notification(user, updates)
    return if user.blank? || updates.blank?
    return if user.email.blank?
    return if user.prefers_no_email
    @user = user
    @grouped_updates = Update.group_and_sort(updates, :skip_past_activity => true)
    @update_cache = Update.eager_load_associates(updates)
    mail(
      :to => user.email,
      :subject => "#{SUBJECT_PREFIX} New updates, #{Date.today}"
    )
  end
end
