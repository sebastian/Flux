HOW_MANY = 3000

tags = %w{snacks food tea flight vacation book movie music apps misc cinema dinner rent coffee}
descriptions = ["Some sample description", "This is something I regret",
  "My mother told me NOT to buy this", "Gifts for friends", "Cinema tickets, yet again",
  "Books (fun ones)", "Dinner with THA LEMON PIE", "Sweets", "Yet another expense",
  "Have to start saving now..."]
kroners = %w{20 30 23 342 21 4 0 12 43 5 21 12 424 29 3 69 3 22 34 34 48 19 73 6 82}
ores = %{20 25 50 0 0 0 0 0 99 79 89 39 49 0 0 0 0 0 10 0 20 0 30}
lats = %{1.0 1.020 4.00 6.234 1.23 0.24 52.02 34.34 0.001 23.24}
lngs = %{1.0 1.020 4.00 6.234 1.23 0.24 52.02 34.34 0.001 23.24}
days = (1..31).to_a
months = %w{01 02 03 04 05 06 07 08 09 10 11 12}
years = (2007..2009).to_a
currencies = %w{EUR GBP GBP GBP GBP GBP NOK NOK NOK NOK NOK NOK NOK NOK NOK EUR EUR USD USD NOK}
expenses = %w{1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1}
minutes = (0..59).to_a
hours = (0..24).to_a
seconds = (0..59).to_a


def choose_one_of_the(what)
  what[(rand * what.size).floor]
end

puts "<transactions>"
HOW_MANY.times do 
  day = choose_one_of_the(days)
  month = choose_one_of_the(months)
  year = choose_one_of_the(years)
  hour = choose_one_of_the(hours)
  minute = choose_one_of_the(minutes)
  second = choose_one_of_the(seconds)
  
  chosen_tags = ""
  (rand*4 + 1).floor.times do 
    chosen_tags += "#{choose_one_of_the(tags)} "
  end
  chosen_tags.strip!
  
  puts "\t<transaction>"
  puts "\t\t<transactionDescription>#{choose_one_of_the(descriptions)}</transactionDescription>"
  puts "\t\t\t<kroner>#{choose_one_of_the(kroners)}</kroner>"
  puts "\t\t\t<ore>#{choose_one_of_the(ores)}</ore>"
  puts "\t\t\t<expense>#{choose_one_of_the(expenses)}</expense>"
  puts "\t\t\t<lat>#{(rand*20).floor * rand}</lat>"
  puts "\t\t\t<lng>#{(rand*20).floor * rand}</lng>"
  puts "\t\t\t<yearMonth>#{year}#{month}</yearMonth>"
  puts "\t\t\t<day>#{day}</day>"
  puts "\t\t\t<date>#{day}/#{month}/#{year} #{hour}:#{minute}:#{second}</date>"
  puts "\t\t\t<currency>#{choose_one_of_the(currencies)}</currency>"
  puts "\t\t\t<tags>#{chosen_tags}</tags>"
  puts "\t\t</transaction>"  
end
puts "</transactions>"