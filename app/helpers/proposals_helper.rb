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

  def rec_data_info(proposal)
    t('.rec_info', data: "#{proposal.created_at.strftime('%Y-%m-%d %H:%M:%S')} [#{category_name(proposal)}]")
  end

end
