top    = pdf.cursor
width  = pdf.bounds.right
height = 65

pdf.save_graphics_state do

  pdf.bounding_box [ 0, top ], width: width, height: height do
    pdf.fill_color "dddddd"
    pdf.fill_rectangle [ 0, pdf.cursor ], width, height

    pdf.font "Georgia", size: 24 do
      pdf.fill_color "000000"
      pdf.text_box 'Virginia Voter Analytics', at: [ 10, pdf.cursor - 10 ]
    end
    pdf.font "Georgia", size: 18 do
      pdf.fill_color "888888"
      pdf.text_box rname+' ('+Date::today.strftime("%B %-d, %Y")+')', at: [ 10, 25 ]
    end
  end

  pdf.move_down 10
end
