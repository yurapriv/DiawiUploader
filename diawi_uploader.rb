require 'json'
require 'uri'

class DiawiUploader

  def initialize
  end

  def download_link_for_file(path = '', token = '', find_by_udid = 0, wall_of_apps = 0, comment = '')

    @token = token

    result = {}
    result[:link] = 'NO LINK'
    result[:message] = 'NO MESSAGE'
    result[:success] = 0
    result[:days_before_expiration] = 6 # default for free accounts

    if @token.length == 0
      result[:message] = 'ERROR: Diawi API token not provided'
      return result
    elsif path.length == 0
      result[:message] = 'ERROR: Path to file not provided'
      return result
    end

    upload_response = upload_ipa_with_parameters(:path => path,
                                                 :find_by_udid => find_by_udid,
                                                 :wall => wall_of_apps,
                                                 :comment => comment)

    if upload_response == nil
      result[:message] = 'ERROR ON UPLOAD'
      return result
    end

    if (job_id = upload_response['job'])
      link = get_download_link(job_id)
      if link =~ URI.regexp
        result[:success] = 1
        result[:link] = link
      end
    end

    result
  end

  def get_download_link(job)

    download_link = 'NO LINK'

    1.upto(10) do |status_request_count|
      puts "status request = #{status_request_count}"

      status_response = request_status_for_job_id(job)

      if (status = status_response['status'])

        case status
          when 2000
            download_link = status_response['link']
            break
          when 2001
            puts "WAIT: #{status_response['message']}"

          when 4000
            download_link = "ERROR: #{status_response['message']}"
            break
          else
            download_link = "Unknown status: #{status}"
            break
        end

      end

      sleep 1

    end

    download_link
  end

  def upload_ipa_with_parameters(params)
    upload_response = `curl https://upload.diawi.com/ -F token='#{@token}' -F file=@#{params[:path]} -F find_by_udid=#{params[:find_by_udid]} -F wall_of_apps=#{params[:wall]} -F comment='#{params[:comment]}'`
    puts "upload_response = #{upload_response}"
    if is_json?(upload_response)
      return JSON.parse(upload_response)
    end
    nil
  end

  def request_status_for_job_id(job_id)
    status_response = `curl 'https://upload.diawi.com/status?token=#{@token}&job=#{job_id}'`
    puts "status_response = #{status_response}"
    if is_json?(status_response)
      return JSON.parse(status_response)
    end
    nil
  end

  def is_json?(string)
    begin
      JSON.parse(string)
    rescue JSON::ParserError => e
      return false
    end
    true
  end

end