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

  instructions = "Per questa sezione di un documento latex di un libro di reti di calcolatori, scrivi 4 flashcards formattandole così in formato csv e separando il fronte dal retro usando un |. Crea 4 flashcards: una per la descrizione (se presente), una per i pregi (se presenti), una per i difetti (se presenti) e una per gli ambiti di utilizzo (se presenti). Formatta il fronte delle flashcards così: Nome argomento - descrizione, Nome argomento - pregi, ecc ecc. Scrivi solo le righe una dopo l'altra come se stessi scrivendo su un foglio csv e non riassumere, semplicemente copia e incolla. Se incontri testo formattato in modo particolare convertilo in plain text"
  full_prompt = "#{instructions} + \n + #{section}"

  response = client.chat(
    parameters: {
      model: 'gpt-4o',
      messages: [{ role: 'user', content: full_prompt }],
      temperature: 0.7
    }
  )
  csv_rows = response.dig('choices', 0, 'message', 'content')

  csv_file.puts(csv_rows)
  completed_sections += 1
end

csv_file_count = File.new('./flashcards.csv')
new_lines = csv_file_count.read.count("\n")
puts "created flashcards for #{completed_sections} topics for a total of #{new_lines} flashcards"
