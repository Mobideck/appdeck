require 'rubygems'
require 'tmpdir'
require 'timeout'
require 'pp'
require 'fileutils'
require './Scripts/screen_recorder'
require './Scripts/network_testing'
require './Scripts/sdk_downloader'

puts ENV["PATH"]
ENV["PATH"] += ":/usr/local/bin"

if File.exists?('./Scripts/private/private.rb')
  require './Scripts/private/private.rb'
end

CONFIGURATION = "Debug"
BUILD_DIR = File.join(File.dirname(__FILE__), "build")
CEDAR_OUT = File.join(BUILD_DIR, "mopubsdk-cedar.xml")

class Simulator
  def initialize(options)
    sdk_version = options[:sdk] || available_sdk_versions.max
    @ios_sim_device_id = "com.apple.CoreSimulator.SimDeviceType.iPhone-5s, #{sdk_version}"
  end

  # We no longer have a way to reset the simulator, so if tests start to fail for no good reasons,
  #   a manual reset may be necessary

  def run(app_location, env)
    env_vars = env.map { |k,v| "--setenv #{k}=#{v}" }
    cmd = "ios-sim launch #{app_location} #{env_vars.join(" ")} --devicetypeid \"#{@ios_sim_device_id}\""
    IO.popen(cmd) { |io| while (line = io.gets) do puts line end }
  end
end

def head(text)
  puts "\n########### #{text} ###########"
end

def clean!
  `rm -rf #{BUILD_DIR}`
end

def build_dir(effective_platform_name)
  File.join(BUILD_DIR, CONFIGURATION + effective_platform_name)
end

def output_file(target)
  output_dir = File.join(File.dirname(__FILE__), "build")
  FileUtils.mkdir_p(output_dir)
  File.join(output_dir, "#{target}.output")
end

def system_or_exit(cmd, outfile = nil)
  cmd += " > #{outfile}" if outfile
  puts "Executing #{cmd}"

  system(cmd) or begin
    puts "******** Build Failed ********"
    puts "To review:\ncat #{outfile}" if outfile
    exit(1)
  end
end

