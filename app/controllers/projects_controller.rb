class ProjectsController < ApplicationController
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
    @project = Project.find(params[:id])
  end
  
  def update
    @project = Project.find params[:id]
    
    if @project.update_attributes(params[:project])
      flash[:notice] = 'Project was successfully updated.'
      redirect_to(@project)
    else
      render :action => "edit"
    end
  end
  
  def show
    @project = Project.find params[:id]
    @feedbacks = @project.feedbacks.paginate :page => params[:page], :per_page => 50, :order => 'created_at DESC'
  end
  
  #def destroy
  #  @project = Utility.find(params[:id])
  #  @project.destroy

  #  redirect_to(projects_path)
  #end
end
