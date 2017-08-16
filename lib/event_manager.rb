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


def hour_report(array)

	reg_hash = Hash.new(0)
	array.each{|key| reg_hash[key] += 1}
	reg_hash = reg_hash.sort_by { |key, value| value }.reverse
	reg_hash
end

def convert_days(array)

	days_array = array.map do |i|
		day = i 
		case day
		when 0
			i = "Sunday"
		when 1
		  i = "Monday"
		when 2
			i = "Tuesday"
		when 3
			i = "Wednesday"
		when 4
			i = "Thursday"
		when 5
			i = "Friday"
		when 6
			i = "Saturday" 	
		end
	end	
	days_array
	
end

def day_report(array)
	reg_day_hash = Hash.new(0)
	array.each{ |key| reg_day_hash[key] += 1}
	reg_day_hash = reg_day_hash.sort_by {|key, value| value}.reverse
	reg_day_hash
	
end

def best_hour_day(final_report)
	Dir.mkdir("analysis") unless Dir.exists?("analysis")
	
	filename = "analysis/report.html"

	File.open(filename, 'w') do |file|
		file.puts final_report
	end	
end

def best_hour
	h_report = File.read "report.erb"
  erb_template = ERB.new h_report 

	contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol
	hours = []
	days = []
	contents.each do |row|
		datetime = DateTime.strptime(row[:regdate], '%m/%d/%y %H:%M')
	
		hours<<datetime.hour
		days<<datetime.wday
		
		

	end
	days = convert_days(days)   #converts wday number to day string
	puts days.inspect

	reg_results = hour_report(hours)
	day_results = day_report(days)
	pop_hour = hours.max_by { |i| hours.count(i) }
	final_report = erb_template.result(binding)
	best_hour_day(final_report)
	

end


best_hour


#take date, 

#as best hour method is in the contents each do it will have to accumulate the numbers somehow





