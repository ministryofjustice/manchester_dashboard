require 'nokogiri'
require 'open-uri'
require 'json'

SCHEDULER.every '5m', :first_in => 0 do

  path = 'manchester_traffic_offences_pleas/reports/coverage.xml' 
  #path = '/Users/lyndongarvey/Projects/manchester_traffic_offences_pleas/reports/coverage.xml' 

  begin   
    xml = Nokogiri::HTML(open(path))
    coverage = xml.xpath('//coverage/packages/package').first['line-rate']
  rescue
    coverage = "No coverage data available"
  end

  send_event('coverage',   { :text=> coverage})

end
