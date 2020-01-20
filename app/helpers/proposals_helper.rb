module ProposalsHelper

  def category_name(data)
    case data.category
    when 'M'
      Proposal::CATEGORY_NAME_M
    when 'R'
      Proposal::CATEGORY_NAME_R
    when ''
      ''
    else
      nil
    end  
  end

  def proposal_no_data
    # data =
    # '<div class="col-sm-12" class="clearfix">
    #   <div class="alert alert-info alert-dismissable">
    #     <a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
    #     <h2 class="center">' + t(".no_data") + '</h2>
    #   </div>
    # </div>'
    # data.html_safe

    data =
    '<fieldset class="my-fieldset">
        <legend class="my-fieldset">' + t(".no_data") + '</legend>
        <p class="center">' + t(".no_data_comment") + '</p>
     </fieldset>'

    data.html_safe
  end

  def proposal_rec_info(data)
    t('proposals.proposal.rec_info', data: "#{data.created_at.strftime('%Y-%m-%d %H:%M:%S')} [#{category_name(data)}][#{data.division_short_name}]")
  end

  def proposal_rec_status_name(data)
    t("proposals.status_id_#{data.proposal_status_id}_name")
  end

end
