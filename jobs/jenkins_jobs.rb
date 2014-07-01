require 'net/http'
require 'json'

http = nil

SCHEDULER.every '1s', :first_in => 0 do
  if not defined? settings.jenkins?
    next
  end

  if nil == http
    url  = URI.parse(settings.jenkins['url'])
    http = Net::HTTP.new(url.host, url.port)

    if ('https' == url.scheme)
      http.use_ssl     = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
  end

  api_url  = '%s/view/%s/api/json?tree=jobs[name,color,number,lastBuild[number,timestamp],healthReport[*]]' \
             % [ settings.jenkins['url'].chomp('/'), settings.jenkins['view'] ]
  response = http.request(Net::HTTP::Get.new(api_url))
  jobs     = JSON.parse(response.body)['jobs']

  if jobs.empty?
    next
  end

  jobs.map! { |job|
    color = 'grey'

    case job['color']
    when 'notbuilt'
      color = 'notbuilt'
    when 'blue'
      color = 'blue'
    when 'red'
      color = 'red'
    end

    { 
      name: job['name'].gsub('CLA',''),
      state: color,
      number: job['lastBuild'] ? job['lastBuild']['number'] : 0,
      timestamp: job['lastBuild'] ? job['lastBuild']['timestamp'] : 0,
      health: job['healthReport'].length > 0 ? job['healthReport'][0]['iconUrl'].chomp('.png') : nil
    }
  }

  jobs.sort_by { |job| job['name'] }

  send_event('jenkins_jobs', { jobs: jobs })
end