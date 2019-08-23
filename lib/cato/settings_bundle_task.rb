module Cato
  # This task works in tandem with AcknowledgmentTask so that you can
  # display included packages' copyright notices in your app via a
  # Settings menu.
  class SettingsBundleTask < Rake::TaskLib
    def initialize(bundle_path)
      @bundle_path = bundle_path
      define_tasks
    end

    def toc_path
      File.join(@bundle_path, '_Acknowledgements.plist')
    end

    def define_tasks
      task 'cato:install' => toc_path

      desc 'Prepare settings bundle'
      file toc_path => CATO_ACKNOWLEDGMENTS_DIR do
        ACKNOWLEDGMENTS.each do |name, source_path|
          target_path = File.join(@bundle_path, "_#{name}.plist")

          cp source_path, target_path, preserve: true
        end

        settings_obj = {
          'PreferenceSpecifiers' => ACKNOWLEDGMENTS.keys.map do |name|
            {
              'Type'  => 'PSChildPaneSpecifier',
              'Title' => name,
              'File'  => "_#{name}"
            }
          end
        }

        plist = CFPropertyList::List.new
        plist.value = CFPropertyList.guess(settings_obj)
        plist.save(toc_path, CFPropertyList::List::FORMAT_XML)
      end

      CLEAN.include(File.join(@bundle_path, '_*.plist'))
    end
  end
end
