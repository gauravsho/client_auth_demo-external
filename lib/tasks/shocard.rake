namespace :shocard do

  desc "Create a new shocard"
  task :new => :environment do
    puts("Initializing ShoCard client...")

    puts("Getting a new ShoCardId from an Adaptor...")
    register_response = HTTPClient.new.post(Rails.configuration.adaptorurl,
                                            "",
                                            {"Content-Type" => "application/json"})
    register = JSON.parse(register_response.content)
    puts("Your ShoCardId is: #{register["shocardid"]}")
    shocard_id = register["shocardid"]

    update_response = HTTPClient.new.put("#{Rails.configuration.adaptorurl}/#{shocard_id}",
                                         {callback: Rails.configuration.shocardcallback, name: Rails.configuration.shocardname}.to_json,
                                         {"Content-Type" => "application/json"})
    JSON.parse(update_response.content)

    puts("Initializing ShoCard client...OK")
    puts("Please add your shocardid: 'heroku config:add SHOCARD_ID=#{shocard_id}'")

  end

end
