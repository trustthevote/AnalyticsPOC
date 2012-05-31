pdf_labeled_block pdf, "Election" do
  pdf_full_width_block pdf do |heights|
    pdf_fields pdf, [
      { columns: 2, value: @election.name, label: 'Name' },
      { columns: 2, value: @election.day.strftime("%B %-d, %Y"),
        label: 'Election Day' },
      { columns: 1, value: @election.voter_start_day.strftime("%B %-d, %Y"),
        label: 'Voter Start Day' },
      { columns: 1, value: @election.voter_end_day.strftime("%B %-d, %Y"), 
        label: 'Voter End Day' }
    ]
  end
end
