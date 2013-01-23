require 'redmine'

Redmine::Plugin.register :pasajes do
  name 'Redmine Pasajes plugin'
  author 'Julian Perelli'
  description 'Plugin para realizar pasajes a desarrollo y produccion'
  version '0.0.4'
  url 'http://www.ms.gba.gov.ar/'
  author_url 'http://jperelli.com.ar/'

  project_module :pasajes do
    permission :hacer_pasajes_desarrollo, :pasajes => [:index, :show]
  end
  
  menu :project_menu, :pasajes, { :controller => 'pasajes', :action => 'index' }, :caption => 'Pasajes', :after => :settings, :param => :project_id

end
