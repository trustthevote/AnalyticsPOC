class ReportsController < ApplicationController

  def show
    if params[:id] 
      eid = params[:id]
    else
      eid = Selection.all[0].eid
    end
    @election = Election.find(eid)
    @report_date = "Report Date: "+Date::today.to_s
    if params[:rn] 
      case params[:rn].to_i
      when 1
        return self.report1()
      when 2
        return self.report2()
      end
    end
    render '/reports/report99'
    return false
  end

  def report1()
    @xvoters  = 1
    @voters   = 0
    @voted    = 0
    @vote_reg = 0
    @vote_upd = 0
    @vote_no  = 0
    @vote_aa  = 0
    @vote_ar  = 0
    @vote_pa  = 0    
    @vote_pr  = 0
    @vote_wac = 0    
    voter_ids = []
    @election.voter_transaction_logs.each do |vtl|
      vtl.voter_transaction_records.each do |vtr|
        vid = vtr.vname
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
    render '/reports/report1'
    return true
  end

  def report2()
    @xvoters  = 1
    @voters   = 0
    @voted    = 0
    @vote_reg = 0
    @vote_upd = 0
    @vote_no  = 0
    @vote_as  = 0
    @vote_ab  = 0    
    @vote_aa  = 0
    @vote_ar  = 0
    voter_ids = []
    @election.voter_transaction_logs.each do |vtl|
      vtl.voter_transaction_records.each do |vtr|
        vid = vtr.vname
        if vtr.vtype =~ /UOCAVA/
          voter_ids.push(vid) unless voter_ids.include?(vid)
          if vtr.action == 'approve'
            if vtr.form =~ /Absentee Ballot/
              @vote_aa += 1
              @voted += 1
            elsif vtr.form =~ /Absentee Request/
              @vote_as += 1 
              @voted += 1
            elsif vtr.form =~ /Voter Registration/
              @vote_reg += 1 
              @voted += 1
            elsif vtr.form =~ /Voter Record Update/
              @vote_upd += 1 
              @voted += 1
            end
          elsif vtr.action == 'reject'
            if vtr.form =~ /Absentee Ballot/
              @vote_ar += 1
              @voted += 1
            end
          elsif vtr.form =~ /Absentee Ballot/
            unless vtr.action == 'discard' #JVC really?
              @vote_ab += 1
              @voted += 1
            end
          end
        end
      end
    end
    @voters = voter_ids.length
    if @voters > 0
      @xvoters = @voters 
      @vote_no = @voters - @voted
    end
    render '/reports/report2'
    return true
  end

end
