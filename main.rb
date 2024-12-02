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
  next if section.length < 50

  system('clear')
  puts "writing to file #{percentage_completed(total_sections, completed_sections)}%"

  instructions = "Aiutami a scrivere delle flashcards. Scrivile in formato csv usando un carattere pipeline | per separare il fronte dal retro. Nel fronte ci deve essere una domanda chiara e non ambigua e nel retro ci deve essere la risposta. La tua risposta deve essere composta da solo le flashcards richieste, non specificare il linguaggio usando ```. Non specificare il formato delle flashcards prima di scriverle, per esempio scrivendo 'Domanda|Risposta' e non scrivere nient'altro oltre alle flashcards richieste. Scrivi le flashcards in linee consecutive senza lasciare una linea vuota in mezzo. Per ogni argomento o tecnologia devo imparare molto bene che cos'è e in che contesto viene usata, quali sono i suoi ambiti di utilizzo principali, quai sono i suoi pregi e quali sono i suoi difetti:\n\n"
  full_prompt = "#{instructions} + \n + #{section}"

  response = client.chat(
    parameters: {
      model: 'gpt-4o-mini',
      messages: [{ role: 'user', content: full_prompt }],
      temperature: 1
    }
  )
  csv_rows = response.dig('choices', 0, 'message', 'content')

  csv_file.puts(csv_rows)
  completed_sections += 1
end

csv_file_count = File.new('./flashcards.csv')
new_lines = csv_file_count.read.count("\n")
puts "created flashcards for #{completed_sections} topics for a total of #{new_lines} flashcards"
