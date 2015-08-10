require 'net/http'
require 'json'
require 'date'

SCHEDULER.every '1h', :first_in => 0 do

  release_stage = ENV['RELEASE_STAGE'] || "production"
  
  case release_stage
    when "local"
      base_url = "http://localhost:8001"
    when "dev"
      base_url = "http://api.dev.makeaplea.dsd.io"
    when "staging"
      base_url = "http://api.makeaplea.dsd.io"
    else
      base_url = "http://api.makeaplea.justice.gov.uk"
  end

  stats_endpoint = URI(base_url + "/v0/stats/?format=json")

  # last 6 months by week
  by_week_endpoint = URI(base_url + "/v0/stats/by_week/?format=json")

  # By court
  by_court_endpoint = URI(base_url + "/v0/stats/by_court/?format=json")

  # Response time
  response_time_endpoint = URI(base_url + "/v0/stats/days_from_hearing/?format=json")


  res = Net::HTTP::get_response(stats_endpoint)
  stats = JSON.parse(res.body)

  res = Net::HTTP::get_response(by_week_endpoint)
  by_week = JSON.parse(res.body)
  
  res = Net::HTTP::get_response(by_court_endpoint)
  by_court = JSON.parse(res.body)

  res = Net::HTTP::get_response(response_time_endpoint)
  response_time = JSON.parse(res.body)


  # Graph by week
  by_week_graph = {
      "chart" => {
          "type" => "column",
          "renderTo" => "by_week_graph"
      },
      "title" => {
          "text" => 'Make a Plea usage stats by week'
      },
      "subtitle" => {
          "text" => ""
      },
      "xAxis" => {
          "categories" => by_week.each_with_index.map {|item,index| index % 2 == 0 ? Date.parse(item['start_date']).strftime("%d %b %Y") : ""},
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
              "stacking" => "normal",
              "borderWidth" => 0
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
      # Not available reliably at present
      # {
      #     "name" => "Requisitions posted",
      #     "data" => by_week.map {|item| !item['postal_requisitions'] ? 0 : item['postal_requisitions']},
      #     "stack" => "2"
      # },
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

  # Graph by regions
  by_court_graph = {
    "chart" => {
        "type" => "bar",
        "renderTo" => "by_court_graph"
    },
    "title" => {
        "text" => 'Make a Plea usage stats by court'
    },
    "subtitle" => {
        "text" => ""
    },
    "xAxis" => {
        "categories" => by_court.map {|item| item['court_name']},
        "labels" => {
          "type" => "category"
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
        "bar" => {
            "stacking" => "normal",
            "borderWidth" => 0
        }
    },
    "series" => [{
        "name" => "Online submissions",
        "data" => by_court.map {|item| item['submissions']},
        "stack" => "submissions"
    },
    {
        "name" => "Online not guilty pleas",
        "data" => by_court.map {|item| item['not_guilty']},
        "stack" => "pleas"
    },
    {
        "name" => "Online guilty pleas",
        "data" => by_court.map {|item| item['guilty']},
        "stack" => "pleas"
    },
    {
        "name" => "Postal responses",
        "data" => by_court.map {|item| !item['postal'] ? 0 : item['postal']},
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

  # Reponse time graph
  response_time_graph = {
    "chart" => {
        "type" => "spline"
    },
    "title" => {
        "text" => "Submissions by number of days to hearing"
    },
    "xAxis" => {
        "reversed" => true,
        "title" => {
            "text" => "Number of days to hearing"
          },
        "categories" => response_time.keys,
        "tickInterval" => 10
    },
    "yAxis" => {
        "allowDecimals" => false,
        "title" => {
            "text" => ""
        },
        "min" => 0
    },
    "series" => [{
        "name" => "Submissions",
        "data" => response_time.map {|item| item},
        "type" => "spline",
        "showInLegend" => false
    }],
    "plotOptions" => {
        "spline" => {
                "marker" => {
                    "enabled" => false
                }
            }
    }
  }

  send_event('by_week_graph', {data: by_week_graph})
  send_event('by_court_graph', {data: by_court_graph})
  send_event('response_time_graph', {data: response_time_graph})
  send_event('guilty_pleas_to_date',   { current: stats['pleas']['to_date']['guilty'] })
  send_event('not_guilty_pleas_to_date',   { current: stats['pleas']['to_date']['not_guilty'] })
  send_event('submissions_to_date',   { current: stats['submissions']['to_date'] })

end
