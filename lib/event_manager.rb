#tutorial from http://tutorials.jumpstartlab.com/projects/eventmanager.html done as part of
#odin project file i/o and serialization project
require "csv"
require "sunlight/congress"
require 'erb'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"


def clean_zipcode(zipcode)
	zipcode.to_s.rjust(5, "0")[0..4]
end		 	

def legislators_by_zipcode(zipcode)
	Sunlight::Congress::Legislator.by_zipcode(zipcode)
end 

def save_thank_you_letters(id,form_letter)
	Dir.mkdir("output") unless Dir.exists?("output")
	
	filename = "output/thanks_#{id}.html"

	File.open(filename, 'w') do |file|
		file.puts form_letter
	end	
end

def clean_phone_no(number)
	number = number.to_s.tr('^0-9', '')
	
	if number.length.between?(10,11)
		if number.length == 10
			return number			
		else
			if number[0] == "1"
				number = number[1..10]
				return number
			else
				return "Bad Number"
			end		
		end
	else
		return "Bad Number"	
	end	
end

	
puts "Event Manager Initialized!!!"

contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

contents.each do |row|
	id = row[0]
	name = row[:first_name]
	phone_no = clean_phone_no(row[:homephone]) #this checks the phone number but i'm not doing anything else with that number at the moment.
	zipcode = clean_zipcode(row[:zipcode])
	legislators = legislators_by_zipcode(zipcode)	

	form_letter =  erb_template.result(binding)

	save_thank_you_letters(id,form_letter)
	
end

#todo time targeting