pdf_labeled_block pdf, "Report Data" do
  pdf_full_width_block pdf do |heights|
    pdf_fields pdf, [
      { columns: 1, value: @pvoters+" ("+@nvoters+")",
        label: 'UOCAVA Voters' },
      { columns: 1, value: @pvote_reg+" ("+@nvote_reg+")",
        label: 'Registered To Vote' },
      { columns: 1, value: @pvote_upd+" ("+@nvote_upd+")",
        label: 'Updated Voter Record' },
      { columns: 1, value: @pvote_as+" ("+@nvote_as+")",
        label: 'Requested Absentee Status' },
      { columns: 1, value: @pvote_ab+" ("+@nvote_ab+")",
        label: 'Submitted Absentee Ballot' },
      { columns: 1, value: @pvote_aa+" / "+@pvote_ar,
        label: 'Absentee Ballot Approved / Rejected' },
    ]
  end
end
