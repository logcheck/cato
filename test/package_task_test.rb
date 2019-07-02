require "test_helper"

class CatoPackageTaskTest < Minitest::Test
  def setup
    Rake.application = Rake::Application.new
  end

  def test_no_source_url
    assert_raises do
      Cato::PackageTask.new('Windows', '3.1')
    end
  end

  def test_creates_basic_tasks
    Cato::PackageTask.new('Windows', '3.1') do |pkg|
      pkg.download "https://microsoft.com/windows/#{pkg.version}.zip"
    end

    assert Rake::Task.task_defined?('Cato/Downloads/Windows@3.1.zip')
    assert Rake::Task.task_defined?('cato:checkout')
    assert Rake::Task.task_defined?('cato:checkout:Windows')
    assert Rake::Task.task_defined?('Cato/Checkouts/Windows')
    refute Rake::Task.task_defined?('Cato/Stamps/Windows@3.1.build')
    assert Rake::Task.task_defined?('Cato/Acknowledgments/Windows.plist')
  end

  def test_creates_build_tasks
    Cato::PackageTask.new('Windows', '3.1') do |pkg|
      pkg.download "https://microsoft.com/windows/#{pkg.version}.zip"
      pkg.xcodebuild
    end

    assert Rake::Task.task_defined?('Cato/Downloads/Windows@3.1.zip')
    assert Rake::Task.task_defined?('cato:checkout')
    assert Rake::Task.task_defined?('cato:checkout:Windows')
    assert Rake::Task.task_defined?('Cato/Checkouts/Windows')
    assert Rake::Task.task_defined?('Cato/Stamps/Windows@3.1.build')
    assert Rake::Task.task_defined?('Cato/Acknowledgments/Windows.plist')
  end

  def test_creates_static_library_tasks
    Cato::PackageTask.new('Windows', '3.1') do |pkg|
      pkg.download "https://microsoft.com/windows/#{pkg.version}.zip"
      pkg.xcodebuild
      pkg.license_path = nil
      pkg.static_library
    end

    assert Rake::Task.task_defined?('Cato/Downloads/Windows@3.1.zip')
    assert Rake::Task.task_defined?('cato:checkout')
    assert Rake::Task.task_defined?('cato:checkout:Windows')
    assert Rake::Task.task_defined?('Cato/Checkouts/Windows')
    assert Rake::Task.task_defined?('Cato/Stamps/Windows@3.1.build')
    refute Rake::Task.task_defined?('Cato/Acknowledgments/Windows.plist')
    assert Rake::Task.task_defined?('cato:products')
    assert Rake::Task.task_defined?('Cato/Headers/Windows')
    assert Rake::Task.task_defined?('Cato/Products/libWindows.a')
  end

  def test_creates_framework_tasks
    Cato::PackageTask.new('Windows', '3.1') do |pkg|
      pkg.download "https://microsoft.com/windows/#{pkg.version}.zip"
      pkg.framework do |f|
        f.platforms = %w[ i286 i386 ]
      end
    end

    assert Rake::Task.task_defined?('Cato/Downloads/Windows@3.1.zip')
    assert Rake::Task.task_defined?('cato:checkout')
    assert Rake::Task.task_defined?('cato:checkout:Windows')
    assert Rake::Task.task_defined?('Cato/Checkouts/Windows')
    refute Rake::Task.task_defined?('Cato/Stamps/Windows@3.1.build')
    assert Rake::Task.task_defined?('Cato/Acknowledgments/Windows.plist')
    assert Rake::Task.task_defined?('cato:products')
    assert Rake::Task.task_defined?('Cato/Products-i286/Windows.framework')
    assert Rake::Task.task_defined?('Cato/Products-i386/Windows.framework')
  end
end
