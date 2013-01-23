require 'will_paginate'

class PasajesController < ApplicationController
  unloadable


  before_filter :find_project, :find_repository, :authorize, :only => [:show, :index]


  def index
    #@logs = Log.find(:all, :conditions => [ "pid = ?", @project.identifier], :order => "date DESC")
    @logs = Log.paginate(:page => params[:page], :per_page => 20, :conditions => [ "pid = ?", @project.identifier], :order => "date DESC")
  end


  def show
    return unless @project

    if not @project.module_enabled?('pasajes')
      render_404
      return
    end    

    if not params[:rev]
      rev = @repository.changesets.find(:first, :order => "committed_on DESC" )
    else
      rev = params[:rev]
      rev_valida = @repository.changesets.find(:first, :conditions => [ "revision = ?", rev ] )
      if rev_valida.nil?
        flash.now[:error] = l(:revision_not_found)
        render_404
	return
      end
    end

    if not params[:simulacion]
      @simulacion = false
    else
      if not params[:simulacion] = 'simulacion'
        @simulacion = false
      else
        @simulacion = true
      end
    end

    simulacion = @simulacion ? 'simulacion' : ''

    project_id = @project.identifier

#    command = "echo id:#{project_id} - rev:#{rev} - simu:#{simulacion}"
    command = "/opt/pasajedesarrollo/sync.sh #{project_id} #{rev} #{simulacion}"

    @output=`#{command} 2>&1`
    @status_code=$?.exitstatus

    Log.create(:pid => project_id, :uid => User.current.id, :revid => rev, :date => Time.now, :simulacion => @simulacion, :success => @status_code)

  end


  # de github.com/chantra/redmine_gitrevision_download/blob/master/app/controllers/gitrevision_download_controller.rb
  def find_project
    begin
      @project = Project.find(:first, :conditions => [ "identifier = ?", params[:project_id] ])
    rescue ActiveRecord::RecordNotFound
      flash.now[:error] = l(:project_not_found)
      render_404
      @project = nil
    rescue Exception => e
      flash.now[:error] = l(:unknown_exception)
      render_404
      @project = nil
    end
  end


  def find_repository
    @repository = @project.repository
    if @repository.nil?
      flash.now[:error] = l(:no_repository_link, :name => @project.to_s)
      render_404
      return
    end
    @repository.fetch_changesets
# no se por que no anda esto...
#    if not @repository.type = "Subversion"
#      flash.now[:error] = l(:repo_not_SVN, :name => @project.to_s)
#      render_404
#      return
#    end    
  end

end
