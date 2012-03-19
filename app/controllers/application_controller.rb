class ApplicationController < ActionController::Base
  protect_from_forgery

  protected

  # Sends the #xml string as a attachment file with the given #filename.
  def send_xml(filename, xml)
    send_data xml,
      filename:     filename,
      type:         'text/xml; charset=UTF-8;',
      disposition:  'attachment;'
  end

end
