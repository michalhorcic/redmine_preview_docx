
module RedminePreviewOffice
  module Patches
    module DmsfFilesControllerPatch
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
            
          alias_method_chain     :show, :office
         
          alias_method           :find_file_for_preview_office, :find_file
          before_action          :find_file_for_preview_office, :only => [:preview_office]


		  def preview_office
        puts "trying to preview DMSF file"

			if @file.is_office_doc? && preview = @file.preview_office(:size => params[:size])

			  if stale?(:etag => preview)

				send_file preview,
				  :filename => filename_for_content_disposition( preview ),
				  :type => 'application/pdf',
				  :disposition => 'inline'
			  end
			else
			  # No thumbnail for the attachment or thumbnail could not be created
			  head 404
			end
		  end #def
 
        end #base
        
      end #self

      module InstanceMethods

        def show_with_office
          
          rendered = false
          respond_to do |format|
            format.html {
              if @file.is_office_doc?
                render :action => 'office'
                rendered = true
              end
            }
            format.any {}
          end
          
          show_without_office unless rendered 
        
        end #def 

      end #module  
      
      module ClassMethods      
      end #module    

    end #module
  end #module
end #module

unless DmsfFilesController.included_modules.include?(RedminePreviewOffice::Patches::DmsfFilesControllerPatch)
    DmsfFilesController.send(:include, RedminePreviewOffice::Patches::DmsfFilesControllerPatch)
end


