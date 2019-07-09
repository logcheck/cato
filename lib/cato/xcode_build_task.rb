module Cato
  # Defines a build step for building a package from source. You can
  # supply any command line options and build settings you wish, in
  # case the package isn't configured to your needs out of the box.
  #
  # Instead of creating an xcodebuild task directly, see
  # PackageTask#xcodebuild.
  class XcodeBuildTask < Rake::TaskLib
    def initialize(package, options)
      @package = package
      @options = options
    end

    def define_tasks
      task @package.build_task_name do
        options = xcodebuild_default_options.merge(@options)

        rake_output_message(@package.name + ': found project at ' +
                            options[:project])

        sh(*xcodebuild_command(options))
      end
    end

    def find_xcodeproj_path
      FileList.new(File.join(@package.checkout_path, '**/*.xcodeproj')).last
    end

    def xcodebuild_default_options
      {
        project: find_xcodeproj_path,
        scheme: @package.name,
        derivedDataPath: CATO_DERIVED_DATA_DIR
      }
    end

    def xcodebuild_command(options)
      ['/usr/bin/xcrun', 'xcodebuild', '-quiet'].tap do |args|
        options.each do |name, value|
          if value
            if name[0] =~ /[A-Z]/
              args << "#{name}=#{value}"
            else
              args << "-#{name}" << value
            end
          end
        end
      end
    end
  end
end
