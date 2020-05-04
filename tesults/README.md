# Tesults

Tesults is a test automation results reporting service. https://www.tesults.com

Tesults API library for uploading test results to Tesults in your Ruby application.

## Installation

`gem install tesults`

## Configuration

 ```rb
require 'tesults'
```

## API Overview

Upload test results using the Results.upload method:

```rb
res = Tesults.upload(data)
puts 'Success: ' + (res[:success] ? "true" : "false") # success is a Boolean, true if results successfully uploaded, false otherwise
puts 'Message: ' + res[:message] # message is a String, if success is false, check message to see why upload failed
puts 'Warnings: ' + res[:warnings].length.to_s # warnings is an Array of Strings, if size is not zero there may be issues with file uploads
puts 'Errors: ' + res[:errors].length.to_s # errors is an Array of Strings, if success is true then this will be empty
```

The data param in upload is a Hash containing your test results in the form:

```rb
data = {
            :target => "token",
            :results => {
                    :cases => [
                            {
                                :name => "Test 1",
                                :desc => "Test 1 description",
                                :suite => "Suite A",
                                :result => "pass"
                                
                                },
                        
                            {
                                :name => "Test 2",
                                :desc => "Test 2 description",
                                :suite => "Suite B",
                                :result => "pass",
                                :params => {:param1 => "value1", :param2 => "value2"} # optional
                                
                                },
                            {
                                :name => "Test 3",
                                :desc => "Test 3 description",
                                :suite => "Suite A",
                                :result => "fail",
                                :reason => "Assert fail in line 203 of example.rb", # optional
                                :files => ["/full/path/to/file/log.txt"] # optional
                                
                                }
                        ]
                }
        }
```

The target value, 'token' above should be replaced with your Tesults target token. If you have lost your token you can regenerate one at https://www.tesults.com/config. The cases Array should contain your test cases.

## Support

support@tesults.com

