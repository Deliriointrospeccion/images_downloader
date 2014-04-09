#!/usr/bin/env ruby
require 'tco'
require 'open-uri'


class GrabImages
  def initialize(uri)
    @uri = uri
    @folder = "images"
  end

  def folder_images(folder = nil)
    uri = (folder ? @uri + folder : @uri)
    begin
      open(uri) do |f|
        f.each_line do |t|
          if match = ( t.match(/<a\s*\w*=\"([\w\d_]*\.\w{3,4})\"/) )
            save_image(match[1], folder)
          end

          if match = ( t.match(/href=\"([a-z^\._\-0-9]+\/)/))
            folder = match[1].gsub("/", "")
            puts 'Changing folders to ' + folder.fg('#71b9f8')
            Dir.mkdir("#{@folder}/#{folder}") unless Dir.exists?(folder)
            folder_images(folder) unless folder == ""
          end

        end
      end
    rescue Timeout::Error => e
      error_msg(e.to_s)
      puts "Waiting to retry in 10 seconds..."
      sleep(10)
    rescue Exception => e
      error_msg(e.to_s)
      puts e.backtrace
    end
  end

  def save_image(img, folder=nil)
    folder = (folder ? "#{@folder}/#{folder}" : @folder)
    open(folder ? "#{folder}/#{img}" : img, 'wb') do |file|
      file << open("#{@uri}/#{img}").read()
    end
    puts ('File saved: '.fg("#00ff00") + "#{img} in /#{folder.fg('#71b9f8')}")
  end

  def error_msg(msg)
    puts msg.bg("#FF0000").fg("#000000")
  end

  def success_msg(msg)
    puts msg.fg("#00FF00")
  end
end


if ARGV.length > 0
  GrabImages.new(ARGV[0]).folder_images
end

