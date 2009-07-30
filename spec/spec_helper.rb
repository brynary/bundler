$:.unshift File.expand_path(File.join(File.dirname(__FILE__)))
$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require "rubygems"
require "bundler"

require "spec"
require "matchers"
require "builders"
require "rbconfig"

class Pathname
  def mkdir_p
    FileUtils.mkdir_p(self)
  end

  def touch_p
    dirname.mkdir_p
    touch
  end

  def touch
    FileUtils.touch(self)
  end

  def cp(*args)
    FileUtils.cp(self, *args)
  end

  def cp_r(*args)
    FileUtils.cp_r(self, *args)
  end
end

module Spec
  module Helpers
    def this_file
      Pathname.new(__FILE__).expand_path.dirname
    end

    def tmp_dir(*path)
      this_file.join("..", "tmp").join(*path)
    end

    alias tmp_file tmp_dir

    def tmp_gem_path(*path)
      tmp_file("vendor", "gems").join(*path)
    end

    def tmp_bindir(*path)
      tmp_file("bin").join(*path)
    end

    def cached(gem_name)
      tmp_dir.join('cache', "#{gem_name}.gem")
    end

    def fixture_dir(*args)
      this_file.join("fixtures").join(*args)
    end

    alias fixture_file fixture_dir

    def gem_repo1(*args)
      fixture_dir("repository1").join(*args)
    end

    def gem_repo2(*args)
      fixture_dir("repository2").join(*args)
    end

    def gem_repo3(*args)
      fixture_dir("repository3").join(*args)
    end

    def very_simple(*args)
      fixture_dir("very-simple").join(*args)
    end

    def fixture(gem_name)
      gem_repo1("gems", "#{gem_name}.gem")
    end

    def copy(gem_name)
      fixture(gem_name).cp(tmp_dir.join('cache'))
    end

    def run_in_context(*args)
      cmd = args.pop.gsub(/(?=")/, "\\")
      env = args.pop || tmp_file("vendor", "gems", "environments", "default")
      %x{#{Gem.ruby} -r #{env} -e "#{cmd}"}.strip
    end

    def gem_command(command, args = "")
      args = args.gsub(/(?=")/, "\\")
      lib  = File.join(File.dirname(__FILE__), '..', 'lib')
      %x{#{Gem.ruby} -I#{lib} -rubygems -S gem #{command} #{args}}
    end

    def build_manifest_file(*args)
      path = tmp_file("Gemfile")
      path = args.shift if args.first.is_a?(Pathname)
      str  = args.shift || ""
      FileUtils.mkdir_p(path.dirname)
      File.open(path, 'w') do |f|
        f.puts str
      end
    end

    def build_manifest(*args)
      path = tmp_file("Gemfile")
      path = args.shift if args.first.is_a?(Pathname)
      str  = args.shift || ""
      FileUtils.mkdir_p(path.dirname)
      Dir.chdir(path.dirname) do
        build_manifest_file(path, str)
        Bundler::ManifestFile.load(path)
      end
    end

    def reset!
      tmp_dir.rmtree if tmp_dir.exist?
      tmp_dir.mkdir
    end
  end
end

Spec::Runner.configure do |config|
  config.include Spec::Builders
  config.include Spec::Matchers
  config.include Spec::Helpers

  original_wd = Dir.pwd

  config.before(:each) do
    @log_output = StringIO.new
    Bundler.logger.instance_variable_set("@logdev", Logger::LogDevice.new(@log_output))
    reset!
  end

  config.after(:each) do
    Dir.chdir(original_wd)
  end
end
