xml.instruct!
xml.voterTransactionLogs do |vtls|
  @voter_transaction_logs.each do |record|
    records = record.voter_transaction_records
    xml.voterTransactionLog do |vtl|
      vtl.header do |h|
        h.origin      record.origin
        h.originUniq  record.origin_uniq unless record.origin_uniq.blank?
        h.date        record.datime.xmlschema
      end
      records.each do |record|
        xml.voterTransactionRecord do |vtr|
          vtr.voter  record.vname
          vtr.date   record.datime.xmlschema
          vtr.action record.action
          unless record.form.blank?
            type1, type2, name, number = record.form.split(' | ')
            vtr.form do |f|
              f.type    type1
              f.type    type2 unless type2.blank?
              f.name    name  unless name.blank?
              f.number  number unless number.blank?
            end
          end
          vtr.leo  record.leo  unless record.leo.blank?
          vtr.note record.note unless record.note.blank?
        end
      end
    end
  end
end
