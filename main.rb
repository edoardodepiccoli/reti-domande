require 'openai'
require 'dotenv'

Dotenv.load

api_key = ENV['API_KEY']

client = OpenAI::Client.new(
  access_token: api_key,
  log_errors: true
)

csv_file = File.open('./flashcards.csv', 'a')

latex_file = File.new('./domande/tutto.tex')
content = latex_file.read
sections = content.split('\section')

total_sections = sections.size
completed_sections = 0

def percentage_completed(total, completed)
  (completed.to_f / total * 100).truncate(2)
end

sections.each do |section|
  next if section.length < 100

  system('clear')
  puts "writing to file #{percentage_completed(total_sections, completed_sections)}%"

  instructions = "Scrivi delle flashcards per aiutarmi a imparare ogni dettaglio su questo testo. Le flashcards devono essere chiare e non ambigue. Puoi creare quante flashcards credi sia necessario per farmi imparare ogni dettaglio di questo argomento, l'importante è che la copertura delle flashcards sia del 100% dell'argomento, in modo che chi le usa per studiare impari tutto. Scrivi le flashcards in formato csv separando il fronte e il retro con un carattere |. Scrivi solamente fronte e retro di ogni flashcards. Ecco il testo:"
  full_prompt = "#{instructions} + \n + #{section}"

  response = client.chat(
    parameters: {
      model: 'gpt-4o',
      messages: [{ role: 'user', content: full_prompt }],
      temperature: 0.5
    }
  )
  csv_rows = response.dig('choices', 0, 'message', 'content')

  csv_file.puts(csv_rows)
  completed_sections += 1
end

csv_file_count = File.new('./flashcards.csv')
new_lines = csv_file_count.read.count("\n")
puts "created flashcards for #{completed_sections} topics for a total of #{new_lines} flashcards"
