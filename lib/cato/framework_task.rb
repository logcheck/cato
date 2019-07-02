module Cato
  # Defines a framework dependency. Cato assumes all frameworks are to
  # be dynamically linked and embedded into your app bundle. That
  # means separate versions are maintained for each platform, and the
  # appropriate one is selected and installed at build time. (Note
  # that "static frameworks" are not officially supported by Apple.)
  #
  # Instead of creating a framework task directly, see
  # PackageTask#framework.
  class FrameworkTask < Rake::TaskLib
    attr_reader :name

    attr_accessor :platforms

    def initialize(package, name)
      @package = package
      @name = name
      @platforms = %w[ iphoneos iphonesimulator ]
    end

    def define_tasks
      platforms.each do |platform|
        define_tasks_for_platform(platform)
      end
    end

    def define_tasks_for_platform(platform)
      basename = "#{name}.framework"
      target_dir = "#{CATO_PRODUCTS_DIR}-#{platform}"
      target_path = File.join(target_dir, basename)

      task 'cato:products' => target_path

      directory target_path => @package.build_task_name do
        path = "Build/Products/*-#{platform}/#{basename}"
        source_list = FileList.new(File.join(CATO_DERIVED_DATA_DIR, path))
        if source_list.empty?
          raise "error: #{name}: cannot find framework at #{path}"
        end

        source_path = source_list.first

        target_path = File.join(target_dir, basename)

        mkpath target_dir
        copy_framework(source_path, target_path)
      end

      CLOBBER.include(target_path)

      if BUILT_PRODUCTS_DIR && (platform == ENV['PLATFORM_NAME'])
        install_path = File.join(BUILT_PRODUCTS_DIR, basename)

        task 'cato:install' => install_path

        directory install_path => target_path do
          copy_framework(target_path, install_path)
        end

        CLEAN.include(install_path)
      end
    end

    def copy_framework(source_path, target_path)
      rmtree target_path
      cp_r source_path, target_path

      rmtree target_path + '.dSYM'
      if File.exist?(source_path + '.dSYM')
        cp_r source_path + '.dSYM', target_path + '.dSYM'
      end
    end
  end
end
