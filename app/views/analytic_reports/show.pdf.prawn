require 'prawn/measurement_extensions'

prawn_document(page_size: [ 216.mm, 279.mm ], margin: 20) do |pdf|
  # Define fonts
  pdf.font_families.update("Georgia" => {
    normal: "#{Rails.root}/lib/fonts/georgia.ttf"
  })
  pdf.default_leading = 3
  pdf.font_size 9

  render "header", pdf: pdf, rname: @rname
  render "election", pdf: pdf
  if @rn == 2
    render "report2", pdf: pdf
  else
    render "report1", pdf: pdf
  end
  render "description", pdf: pdf
end
