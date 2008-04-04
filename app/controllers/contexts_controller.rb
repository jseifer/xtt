class ContextsController < ApplicationController
  def index
    @contexts = current_user.contexts.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml  => @contexts }
      format.json { render :json => @contexts }
    end
  end

  def show
    @context = current_user.contexts.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml  => @context }
      format.json { render :json => @context }
    end
  end

  def new
    @context = current_user.contexts.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml  => @context }
      format.json { render :json => @context }
    end
  end

  def create
    @context = current_user.contexts.find_or_create_by_name(params[:context][:name])
    @context.attributes = params[:context]

    respond_to do |format|
      if @context.save
        flash[:notice] = 'Context was successfully created.'
        format.html { redirect_to(@context) }
        format.xml  { render :xml  => @context, :status => :created, :location => @context }
        format.json { render :json => @context, :status => :created, :location => @context }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml  => @context.errors, :status => :unprocessable_entity }
        format.json { render :json => @context.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @context = current_user.contexts.find(params[:id])
  end

  def update
    @context = current_user.contexts.find(params[:id])

    respond_to do |format|
      if @context.update_attributes(params[:context])
        flash[:notice] = 'Context was successfully updated.'
        format.html { redirect_to(@context) }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml  => @context.errors, :status => :unprocessable_entity }
        format.json { render :json => @context.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @context = current_user.contexts.find(params[:id])
    @context.destroy

    respond_to do |format|
      format.html { redirect_to(contexts_url) }
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end
end
