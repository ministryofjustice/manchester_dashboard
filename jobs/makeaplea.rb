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

  # Next hearings
  week_hearings_endpoint = URI(base_url + "/v0/stats/by_hearing/?format=json")

  # last 6 months by week
  by_week_endpoint = URI(base_url + "/v0/stats/by_week/?format=json")

  # By region
  by_court_endpoint = URI(base_url + "/v0/stats/by_court/?format=json")

  res = Net::HTTP::get_response(stats_endpoint)
  stats = JSON.parse(res.body)

  res = Net::HTTP::get_response(week_hearings_endpoint)
  hearing_stats = JSON.parse(res.body)

  res = Net::HTTP::get_response(by_week_endpoint)
  by_week = JSON.parse(res.body)
  
  res = Net::HTTP::get_response(by_court_endpoint)
  by_court = JSON.parse(res.body)


  # Next hearing dates
  week_hearings = {}

  hearing_stats.each do |item|
    prefix = item['hearing_day']
    dt = Date.parse(item['hearing_day'])

    heading = dt.strftime("%a %d %b %Y")

    week_hearings[prefix+"_heading"] = {
        :heading=>true,
        :label=>heading,
        :value=>""
    }

    week_hearings[prefix+"_submissions"] = {
        :label=>"Submissions",
        :value=>item['submissions']
    }

    week_hearings[prefix+"_guilty"] = {
        :label=>"Guilty",
        :value=>item['guilty']
    }

    week_hearings[prefix+"_not_guilty"] = {
        :label=>"Not Guilty",
        :value=>item['not_guilty']
    }
  end

  # Graph by week
  by_week_graph = {
      "chart" => {
          "type" => "column",
          "renderTo" => "usage_graph"
      },
      "title" => {
          "text" => 'Make a Plea usage stats by week'
      },
      "subtitle" => {
          "text" => ""
      },
      "xAxis" => {
          "categories" => by_week.map {|item| Date.parse(item['start_date']).strftime("%d %b %Y")},
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
        "renderTo" => "courts_graph"
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

  send_event('usage_graph', {data: by_week_graph})
  send_event('regions_graph', {data: by_court_graph})
  send_event('guilty_pleas_to_date',   { current: stats['pleas']['to_date']['guilty'] })
  send_event('not_guilty_pleas_to_date',   { current: stats['pleas']['to_date']['not_guilty'] })
  send_event('submissions_to_date',   { current: stats['submissions']['to_date'] })
  send_event('week_hearings',   { :items=>week_hearings.values })

end
