module ProposalsHelper

  def category_name(proposal)
    case proposal.category
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

  def proposal_rec_info(proposal)
    t('proposals.proposal.rec_info', data: "#{proposal.created_at.strftime('%Y-%m-%d %H:%M:%S')} [#{category_name(proposal)}]")
  end

  def proposal_no_data
    data =
    '<div class="col-sm-12" class="clearfix">
      <div class="alert alert-info alert-dismissable">
        <a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
        <h2 class="center">' + t(".no_data") + '</h2>
      </div>
    </div>'
    data.html_safe




  end


end
