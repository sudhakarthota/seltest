require 'rdoc/task'

#task :clean do
#    system "ruby -rubygems resetdb.rb"
#end

task :ssts, [:suite, :test_name] do |t, args|

    if args.suite
      if File.exist?("smoke_test/#{args.suite}.rb")
        folder_name = 'smoke_test'
      elsif File.exist?("regression/#{args.suite}.rb")
         folder_name = 'regression'
      end
      suite = args.suite
      system "ruby -rubygems resetdb.rb"
          if args.test_name
            system "ruby -rubygems #{folder_name}/#{suite}.rb --name test_#{args.test_name} >> #{folder_name}_output.log"
          else
            system "ruby -rubygems #{folder_name}/#{suite}.rb >> #{folder_name}_output.log"
          end
    else
        Dir.glob('smoke_test/*.rb') do |file|
            system "ruby -rubygems resetdb.rb"
            suite = File.basename file
            system "ruby -rubygems smoke_test/#{suite} >>  smoke_test_output.log"
        end
        Dir.glob('regression/*.rb') do |file|
            system "ruby -rubygems resetdb.rb"
            suite = File.basename file
            system "ruby -rubygems regression/#{suite} >>  regression_output.log"
        end
    end
    system "ruby -rubygems suite_status.rb"    
end

#  To genrate Selenium Documentation using RDoc
RDoc::Task.new :selenium_doc do |rdoc|
  rdoc.title = "<b> Smoke TestCases </b>"
  rdoc.rdoc_dir="documentation"
  rdoc.rdoc_files.include( "README.rdoc","smoke_test/*.rb")
  rdoc.options << "--all"
end
