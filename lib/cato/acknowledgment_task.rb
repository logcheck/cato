module Cato
  ACKNOWLEDGMENTS = Hash.new

  # This task works in tandem with the SettingsBundleTask, so that you
  # can display package copyright notices in your app's Settings.
  class AcknowledgmentTask < Rake::TaskLib
    def initialize(name, path, dir = nil)
      @name = name
      @path = path
      @dir = dir
      define_tasks
    end

    def acknowledgment_path
      File.join(CATO_ACKNOWLEDGMENTS_DIR, "#{@name}.plist")
    end

    def define_tasks
      ACKNOWLEDGMENTS[@name] = acknowledgment_path

      task 'cato:products' => acknowledgment_path

      directory CATO_ACKNOWLEDGMENTS_DIR => acknowledgment_path do
        touch CATO_ACKNOWLEDGMENTS_DIR
      end

      if @dir
        # @path is relative to @dir
        file acknowledgment_path => @dir do
          if @path.is_a? Array
            create_plist(find_license_path)
          else
            create_plist(File.join(@dir, @path))
          end
        end
      else
        # @path is relative to the current directory
        file acknowledgment_path => @path do
          create_plist(@path)
        end
      end

      CLOBBER.include(acknowledgment_path)
    end

    def find_license_path
      list = FileList.new(@path.map { |p| File.join(@dir, p) })

      if list.empty?
        raise "error: could not find license for #{name}; " +
              "set license_path to nil if none is available"
      end

      license_path = list.first

      rake_output_message "#{@name}: found license at #{license_path}"

      return license_path
    end

    def create_plist(text_path)
      settings_obj = {
        'PreferenceSpecifiers' => [
          {
            'Type'       => 'PSGroupSpecifier',
            'Title'      => @name,
            'FooterText' => File.read(text_path, encoding: 'UTF-8')
          }
        ]
      }

      mkpath File.dirname(acknowledgment_path)

      plist = CFPropertyList::List.new
      plist.value = CFPropertyList.guess(settings_obj)
      plist.save(acknowledgment_path, CFPropertyList::List::FORMAT_XML)
    end
  end
end
