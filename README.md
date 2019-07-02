# Cato: manage Xcode project dependencies with Rake

Cato makes it easy to manage your Xcode project's dependencies using
Rake (a Make-like dependency management tool implemented in Ruby).

Cato unobtrusively downloads, builds, and copies static libraries and
frameworks into the places where Xcode expects to find them.

Cato began as a set of Ruby scripts designed to manage dependencies in
the LogCheck mobile app. Primarily for the sake of tidiness, I decided
to factor it out into this gem. Maybe someone else will find it useful
for their project. Who knows?

## How to add Cato to your Xcode project

In a nutshell:

1. Create a `Rakefile` that includes `require 'cato/tasks'` and
   describes your dependencies.

2. In Xcode, add an "External Build System" target that runs `rake
   cato:install --trace`.

3. Add dependencies to your Xcode project (see below).

The above will work only if you install the `cato` gem ahead of time;
if you want to make life easier on the developers using the project,
you can write a shell script that will install the gem if needed.

## How to add a new framework or static library dependency using Cato

1. Add a `PackageTask` to your `Rakefile` that describes where to
   download it from. Add one or more `xcodebuild` declarations if
   building from source, and add one or more `static_library` and/or
   `framework` declarations.

2. In Xcode, change the active scheme destination to "Generic iOS
   Device" (instead of a simulator). This shouldn't matter, but it
   does.

3. Build the project in Xcode, which will run `rake
   cato:install`. Rake will put the needed files into Xcode's
   `BUILT_PRODUCTS_DIR`. It's OK if the build fails, as long as the
   `rake` execution succeeded.

4. Navigate to the target's "Build Phases" tab and the "Link Binary
   With Libraries" section. *IMPORTANT:* When adding a static library
   or framework, navigate through the `Cato/XcodeProducts` folder link
   and select the item from there.

5. Within the "Build Phases" tab, ctrl-click the new library or
   framework and select "Reveal in Project Navigator"; from there,
   ctrl-click again and select "Show File Inspector".

6. In the File Inspector, change the Location to "Relative to Build
   Products". If everything is correct, the filename below the pop-up
   menu will appear without any leading path information. (For
   example, you should see `libFooBar.a` and not
   `../Debug-iphonesimulator/libFooBar.a`.)

7. Build again and everything should be working!

## TODO

* It would be helpful to pick some public projects using Carthage or
  CocoaPods and "Cato-ize" them, to test how well this thing works
  apart from the LogCheck app.

* I probably need to explain how Cato compares to CocoaPods and
  Carthage, in a polite way. :-)
