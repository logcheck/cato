require 'rake/tasklib'
require 'rake/clean'
require 'cfpropertylist'

require 'cato/version'

module Cato
  CATO_DIR = 'Cato'

  # The directory where Cato stages "acknowledgement" property list
  # files, suitable for including in an app's Settings bundle.
  CATO_ACKNOWLEDGMENTS_DIR = File.join(CATO_DIR, 'Acknowledgments')

  # The directory where Cato stages static library header files.
  CATO_HEADERS_DIR         = File.join(CATO_DIR, 'Headers')

  # The directory where Cato stages static libraries and frameworks.
  CATO_PRODUCTS_DIR        = File.join(CATO_DIR, 'Products')

  # The directory where Cato stages "stamp" files to keep track of
  # whether a package has been checked out or build.
  CATO_STAMPS_DIR          = File.join(CATO_DIR, 'Stamps')

  # The directory where Cato unpacks packages.
  CATO_CHECKOUTS_DIR       = File.join(CATO_DIR, 'Checkouts')

  # The directory where Cato downloads packages.
  CATO_DOWNLOADS_DIR       = File.join(CATO_DIR, 'Downloads')

  # The directory where Cato directs `xcodebuild` to write
  # intermediate build files and build products.
  CATO_DERIVED_DATA_DIR    = File.join(CATO_DIR, 'DerivedData')

  # A symlink to the last seen value of the BUILT_PRODUCTS_DIR
  # environment variable, which is set by Xcode to indicate where
  # product files should be installed for later build targets to see.
  CATO_XCODE_PRODUCTS_DIR  = File.join(CATO_DIR, 'XcodeProducts')

  BUILT_PRODUCTS_DIR       = ENV['BUILT_PRODUCTS_DIR']
end

require 'cato/acknowledgment_task'
require 'cato/framework_task'
require 'cato/package_task'
require 'cato/settings_bundle_task'
require 'cato/static_library_task'
require 'cato/xcode_build_task'
