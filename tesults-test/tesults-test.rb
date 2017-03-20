require 'tesults'

if __FILE__ == $0
    
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
                                :result => "pass"
                                
                                },
                            {
                                :name => "Test 3",
                                :desc => "Test 3 description",
                                :suite => "Suite A",
                                :result => "fail",
                                :reason => "Assert fail in line 203 of example.rb"
                                
                                }
                        ]
                }
        }
    
    res = Tesults.upload(data)
    puts res[:success]
    puts res[:message]
end