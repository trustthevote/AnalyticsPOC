xml.instruct!
xml.voterTransactionRecord do |vtr|
  record = @voter_transaction_record
  vtr.voter  record.voter
  vtr.vtype  record.vtype unless record.vtype.blank?
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
