require 'json'

class DiawiUploader

  def initialize
  end

  def download_link_for_file(path = '', token = '')

    @token = token
    @path = path

    if @token.length == 0
      return 'ERROR: Diawi API token not provided'
    elsif @path.length == 0
      return 'ERROR: Path to file not provided'
    end

    upload_response = upload_ipa_from_path(@path)
    if upload_response == nil
      return 'ERROR ON UPLOAD'
    end

    result = 'NO RESULT'

    if (job_id = upload_response['job'])
      result = get_download_link(job_id)
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

  def upload_ipa_from_path(path)
    upload_response = `curl https://upload.diawi.com/ -F token='#{@token}' -F file=@#{path} -F find_by_udid=0 -F wall_of_apps=0`
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