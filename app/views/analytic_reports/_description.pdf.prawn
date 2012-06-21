pdf_labeled_block pdf, "Report Description" do
  pdf_full_width_block pdf do |heights|
    notfirst = false
    @description.each do |desc|
      pdf.move_down 5
      pdf.text desc
    end
  end
end
