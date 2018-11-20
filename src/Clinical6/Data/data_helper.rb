require 'json'
require 'csv'

class DataHandler

  TEST_FILE = File.dirname(__FILE__) + '/test_data.json'

  def self.get_env(env)
    file = File.read(TEST_FILE)
    data_hash = JSON.parse(file)
    data_hash["environments"]["#{env}"]
  end

  def self.get_env_user(env_hash, user_type)

    case user_type
    when :super_user
      env_hash["superuser1"]
    when :unauthorized_user
      env_hash["unauthorizeduser1"]
    when :invalid_user
      env_hash["invaliduser1"]
    when :mobile_user
      env_hash["mobileuser1"]
    end
  end

  def self.get_test_data(testname)
    file = File.read(TEST_FILE)
    data_hash = JSON.parse(file)
    data_hash["tests"]["#{testname}"]
  end

  def self.change_test_data_value(testname, key, value)
    file = File.read(TEST_FILE)
    data_hash = JSON.parse(file)
    data_hash["tests"]["#{testname}"]["#{key}"] = "#{value}"
    File.open(TEST_FILE,"w") do |f|
      f.write(JSON.pretty_generate(data_hash))
    end
  end

  def self.read_csv_file(csvfile)
    CSV.foreach(csvfile, headers: true) do |row|
      puts row
    end
  end

  def self.traverse_dir_csv(file_path, name)
    if File.directory? file_path
      Dir.foreach(file_path) do |file|
        if file != "." and file != ".."
          traverse_dir(file_path + '/' + file, name)
        end
      end
    else
      if File.basename(file_path)[/\.[^\.]+$/] == '.csv' and File.basename(file_path).include?(name)
        open_csv_file(File.basename(file_path))
      end
    end
  end
end


