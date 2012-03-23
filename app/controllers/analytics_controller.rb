class AnalyticsController < ApplicationController

  def analytic
    if params[:id] 
      eid = params[:id]
    else
      eid = Selection.all[0].eid
    end
    @election = Election.find(eid)
    render :analytic
  end

end
