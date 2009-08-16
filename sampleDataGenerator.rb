require "time"

HOW_MANY = 500

tags = %w{snacks food tea flight vacation book movie music apps misc cinema dinner rent coffee}
descriptions = ["Incredibly nice item", "This is something I regret",
  "My mother told me NOT to buy this", "Gifts for friends", "Cinema tickets, yet again",
  "Books (fun ones)", "Dinner with THA LEMON PIE", "Sweets", "Yet another expense",
  "Have to start saving now...", "I wish I had bought this last year", "This is the bestest",
  "I'll buy another tomorrow", "Maybe this will work?"]
kroners = (250..2500).to_a
lat = 59.9
lng = 10.7
days = (1..31).to_a
months = %w{01 02 03 04 05 06 07}
years = (2009).to_a
currencies = %w{EUR GBP GBP GBP GBP GBP NOK NOK NOK NOK NOK NOK NOK NOK NOK EUR EUR USD USD NOK}
expenses = %w{1 0}
minutes = (0..59).to_a
hours = (0..24).to_a
seconds = (0..59).to_a
weekday_names = %w{Monday Tuesday Wednesday Thursday Friday Saturday Sunday}
month_names = %w{January February March April May June July August September October November December}

def choose_one_of_the(what)
  what[(rand * what.size).floor]
end

puts "<transactions>"
HOW_MANY.times do 
  day = choose_one_of_the(days)
  month = choose_one_of_the(months)
  
  # Check for february
  day = 28 if (month == 2) and (day > 28)
    
  # Check for the months that only have 30 days
  day = 30 if (day > 30) and (month == 4) 
  day = 30 if (day > 30) and (month == 6) 
  day = 30 if (day > 30) and (month == 9) 
  day = 30 if (day > 30) and (month == 11) 
  
  year = choose_one_of_the(years)
  hour = choose_one_of_the(hours)
  minute = choose_one_of_the(minutes)
  second = choose_one_of_the(seconds)
  
  chosen_tags = ""
  (rand*4 + 1).floor.times do 
    chosen_tags += "#{choose_one_of_the(tags)} "
  end
  chosen_tags.strip!
  
  time_string = "#{day}/#{month}/#{year} #{hour}:#{minute}:#{second}"
  time = Time.parse("#{month}/#{day}/#{year}")
  autotags = "#{weekday_names[(time.wday - 1)].downcase} #{month_names[(time.month - 1)].downcase}"
  
  puts "\t<transaction>"
  puts "\t\t<transactionDescription>#{choose_one_of_the(descriptions)}</transactionDescription>"
  puts "\t\t\t<kroner>#{choose_one_of_the(kroners)}</kroner>"
  puts "\t\t\t<expense>#{choose_one_of_the(expenses)}</expense>"
  puts "\t\t\t<lat>#{lat}#{(rand*100000).floor}</lat>"
  puts "\t\t\t<lng>#{lng}#{(rand*100000).floor}</lng>"
  puts "\t\t\t<yearMonth>#{year}#{month}</yearMonth>"
  puts "\t\t\t<day>#{day}</day>"
  puts "\t\t\t<date>#{time_string}</date>"
  puts "\t\t\t<currency>#{choose_one_of_the(currencies)}</currency>"
  puts "\t\t\t<tags>#{chosen_tags}</tags>"
  puts "\t\t\t<autotags>#{autotags}</autotags>"
  puts "\t\t</transaction>"  
end
puts "</transactions>"
