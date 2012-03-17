class AnalyticsController < ApplicationController

  def analytic
    @xvoters  = 1
    @voters   = 0
    @voted    = 0
    @vote_reg = 0
    @vote_no  = 0
    @vote_aa  = 0
    @vote_ar  = 0
    @vote_pa  = 0    
    @vote_pr  = 0
    @vote_wac = 0    
    eid = Selection.all[0].eid
    election = Election.find(eid)
    voter_ids = []
    election.voter_transaction_logs.each do |vtl|
      vtl.voter_transaction_records.each do |vtr|
        vid = vtr.voter
        voter_ids.push(vid) unless voter_ids.include?(vid)
        if vtr.action == "approve"
          if vtr.form =~ /Absentee Ballot/
            @vote_aa += 1
            @voted += 1
          elsif vtr.form =~ /Provisional Ballot/
            @vote_pa += 1
            @voted += 1
          end
        elsif vtr.action == "reject"
          if vtr.form =~ /Absentee Ballot/
            @vote_ar += 1
            @voted += 1
          elsif vtr.form =~ /Provisional Ballot/
            @vote_pr += 1 
            @voted += 1
          end
        elsif vtr.action == "identify"
          if vtr.form =~ /Poll Book/
            @vote_reg += 1
            @voted += 1
          end
        end
      end
    end
    @voters = voter_ids.length
    if @voters > 0
      @xvoters = @voters 
      @vote_no = @voters - @voted
    end
    render :analytic
  end

end
