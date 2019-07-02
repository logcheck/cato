require 'cato'

namespace :cato do
  desc 'Download and unpack all packages'
  task :checkout

  desc 'Prepare headers, libraries, and frameworks'
  task :products

  desc 'Copy files to BUILT_PRODUCTS_DIR (under Xcode)'
  task :install do
    # For convenience (especially when adding libraries and frameworks
    # to Xcode), we create a symlink to Xcode's currently active Build
    # Products directory.
    if Cato::BUILT_PRODUCTS_DIR
      mkpath Cato::CATO_DIR
      rm_f Cato::CATO_XCODE_PRODUCTS_DIR
      ln_s Cato::BUILT_PRODUCTS_DIR, Cato::CATO_XCODE_PRODUCTS_DIR
    end
  end
end

CLEAN.include(Cato::CATO_DERIVED_DATA_DIR)
