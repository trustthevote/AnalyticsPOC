pdf_labeled_block pdf, "Report Data" do
  pdf_full_width_block pdf do |heights|
    pdf_fields pdf, [
      { columns: 1, value: @pvoters+" ("+@nvoters+")",
        label: 'All Voters' },
      { columns: 1, value: @pvote_no+" ("+@nvote_no+")",
        label: 'Non-Voting' },
      { columns: 1, value: @pvote_reg+" ("+@nvote_reg+")",
        label: 'Regular Ballot' },
      { columns: 1, value: @pvote_a+" ("+@vote_aa.to_s+"/"+@vote_ar.to_s+")",
        label: 'Absentee Ballot' },
      { columns: 1, value: @pvote_p+" ("+@vote_pa.to_s+"/"+@vote_pr.to_s+")",
        label: 'Provisional Ballot' },
      { columns: 1, value: @pvote_wac+" ("+@nvote_wac+")",
        label: 'Whacky Voter' },
    ]
  end
end
