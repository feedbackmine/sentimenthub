class ProjectsController < ApplicationController
  def index
    @projects = Project.find :all
  end
  
  def show
    @project = Project.find params[:id]
    @feedbacks = @project.feedbacks
  end
end
