
module RedminePreviewOffice
  module Patches
    module DmsfFilePatch
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          

          # Returns the full path the attachment docx preview, or nil
          # if the preview cannot be generated.
          def preview_office(options={})
            if is_office_doc?

              target = File.join(self.class.thumbnails_storage_path, "#{self.last_revision.id}.pdf")

              begin
                Redmine::Thumbnail.generate_preview_office("#{self.last_revision.disk_file}", target)
              rescue => e
                logger.error "An error occured while generating preview for #{self.last_revision.disk_file} to #{target}\nException was: #{e.message}" if logger
                return nil
              end
            end
          end #def
          
          def is_office_doc?
            %w(.doc .docx .xls .xlsx .ppt .pptx .rtf .odt).include?( File.extname(self.last_revision.disk_file).downcase )
          end #def


        end #base
      end #included

       module InstanceMethods        
       end #module      

       module ClassMethods
       end #module

    end
  end  
end

unless DmsfFile.included_modules.include?(RedminePreviewOffice::Patches::DmsfFilePatch)
    DmsfFile.send(:include, RedminePreviewOffice::Patches::DmsfFilePatch)
end


