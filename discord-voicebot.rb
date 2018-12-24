require 'discordrb'
require 'aws-sdk'

TOKEN        = ENV['DISCORD_BOT_TOKEN']
VOICE_ID     = ENV['POLLY_VOICE_ID']
TTS_CHANNELS = ENV['TTS_CHANNELS'].split(',')
SampleRate   = "16000"
MP3_DIR      = "/data/tts/mp3"
NAME_DIR     = "/data/tts/name"

bot = Discordrb::Commands::CommandBot.new token: TOKEN, prefix: '!'

bot.command(:connect, description:'読み上げbotを接続中の音声チャンネルに参加させます',usage:'!connect') do |event|
  channel = event.user.voice_channel

  unless channel
    event << "```"
    event << "ボイスチャンネルに接続されていません"
    event << "```"
    next
  end

  # ボイスチャンネルにbotを接続
  bot.voice_connect(channel)
  event << "```"
  event << "ボイスチャンネル「 #{channel.name}」に接続しました。利用後は「!destroy」でボットを切断してください"
  event << "```"

end

bot.command(:destroy, description:'音声チャンネルに参加している読み上げbotを切断します', usage:'!destroy') do |event|
  channel = event.user.voice_channel
  server = event.server.resolve_id

  unless channel
    event << "```"
    event << "ボイスチャンネルに接続されていません"
    event << "```"
    next
  end

  bot.voice_destroy(server)
  event << "```"
  event << "ボイスチャンネル「 #{channel.name}」から切断されました"
  event << "```"

end

bot.message(in: TTS_CHANNELS) do |event|

  channel   = event.channel
  server    = event.server
  voice_bot = event.voice

  if voice_bot != nil
    if /^[^!]/ =~ event.message.to_s

      # `chname` で指定された名前があれば設定
      if File.exist?("#{NAME_DIR}/#{server.resolve_id}_#{event.user.resolve_id}")
        speaker_name = "#{File.read("#{NAME_DIR}/#{server.resolve_id}_#{event.user.resolve_id}")}"
      else
        speaker_name = "#{event.user.name}"
      end

      # pollyで作成した音声ファイルを再生
      polly = Aws::Polly::Client.new
      polly.synthesize_speech({
                                  response_target: "#{MP3_DIR}/#{server.resolve_id}_#{channel.resolve_id}_speech.mp3",
                                  output_format: "mp3",
                                  sample_rate: SampleRate,
                                  text: "<speak>#{speaker_name}いわく、>#{event.message}</speak>",
                                  text_type: "ssml",
                                  voice_id: VOICE_ID,
                              })
      voice_bot.play_file("#{MP3_DIR}/#{server.resolve_id}_#{channel.resolve_id}_speech.mp3")
    end
  end
end

bot.command(:chname, min_args: 1, max_args: 1, description:'botに読み上げられる自分の名前を設定します', usage:'!chname ギャザラ') do |event, name|

  File.open("#{NAME_DIR}/#{event.server.resolve_id}_#{event.user.resolve_id}", "w") do |f|
    f.puts("#{name}")
  end

  event << "```"
  event << "呼び方を#{name}に変更しました。"
  event << "```"

end

bot.run