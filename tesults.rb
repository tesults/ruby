require 'json'
require 'uri'
require 'net/https'
require 'aws-sdk-s3'

class Tesults
    @@expire_buffer = 30 # 30 seconds
    @@files_uploaded = 0
    @@bytes_uploaded = 0
    @@uploading = []
    @@warnings = []

    def self.create_s3_client(credentials)
        s3_client = Aws::S3::Client.new(
            region: 'us-east-1',
            access_key_id: credentials['AccessKeyId'],
            secret_access_key: credentials['SecretAccessKey'],
            session_token: credentials['SessionToken']
        )
        Aws::S3::Resource.new(client: s3_client)
    end

    def self.refresh_credentials(target, key)
        data = {:target => target, :key => key}
        uri = URI("https://www.tesults.com/permitupload")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
        req.body = data.to_json
        res = http.request(req)
        jsonData = JSON.parse(res.body)
        success = false
        message = ""
        upload = nil
        if jsonData['error'] == nil
            success = true
            d = jsonData['data']
            message = d['message']
            upload = d['upload']
        else
            success = false
            err = jsonData['error']
            message = err['message']
        end
        val = {:success => success, :message => message, :upload => upload}
    rescue => e
        return {:success => false, :message => e.message, :upload => nil}

    end

    def self.transfer(file, bytes, key, auth)
        Thread.new {
            s3 = create_s3_client(auth)
            increment = 1
            bytes_increment = bytes
            begin
                result = s3.bucket('tesults-results').object(key).upload_file(file)
            rescue
                # upload failed
                increment = 0
                bytes_increment = 0
            ensure
                if result != true
                    increment = 0
                    bytes_increment = 0
                end
                @@files_uploaded += increment
                @@bytes_uploaded += bytes_increment
                @@uploading.delete_at @@uploading.index file
            end
        }
        
    end

    def self.files_upload(files, keyPrefix, auth, target)
        expiration_string = auth['Expiration']
        expiration = expiration_string.to_i
        max_active_uploads = 10 # Upload at most 10 files simultaneously to avoid hogging the client machine.

        while files.length != 0 || @@uploading.length != 0 do
            begin
                if @@uploading.length < max_active_uploads && files.length != 0
                    # Check if new credentials required.
                    now = Time.now.to_i
                    if now + @@expire_buffer > expiration # Check within 30 seconds of expiry.
                        # Refresh credentials.
                        if @@uploading.length == 0
                            # Wait for all current transfers to complete so we can set a new s3 client.
                            response = refresh_credentials(target, keyPrefix)
                            if response[:success] != true
                                # Must stop upload due to failure to be permitted for new credentials.
                                @@warnings.push(response[:message])
                                break
                            else
                                upload = response[:upload]
                                key = upload['key']
                                upload_message = upload['message']
                                permit = upload['permit']
                                auth = upload['auth']
                                if permit != true
                                    # Must stop upload due to failure to be permitted for new credentials.
                                    @@warnings.push(upload_message)
                                    break
                                else
                                    # Upload permitted.
                                    expiration_string = auth['Expiration']
                                    expiration = expiration_string.to_i
                                end
                            end
                        end
                    end

                    if now + @@expire_buffer < expiration
                        # Load new file for upload.
                        f = files.shift
                        if File.file?(f[:file])
                            fname = File.basename f[:file]
                            key = keyPrefix + '/' + f[:num].to_s + '/' + fname
                            @@uploading.push(f[:file])
                            transfer(f[:file], File.size(f[:file]),  key, auth)
                        else
                            @@warnings.push('File not found: ' + f[:file])
                        end
                    end
                end

                # Check if existing upload complete - handled by each transfer.
            rescue => e
                @@warnings.push(e.message)
            end
        end

        return {:message => '. ' + @@files_uploaded.to_s + ' files uploaded. ' + @@bytes_uploaded.to_s + ' bytes uploaded.', :warnings => @@warnings}
    end

    def self.files_in_test_cases(data)
        results = data[:results]
        cases = results[:cases]
        files = []
        num = 0
        cases.each do |c|
            c_files = c[:files]
            if c_files == nil
                next
            else
                c_files.each do |f|
                    files.push({:num => num, :file => f})
                end
            end
            num += 1
        end
        return files
    end

    def self.upload(data)
        begin
            uri = URI("https://www.tesults.com/results")
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
            req.body = data.to_json
            res = http.request(req)
            jsonData = JSON.parse(res.body)
            success = false
            message = ""
            if jsonData['error'] == nil
                success = true
                d = jsonData['data']
                message = d['message']
                upload = d['upload']

                if upload == nil
                    # No files to upload, complete.
                    val = {:success => success, :message => message, :warnings => [], :errors => []}
                else
                    # Upload files.
                    target = data[:target]
                    files = files_in_test_cases(data)

                    key = upload['key']
                    upload_message = upload['message']
                    permit = upload['permit']
                    auth = upload['auth']

                    if permit != true
                        val = {:success => success, :message => message, :warnings => [uploadMessage], :errors => []}
                    else
                        # Upload required and permitted.
                        begin
                            file_upload_return = files_upload(files, key, auth, target) # This can take a while
                            upload_message = file_upload_return[:message]
                        rescue => e
                           @@warnings.push(e.message)
                           upload_message = '. View warnings.'
                        ensure
                            return {:success => success, :message => "Success" + upload_message.to_s, :warnings => @@warnings, :errors => []}
                        end
                    end
                end
             else   
                success = false
                error = jsonData['error']
                message = error['message']
                return {:success => success, :message => message, :warnings => [], :errors => [message]}
            end
        rescue => e
            return {:success => false, :message => e.message, :warnings=> [], :errors => [e.message]}
        end
    end
end