class ProjectsController < ApplicationController
  before_filter :require_user, :except => [:index, :show, :positive, :nagative, :other]
  
  def index
    @projects = Project.featured
  end
  
  def new
    @project = Project.new
  end
  
  def create
    @project = Project.create(params[:project])
    
    if @project.save
      flash[:notice] = 'Project was successfully created.'
      redirect_to(@project)
    else
      render :action => "new"
    end
  end
  
  def edit
    @project = Project.find_by_name(params[:id])
  end
  
  def update
    @project = Project.find_by_name params[:id]
    
    if @project.update_attributes(params[:project])
      flash[:notice] = 'Project was successfully updated.'
      redirect_to(@project)
    else
      render :action => "edit"
    end
  end
  
  def show
    @project = Project.find_by_name params[:id]
    @source = params[:source] ? params[:source] : 'twitter'
    @polarity = params[:polarity] ? params[:polarity] : 'all'
    @twitter_count = @project.feedbacks.sentiment('twitter', 'all').count
    @blog_count    = @project.feedbacks.sentiment('blog',    'all').count
    @feedbacks = @project.feedbacks.sentiment(@source, @polarity).paginate :page => params[:page], :per_page => 50, :order => 'created_at DESC'
  end
  
  def destroy
    @project = Project.find(params[:id])
    @project.destroy

    redirect_to(projects_path)
  end
  
end
