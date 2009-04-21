class FeedbacksController < ApplicationController
  before_filter :require_user
  
  def destroy
    @feedback = Feedback.find(params[:id])
    @feedback.destroy

    redirect_to :back
  end
  
  #reclassify
  def edit
    @feedback = Feedback.find(params[:id])
    @feedback.reclassify
    
    redirect_to :back
  end
end