def build(options)
  clean!
  target = options[:target]
  project = options[:project]
  configuration = options[:configuration] || CONFIGURATION
  if options[:sdk]
    sdk = options[:sdk]
  elsif options[:sdk_version]
    sdk = "iphonesimulator#{options[:sdk_version]}"
  else
    sdk = "iphonesimulator#{available_sdk_versions.max}"
  end
  out_file = output_file("mopub_#{options[:target].downcase}_#{sdk}")
  if target == 'Specs' 
  	system_or_exit(%Q[xcodebuild -workspace #{project}.xcworkspace -scheme #{target} -configuration #{configuration} -destination 'platform=iOS Simulator,name=iPad' -sdk #{sdk} build SYMROOT=#{BUILD_DIR}], out_file)
  else
	system_or_exit(%Q[xcodebuild -project #{project}.xcodeproj -target #{target} -configuration #{configuration} ARCHS=i386 -sdk #{sdk} build SYMROOT=#{BUILD_DIR}], out_file) 
  end
end

def run_in_simulator(options)
  app_name = "#{options[:target]}.app"
  app_location = "#{File.join(build_dir("-iphonesimulator"), app_name)}"

  env = options[:environment]
  simulator = Simulator.new(options)

  # record_video = options[:record_video]
  # screen_recorder = ScreenRecorder.new(File.expand_path("./Scripts"))
  # screen_recorder.start_recording if record_video

  if env.include?("CEDAR_JUNIT_XML_FILE") && File.exists?(env["CEDAR_JUNIT_XML_FILE"])
    File.delete env["CEDAR_JUNIT_XML_FILE"]
  end

  head "Running tests"
  simulator.run(app_location, env)
  head "Test run complete"

  if !File.exists? env["CEDAR_JUNIT_XML_FILE"]
    puts "Tests failed to generate output file"
    exit(1)
  end

  # TODO: save the video if it fails
  # if record_video
  #   video_path = screen_recorder.save_recording
  #   puts "Saved video: #{video_path}"
  # end

  # screen_recorder.stop_recording if record_video
  return true
end

def available_sdk_versions
  available = []
  `xcodebuild -showsdks | grep iphonesimulator`.split("\n").each do |line|
    match = line.match(/simulator([\d\.]+)/)
    # excluding 5.* SDK and 6.* versions
    available << match[1] if match and !match[1].start_with? "5." and !match[1].start_with? "6."
  end
  available
end

def cedar_env
  {
    "CEDAR_REPORTER_CLASS" => "CDRColorizedReporter,CDRJUnitXMLReporter",
    "CFFIXED_USER_HOME" => Dir.tmpdir,
    "CEDAR_HEADLESS_SPECS" => "1",
    "CEDAR_JUNIT_XML_FILE" => CEDAR_OUT
  }
end

desc "Build MoPubSDK on all SDKs then run tests"
task :default => [:trim_whitespace, "mopubsdk:build", "mopubsample:build", "mopubsdk:spec"] #TODO add back later , "mopubsample:spec", :integration_specs]

desc "Build MoPubSDK on all SDKs and run all unit tests"
task :unit_specs => ["mopubsdk:build", "mopubsample:build", "mopubsdk:spec", "mopubsample:spec"]

desc "Run KIF integration tests"
task :integration_specs => ["mopubsample:kif"]

desc "Trim Whitespace"
task :trim_whitespace do
  head "Trimming Whitespace"

  system_or_exit(%Q[git status --short | awk '{if ($1 != "D" && $1 != "R") for (i=2; i<=NF; i++) printf("%s%s", $i, i<NF ? " " : ""); print ""}' | grep -e '.*.[mh]"*$' | xargs sed -i '' -e 's/	/    /g;s/ *$//g;'])
end

desc "Download Ad Network SDKs"
task :download_sdks do
  head "Downloading Ad Network SDKs"
  downloader = SDKDownloader.new
  downloader.download!
end

namespace :mopubsdk do
  desc "Build MoPub SDK against all available SDK versions"
  task :build do
    available_sdk_versions.each do |sdk_version|
      head "Building MoPubSDK for #{sdk_version}"
      build :project => "MoPubSDK", :target => "MoPubSDK", :sdk_version => sdk_version
    end

    available_sdk_versions.each do |sdk_version|
      head "Building MoPubSDK+Networks for #{sdk_version}"
      build :project => "MoPubSDK", :target => "MoPubSDK+Networks", :sdk_version => sdk_version
    end

    head "Building MoPubSDK Fabric"
    build :project => "MoPubSDK", :target => "Fabric"
    
    head "SUCCESS"
  end

  desc "Run MoPubSDK Cedar Specs with specified iOS Simulator using argument 'simulator_version'"
  task :spec do
    head "Building Specs"
    build :project => "MoPubSDK", :target => "Specs"

    simulator_version = ENV['simulator_version']
    if (!simulator_version)
      simulator_version = available_sdk_versions.max
    end

    head "Running Specs in iOS Simulator version #{simulator_version}"
    run_in_simulator(:project => "MoPubSDK", :target => "Specs", :environment => cedar_env, :sdk => simulator_version)

    head "SUCCESS"
  end
end

namespace :mopubsample do
  desc "Build MoPub Sample App"
  task :build do
    head "Building MoPub Sample App"
    build :project => "MoPubSampleApp", :target => "MoPubSampleApp"
  end

  desc "Run MoPub Sample App Cedar Specs"
  task :spec do
    head "Building Sample App Cedar Specs"
    build :project => "MoPubSampleApp", :target => "SampleAppSpecs"

    head "Running Sample App Cedar Specs"
    run_in_simulator(:project => "MoPubSampleApp", :target => "SampleAppSpecs", :environment => cedar_env, :success_condition => ", 0 failures")
  end

  desc "Build Mopub Sample App with Crashlytics"
  task :crashlytics do
    current_branch = `git rev-parse --abbrev-ref HEAD`

    current_branch = current_branch.strip()

    should_switch_git_branch = current_branch != "crashlytics-integration"

    if should_switch_git_branch
      system_or_exit(%Q[git co crashlytics-integration])
      sleep 2
    end

    head "Launching Crashlytics App"
    system_or_exit(%Q[open /Applications/Crashlytics.app])

    head "Giving Crashlytics time to update"
    sleep 5

    head "Building MoPub Sample App with Crashlytics"
    build :project => "MoPubSampleApp", :target => "MoPubSampleApp"

    if should_switch_git_branch
      system_or_exit(%Q[git co #{current_branch}])
      sleep 2

      head "Cleaning up"
      system_or_exit(%Q[rm -rf Crashlytics.framework/])
    end
  end

  desc "Run MoPub Sample App Integration Specs"
  task :kif do |t, args|
    head "Building KIF Integration Suite"
    build :project => "MoPubSampleApp", :target => "SampleAppKIF"
    head "Running KIF Integration Suite"

    network_testing = NetworkTesting.new

    kif_log_file = nil
    network_testing.run_with_proxy do
      kif_log_file = run_in_simulator(:project => "MoPubSampleApp", :target => "SampleAppKIF", :success_condition => "TESTING FINISHED: 0 failures", :record_video => ENV['IS_CI_BOX'])
    end

    network_testing.verify_kif_log_lines(File.readlines(kif_log_file))
  end
end

desc "Remove any focus from specs"
task :nof do
  system_or_exit %Q[ grep -l -r -e "\\(fit\\|fdescribe\\|fcontext\\)" Specs | grep -v -e 'Specs/Frameworks' -e 'JasmineSpecs' | xargs -I{} sed -i '' -e 's/fit\(@/it\(@/g;' -e 's/fdescribe\(@/describe\(@/g;' -e 's/fcontext\(@/context\(@/g;' "{}" ]
end

desc "Run jasmine specs"
task :run_jasmine do
  head "Running jasmine"
  Dir.chdir('Specs/JasmineSpecs/SpecsApp') do
    # NOTE: for this task to run, you must have already run 'npm install' in the Jasminespecs/SpecsApp dir
    # test runner is in a node app that requires the mraid.js file to be in a specific path
    system_or_exit(%Q[cp ../../../MoPubSDK/Resources/MRAID.bundle/mraid.js webapp/static/vendor/mraid.js])
    begin
        system_or_exit(%Q[node node_modules/jasmine-phantom-node/bin/jasmine-phantom-node webapp/static/tests])
    ensure
        system_or_exit(%Q[rm webapp/static/vendor/mraid.js])
    end
  end
end

