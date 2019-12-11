class ProposalMailer < ApplicationMailer
  include ProposalsHelper
  default template_path: 'proposal_mailer' # to make sure that your mailer uses the devise views
  default from: Rails.application.secrets.email_provider_username
  default cc: Rails.application.secrets.email_provider_username

  def created(proposal)
    @proposal = proposal
    @proposal_fullname = "#{proposal_rec_info(@proposal)}"
    @proposal_url_uuid = Rails.application.routes.url_helpers.url_for(only_path: false, controller: 'proposals', action: 'show', multi_app_identifier: @proposal.multi_app_identifier, locale: locale)

    attachments.inline['logo_app.jpg'] = File.read("app/assets/images/logo_application.png")
    attachments.inline['logo_uke.jpg'] = File.read("app/assets/images/logo_uke_pl_do_lewej_small.png")

    mail(to: @proposal.creator.email, subject: "#{t('description')} - #{@proposal_fullname}" )
  end

  def approved(proposal)
    @proposal = proposal
    @proposal_fullname = "#{proposal_rec_info(@proposal)}"
    @proposal_url_uuid = Rails.application.routes.url_helpers.url_for(only_path: false, controller: 'proposals', action: 'show', multi_app_identifier: @proposal.multi_app_identifier, locale: locale)

    attachments.inline['logo_app.jpg'] = File.read("app/assets/images/logo_application.png")
    attachments.inline['logo_uke.jpg'] = File.read("app/assets/images/logo_uke_pl_do_lewej_small.png")

    mail(to: @proposal.creator.email, subject: "#{t('description')} - #{@proposal_fullname}" )
  end

  def not_approved(proposal)
    @proposal = proposal
    @proposal_fullname = "#{proposal_rec_info(@proposal)}"
    @proposal_url_uuid = Rails.application.routes.url_helpers.url_for(only_path: false, controller: 'proposals', action: 'show', multi_app_identifier: @proposal.multi_app_identifier, locale: locale)

    attachments.inline['logo_app.jpg'] = File.read("app/assets/images/logo_application.png")
    attachments.inline['logo_uke.jpg'] = File.read("app/assets/images/logo_uke_pl_do_lewej_small.png")

    mail(to: @proposal.creator.email, subject: "#{t('description')} - #{@proposal_fullname}" )
  end

  def closed(proposal)
    @proposal = proposal
    @proposal_fullname = "#{proposal_rec_info(@proposal)}"
    @proposal_url_uuid = Rails.application.routes.url_helpers.url_for(only_path: false, controller: 'proposals', action: 'show', multi_app_identifier: @proposal.multi_app_identifier, locale: locale)

    attachments.inline['logo_app.jpg'] = File.read("app/assets/images/logo_application.png")
    attachments.inline['logo_uke.jpg'] = File.read("app/assets/images/logo_uke_pl_do_lewej_small.png")

    mail(to: @proposal.creator.email, subject: "#{t('description')} - #{@proposal_fullname}" )
  end

  def annulled(proposal)
    @proposal = proposal
    @proposal_fullname = "#{proposal_rec_info(@proposal)}"
    @proposal_url_uuid = Rails.application.routes.url_helpers.url_for(only_path: false, controller: 'proposals', action: 'show', multi_app_identifier: @proposal.multi_app_identifier, locale: locale)

    attachments.inline['logo_app.jpg'] = File.read("app/assets/images/logo_application.png")
    attachments.inline['logo_uke.jpg'] = File.read("app/assets/images/logo_uke_pl_do_lewej_small.png")

    mail(to: @proposal.creator.email, subject: "#{t('description')} - #{@proposal_fullname}" )
  end

  def examination_result_b(proposal)
    @proposal = proposal
    @proposal_fullname = "#{proposal_rec_info(@proposal)}"
    @proposal_url_uuid = Rails.application.routes.url_helpers.url_for(only_path: false, controller: 'proposals', action: 'show', multi_app_identifier: @proposal.multi_app_identifier, locale: locale)

    attachments.inline['logo_app.jpg'] = File.read("app/assets/images/logo_application.png")
    attachments.inline['logo_uke.jpg'] = File.read("app/assets/images/logo_uke_pl_do_lewej_small.png")

    mail(to: @proposal.creator.email, subject: "#{t('description')} - #{@proposal_fullname}" )
  end

  def examination_result_n(proposal)
    @proposal = proposal
    @proposal_fullname = "#{proposal_rec_info(@proposal)}"
    @proposal_url_uuid = Rails.application.routes.url_helpers.url_for(only_path: false, controller: 'proposals', action: 'show', multi_app_identifier: @proposal.multi_app_identifier, locale: locale)

    attachments.inline['logo_app.jpg'] = File.read("app/assets/images/logo_application.png")
    attachments.inline['logo_uke.jpg'] = File.read("app/assets/images/logo_uke_pl_do_lewej_small.png")

    mail(to: @proposal.creator.email, subject: "#{t('description')} - #{@proposal_fullname}" )
  end

  def examination_result_o(proposal)
    @proposal = proposal
    @proposal_fullname = "#{proposal_rec_info(@proposal)}"
    @proposal_url_uuid = Rails.application.routes.url_helpers.url_for(only_path: false, controller: 'proposals', action: 'show', multi_app_identifier: @proposal.multi_app_identifier, locale: locale)

    attachments.inline['logo_app.jpg'] = File.read("app/assets/images/logo_application.png")
    attachments.inline['logo_uke.jpg'] = File.read("app/assets/images/logo_uke_pl_do_lewej_small.png")

    mail(to: @proposal.creator.email, subject: "#{t('description')} - #{@proposal_fullname}" )
  end

  def examination_result_p(proposal)
    @proposal = proposal
    @proposal_fullname = "#{proposal_rec_info(@proposal)}"
    @proposal_url_uuid = Rails.application.routes.url_helpers.url_for(only_path: false, controller: 'proposals', action: 'show', multi_app_identifier: @proposal.multi_app_identifier, locale: locale)

    attachments.inline['logo_app.jpg'] = File.read("app/assets/images/logo_application.png")
    attachments.inline['logo_uke.jpg'] = File.read("app/assets/images/logo_uke_pl_do_lewej_small.png")

    mail(to: @proposal.creator.email, subject: "#{t('description')} - #{@proposal_fullname}" )
  end

  def examination_result_z(proposal)
    @proposal = proposal
    @proposal_fullname = "#{proposal_rec_info(@proposal)}"
    @proposal_url_uuid = Rails.application.routes.url_helpers.url_for(only_path: false, controller: 'proposals', action: 'show', multi_app_identifier: @proposal.multi_app_identifier, locale: locale)

    attachments.inline['logo_app.jpg'] = File.read("app/assets/images/logo_application.png")
    attachments.inline['logo_uke.jpg'] = File.read("app/assets/images/logo_uke_pl_do_lewej_small.png")

    mail(to: @proposal.creator.email, subject: "#{t('description')} - #{@proposal_fullname}" )
  end

end

# preview
# http://localhost:3000/rails/mailers/status_mailer/project_status_email.html