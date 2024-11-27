require 'openai'

client = OpenAI::Client.new(
  access_token: 'access_token_goes_here',
  log_errors: true # Highly recommended in development, so you can see what errors OpenAI is returning. Not recommended in production because it could leak private data to your logs.
)

file = File.new('./domande/tutto.tex')
content = file.read

sections = content.split('\section')
