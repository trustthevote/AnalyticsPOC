pdf_labeled_block pdf, "Election" do
  pdf_full_width_block pdf do |heights|
    pdf_fields pdf, [
      { columns: 1, value: @election.name, label: 'Election Name' },
      { columns: 1, value: @election.day.strftime("%B %-d, %Y"),
        label: 'Election Day' },
      { columns: 2, value: @election.voter_start_day.strftime("%B %-d, %Y")+
          " - "+@election.voter_end_day.strftime("%B %-d, %Y"), 
        label: 'Voter Days' },
      { columns: 2, value: number_with_delimiter(@election.logs_num)+" / "+
          number_with_delimiter(@election.records_num)+" / "+
          number_with_delimiter(@election.voters_num),
        label: 'Logs / Records / Voters' }
    ]
  end
end
