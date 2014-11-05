require 'net/http'
require 'json'
require 'date'

SCHEDULER.every '1h', :first_in => 0 do
  base_url = "http://localhost:8000"
  #base_url = "https://makeaplea.dsd.io"
  base_url = 'https://www.makeaplea.justice.gov.uk'

  endpoint = URI(base_url + "/api/v1.0/usage-stats/?format=json")
  hearing_endpoint = URI(base_url + "/api/v1.0/usage-stats/hearing/?format=json")

  res = Net::HTTP::get_response(endpoint)
  stats = JSON.parse(res.body)

  res = Net::HTTP::get_response(hearing_endpoint)
  hearing_stats = JSON.parse(res.body)

  list_data = {} 
  hearing_stats.each do |item|
    prefix = item['hearing_day']
    dt = Date.parse(item['hearing_day'])

    heading = dt.strftime("%a %d %b %Y")

    list_data[prefix+"_heading"] = {
        :heading=>true,
        :label=>heading,
        :value=>""
    }

    list_data[prefix+"_submissions"] = {
        :label=>"Submissions",
        :value=>item['submissions']
    }

    list_data[prefix+"_guilty"] = {
        :label=>"Guilty",
        :value=>item['guilty']
    }

    list_data[prefix+"_not_guilty"] = {
        :label=>"Not Guilty",
        :value=>item['not_guilty']
    }

  end 

  send_event('guilty_pleas_to_date',   { current: stats['pleas']['to_date']['guilty'] })
  send_event('not_guilty_pleas_to_date',   { current: stats['pleas']['to_date']['not_guilty'] })
  #send_event('optional_fields_percentage',   { value: stats['additional']['subs_with_optional_fields_percentage'], min: 0, max: 100})
  #send_event('optional_fields_percentage',   { text: stats['additional']['subs_with_optional_fields_percentage'] +"%"})
  send_event('submissions_to_date',   { current: stats['submissions']['to_date'] })
  send_event('detail',   { :items=>list_data.values })
end
