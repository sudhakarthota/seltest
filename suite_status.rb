gem "test-unit"
require "test/unit"
require 'rubygems'
require 'time'
require "active_support"

class Suite_Result < Test::Unit::TestCase

    def test_read_log
        i=0
        @bugs = 0
        @passed = 0
        @failed = 0
        @script_name = nil
        @status = nil
        @result = ""
        @bugs_smoke = 0
        @bugs_smoke_passed = 0
        @bugs_smoke_failed = 0
        @bugs_reg = 0
        @bugs_reg_passed = 0
        @bugs_reg_failed = 0
        file_path = Dir.pwd
        files=Dir[file_path+"/*.log"]
        
        for i in 0...files.length
        File.open(files[i], "r").each_line do |line|
            # count total number of scripts
            if(line.include?("Loaded suite "))
                @bugs+=1
                @script_name =  line.split("/")[1].strip
                if(files[i].include?("reg"))
                    @bugs_reg += 1
                elsif(files[i].include?("smoke"))
                    @bugs_smoke += 1
                end
            end
            # check script whether it is passed or failed
            if(line.include?("% passed"))
                result = line.split("%")[0]
                if(result.include?("100"))
                    @passed+=1
                    @status = "passed"
                    @color= "green"
                    # increment respective script count
                    if(files[i].include?("reg"))
                        @bugs_reg_passed += 1
                    elsif(files[i].include?("smoke"))
                        @bugs_smoke_passed += 1
                    end
                else
                    @failed+=1
                    @status = "failed"
                    @color="red"
                    # increment respective script count
                    if(files[i].include?("reg"))
                        @bugs_reg_failed += 1
                    elsif(files[i].include?("smoke"))
                        @bugs_smoke_failed += 1
                    end
                end
                @result += "<tr><td>"+ @script_name+ "</td> <td bgcolor='#{@color}'> "+@status+"</td></tr>"
            end
        end
        end
        suite = File.new("suite_result.html","w")
        suite.write("<table border='2'>")
        suite.write("<tr><td><b>Total Scripts : #{@bugs}</b></td> </tr>")
        suite.write("<tr><td><b>Number of Scripts Passed : #{@passed}</b></td> </tr>")
        suite.write("<tr><td><b>Number of Scripts Failed : #{@failed}</b></td> </tr>")
        suite.write("<tr><td><b>Number of Smoke-Test Scripts  : #{@bugs_smoke}</b></td> </tr>")
        suite.write("<tr><td><b>Number of Smoke-Test scripts Passed : #{@bugs_smoke_passed}</b></td> </tr>")
        suite.write("<tr><td><b>Number of Smoke-Test scripts Failed : #{@bugs_smoke_failed}</b></td> </tr>")
        suite.write("<tr><td><b>Number of Regression Scripts  : #{@bugs_reg}</b></td> </tr>")
        suite.write("<tr><td><b>Number of Regression Scripts Passed : #{@bugs_reg_passed}</b></td> </tr>")
        suite.write("<tr><td><b>Number of Regression Scripts Failed : #{@bugs_reg_failed}</b></td> </tr>")
        suite.write("</table>")
        suite.write("</br><h2>Individual Suite Status</h2></br>")
        suite.write("<table border='1'>")
        suite.write(@result)
        suite.write("</table>")
        suite.close
    end
end