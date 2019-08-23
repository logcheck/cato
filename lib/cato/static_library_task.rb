module Cato
  # Defines a static library dependency. Static libraries are embedded
  # into the targets that link to them.
  #
  # Instead of creating a static library task directly, see
  # PackageTask#static_library.
  class StaticLibraryTask < Rake::TaskLib
    attr_reader :name

    attr_accessor :headers_path
    attr_accessor :library_path

    def initialize(package, name)
      @package = package
      @name = name
      # these defaults assume we're building from source
      @headers_path = "Build/Products/*/include/#{name}/*.h"
      @library_path = "Build/Products/*/lib#{name}.a"
    end

    def define_tasks
      if @package.has_build_steps?
        @source_dir = CATO_DERIVED_DATA_DIR
        @dependency = @package.build_task_name
      else
        @source_dir = @package.checkout_path
        @dependency = @package.checkout_path
      end

      define_headers_tasks if @headers_path
      define_library_tasks
    end

    def define_headers_tasks
      target_path = File.join(CATO_HEADERS_DIR, name)

      task 'cato:products' => target_path

      directory target_path => @dependency do
        source_list = FileList.new(File.join(@source_dir, @headers_path))

        if source_list.empty?
          raise "no headers found for #{name}; set headers_path = false " +
                "if there are no headers to copy"
        end

        rmtree target_path
        mkpath target_path
        source_list.each { |file| cp file, target_path, preserve: true }
      end

      CLOBBER.include(target_path)

      if BUILT_PRODUCTS_DIR
        include_path = File.join(BUILT_PRODUCTS_DIR, 'include')
        install_path = File.join(include_path, name)

        task 'cato:install' => install_path

        directory install_path => target_path do
          rmtree install_path
          mkpath install_path
          cp_r File.join(target_path, '.'), install_path, preserve: true
        end

        CLEAN.include(install_path)
      end
    end

    def define_library_tasks
      basename = "lib#{name}.a"
      target_path = File.join(CATO_PRODUCTS_DIR, basename)

      task 'cato:products' => target_path

      file target_path => @dependency do
        mkpath CATO_PRODUCTS_DIR

        source_list = FileList.new(File.join(@source_dir, @library_path))

        rm_f target_path

        if source_list.length > 1
          merge_command = ['/usr/bin/xcrun', 'lipo',
                           '-create',
                           '-output', target_path]
          sh(*(merge_command + source_list))

          t = source_list.map { |f| File.mtime(f) }.max
          File.utime(t, t, target_path)
        else
          cp source_list.first, target_path, preserve: true
        end
      end

      CLOBBER.include(target_path)

      if BUILT_PRODUCTS_DIR
        install_path = File.join(BUILT_PRODUCTS_DIR, basename)

        task 'cato:install' => install_path

        file install_path => target_path do
          rm_f install_path
          cp target_path, install_path, preserve: true
        end

        CLEAN.include(install_path)
      end
    end
  end
end
