module ApplicationHelper

  # for layouts/messages
  def flash_class_name(name)
    case name
    when 'notice'
      'success'
    when 'alert'
      'error'
    when 'danger'
      'error'
    else 
      name
    end
  end

  # display error layout
  def form_errors_for(object=nil)
    if object.present? && object.errors.any?
      render('layouts/errors', object: object)
    end
  end

end
