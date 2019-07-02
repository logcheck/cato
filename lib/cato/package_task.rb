module Cato
  # Defines tasks to download and check out a package, and the ability
  # to declare subtasks to build and copy static libraries and
  # frameworks from it. Also searches the package for a license to
  # create an acknowledgment file. (To prevent that behavior, set
  # `license_path` to `nil`.)
  class PackageTask < Rake::TaskLib
    LICENSE_FILE_SEARCH_PATTERNS = %w[
      **/LICENSE
      **/LICENSE.txt
      **/License.txt
    ]

    attr_reader :name
    attr_reader :version
    attr_reader :versioned_name

    attr_accessor :license_path

    def initialize(name, version, &block)
      init_defaults(name, version)
      yield self if block_given?
      define_download_tasks
      define_checkout_tasks
      define_other_tasks
    end

    def init_defaults(name, version)
      @name = name.freeze
      @version = version.freeze
      @versioned_name = "#{name}@#{version}".freeze
      @download_options = {}
      @checkout_options = { strip_path_components: 0 }
      @license_path = LICENSE_FILE_SEARCH_PATTERNS
      @build_tasks = []
      @product_tasks = []
    end

    def has_build_steps?
      !@build_tasks.empty?
    end

    def download(url, options = {})
      @download_options[:url] = url
      @download_options.merge! options
    end

    def checkout(options)
      @checkout_options.merge! options
    end

    def xcodebuild(options = {})
      @build_tasks << XcodeBuildTask.new(self, options)
    end

    def static_library(library_name = nil)
      task = StaticLibraryTask.new(self, library_name || @name)
      yield task if block_given?
      @product_tasks << task
    end

    def framework(framework_name = nil)
      task = FrameworkTask.new(self, framework_name || @name)
      yield task if block_given?
      @product_tasks << task
    end

    #
    # Download Tasks
    #

    def download_url
      @download_options[:url]
    end

    def download_type
      case download_url
      when /\.tar\.gz$/ then :tgz
      when /\.zip$/ then :zip
      else raise "error: can't determine file type from URL #{download_url}"
      end
    end

    def download_path
      File.join(CATO_DIR, 'Downloads', "#{versioned_name}.#{download_type}")
    end

    def define_download_tasks
      raise "error: no download URL specified for #{name}" unless download_url

      file download_path do
        mkpath CATO_DOWNLOADS_DIR
        sh 'curl',
           '--silent', '--fail', '--show-error', '--location',
           '--output', download_path,
           download_url
      end

      CLOBBER.include(download_path)
    end

    #
    # Checkout Tasks
    #

    def checkout_task_name
      "cato:checkout:#{name}"
    end

    def checkout_path
      File.join(CATO_DIR, 'Checkouts', name)
    end

    def define_checkout_tasks
      task 'cato:checkout' => checkout_task_name

      desc "Download and unpack #{name}"
      task checkout_task_name => checkout_path

      directory checkout_path => download_path do
        strip_levels = @checkout_options[:strip_path_components].to_s

        rmtree checkout_path
        mkpath checkout_path

        sh 'tar',
           '-xf', download_path,
           '-C', checkout_path,
           '--strip-components', strip_levels
      end

      CLOBBER.include(checkout_path)
    end

    #
    # Other Tasks
    #

    def build_task_name
      File.join(CATO_STAMPS_DIR, "#{versioned_name}.build")
    end

    def define_other_tasks
      unless @build_tasks.empty?
        file_create build_task_name => checkout_path

        CLOBBER.include(build_task_name)

        @build_tasks.each(&:define_tasks)

        Rake::Task[build_task_name].enhance do
          mkpath CATO_STAMPS_DIR
          touch build_task_name
        end
      end

      @product_tasks.each(&:define_tasks)

      if license_path
        AcknowledgmentTask.new(name, license_path, checkout_path)
      end
    end
  end

  class GitHubPackageTask < PackageTask
    def init_defaults(user_and_repo, version)
      _, repo = user_and_repo.split('/', 2)

      super(repo, version)

      download ['https://github.com/', user_and_repo,
                '/archive/', version, '.tar.gz'].join

      checkout strip_path_components: 1
    end
  end
end
