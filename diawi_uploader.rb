require 'json'

class DiawiUploader

  def initialize(token = '')
    @token = token
  end

  def download_link_for_file(path = '')

    if @token.length == 0
      return 'ERROR: Diawi API token not provided'
    elsif path.length == 0
      return 'ERROR: Path to file not provided'
    end

    upload_response = upload_ipa_from_path(path)
    parsed_upload_response = JSON.parse(upload_response)

    result = 'NO RESULT'

    if (job_id = parsed_upload_response['job'])

      1.upto(5) do |n|
        puts "status request = #{n}"

        status_response = request_status_for_job_id(job_id)
        parsed_status_response = JSON.parse(status_response)

        if (status = parsed_status_response['status'])
          case status
            when 2000
              result = parsed_status_response['link']
              break
            when 2001
              puts 'WAIT: ' + parsed_status_response['message']
            when 4000
              result = 'ERROR: ' + parsed_status_response['message']
              break
            else
              # type code here
              result = "Unknown status: #{status}"
          end
        end

        sleep 1 # second
      end

    end

    result
  end

  def upload_ipa_from_path(path)
    puts "path = #{path}"
    result = `curl https://upload.diawi.com/ -F token='#{@token}' -F file=@#{path} -F find_by_udid=0 -F wall_of_apps=0`
    puts "result = #{result}"

    result
  end

  def request_status_for_job_id(job_id)
    puts "job_id = #{job_id}"
    status = `curl 'https://upload.diawi.com/status?token=#{@token}&job=#{job_id}'`
    puts "status = #{status}"

    status
  end

end