require 'fileutils'

module Tres

module FileMethods
  def file? file
    File.exists? file
  end

  def dir? dir
    File.directory? dir
  end

  def change_dir to
    Dir.chdir to
  end

  def move from, to
    Tres.say(" Moving\t#{from} to #{to}") {
      Dir[from].each do |something| FileUtils.mv something, to end
    }
  end

  def copy from, to
    Tres.say(" Copying\t#{from} to #{to}") {
      Dir[from].each do |something|
        File.directory?(something) ? FileUtils.cp_r(something, to) : FileUtils.cp(something, to)
      end
    }
  end

  def new_dir dir, careful = true
    confirm "#{dir} already exists. Proceed?" if careful and dir?(dir)
    Tres.say(" Creating\t#{dir}") { FileUtils.mkdir_p dir }
  end

  def read_file file
    File.read file
  end
  
  def name_and_extension file
    [basename(file, extname(file)), extname(file).sub(/^./, '')]
  end

  def erb file
    ERB.new(read_file(file)).result(binding)
  end

  def json file
    begin
      JSON.parse read_file(file)
    rescue Errno::ENOENT
      raise Tres::NoSuchFile, "File #{file} doesn't exist"
    rescue 
      raise Tres::CantParseJSONFile, "File #{file} doesn't appear to be valid JSON"
    end
  end

  def expand path
    File.expand_path path
  end

  def dirname file
    File.dirname file
  end

  def mkdir_p dir
    FileUtils.mkdir_p dir
  end

  def extname file
    File.extname file
  end

  def basename file, take = ''
    File.basename file, take
  end

  def delete! file
    Tres.say " Deleting\t#{file}" do
      dir?(file) ? FileUtils.rm_rf(file) : FileUtils.rm(file) rescue nil
    end
  end

  def new_file path
    Tres.say "  #{file?(path) ? "Changing" : "Creating"}\t#{path}" do
      File.open path, 'w' do |file|
        yieldage = yield if block_given?
        file.write yieldage unless yieldage.empty? or not yieldage.is_a?(String)
      end
    end
  end

  private
  def confirm text
    Tres.say text
    !!(STDIN.gets =~ /yes|y/i) ? true : exit(-2)
  end
end

end