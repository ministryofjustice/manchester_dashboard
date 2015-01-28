require 'net/http'
require 'json'
require 'date'

SCHEDULER.every '1h', :first_in => 0 do
  #base_url = "http://api.dev.makeaplea.dsd.io"
  #base_url = "http://localhost:8000"
  base_url = 'http://api.makeaplea.justice.gov.uk'

  endpoint = URI(base_url + "/v0/stats/?format=json")
  hearing_endpoint = URI(base_url + "/v0/stats/by_hearing/?format=json")
  all_hearing_endpoint = URI(base_url + "/v0/stats/all_by_hearing/?format=json")

  # last 6 months by week
  by_week_endpoint = URI(base_url + "/v0/stats/by_week/?format=json")

  res = Net::HTTP::get_response(endpoint)
  stats = JSON.parse(res.body)

  res = Net::HTTP::get_response(hearing_endpoint)
  hearing_stats = JSON.parse(res.body)

  res = Net::HTTP::get_response(all_hearing_endpoint)
  all_hearing_stats = JSON.parse(res.body)

  res = Net::HTTP::get_response(all_hearing_endpoint)
  all_hearing_stats = JSON.parse(res.body)

  res = Net::HTTP::get_response(by_week_endpoint)
  by_week = JSON.parse(res.body)

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

  index = 0

  guilty_data = []
  not_guilty_data = []
  submissions = []

    graph_config = {
        "chart" => {
            "type" => "column",
            "renderTo" => "usage_graph",
            "height" => 360,
        },
        "title" => {
            "text" => 'Makeaplea usage stats by week',
            "x" => -20
        },
        "subtitle" => {
            "text" => "",
            "x" => -20
        },
        "xAxis" => {
            "categories" => by_week.map {|item| item['start_date']},
            "labels" => {
	            "type" => "category",
	            "rotation" => -45
	        }
        },
        "yAxis" => {
            "title" => {
                "text" => ''
            },
            "plotLines" => [{
                "value" => 0,
                "width" => 1,
                "color" => "#808080"
            }],
            "min" => 0
        },
        "tooltip" => {
            "valueSuffix" => ""
        },
        "plotOptions" => {
            "column" => {
                "stacking" => "normal"
            }
        },
        "series" => [{
            "name" => "Online submissions",
            "data" => by_week.map {|item| item['online_submissions']},
            "stack" => "submissions"
        },
        {
            "name" => "Online not guilty pleas",
            "data" => by_week.map {|item| item['online_not_guilty_pleas']},
            "stack" => "pleas"
        },
        {
            "name" => "Online guilty pleas",
            "data" => by_week.map {|item| item['online_guilty_pleas']},
            "stack" => "pleas"
        },
        {
            "name" => "Requisitions posted",
            "data" => by_week.map {|item| !item['postal_requisitions'] ? 0 : item['postal_requisitions']},
            "stack" => "2"
        },
        {
            "name" => "Postal responses",
            "data" => by_week.map {|item| !item['postal_responses'] ? 0 : item['postal_responses']},
            "stack" => "submissions"
        }],
        "dataLabels" => {
            "enabled" => true,
            "rotation" => -90,
            "color" => "#FFFFFF",
            "align" => "right",
            "x" => 4,
            "y" => 10,
            "style" => {
                "fontSize" => "13px",
                "fontFamily" => "Verdana, sans-serif",
                "textShadow" => "0 0 3px black"
            }
        }
    }

  send_event('usage_graph', {data: graph_config})
  send_event('guilty_pleas_to_date',   { current: stats['pleas']['to_date']['guilty'] })
  send_event('not_guilty_pleas_to_date',   { current: stats['pleas']['to_date']['not_guilty'] })
  send_event('submissions_to_date',   { current: stats['submissions']['to_date'] })
  send_event('detail',   { :items=>list_data.values })

end
