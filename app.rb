# -*- coding: utf-8 -*-
# !/usr/bin/env ruby
require 'tco'
require 'open-uri'

class GrabImages
  def initialize(uri)
    @uri = uri
    @folder = 'images'
  end

  def folder_images(folder = nil)
    uri = (folder ? "#{@uri}#{folder}/" : @uri)
    begin
      open(uri) do |f|
        f.each_line do |t|
          # Check for image
          if match = t.match(/href=\"([\w\d_]*\.(jpg|jpeg|png|gif|bmp))\"/)
            save_image(match[1], folder)
          end

          # Probably have to change folder:
          if match = t.match(/href=\"([a-z^\._\-0-9]+)\/\">\ *[^(Parent)]/)
            change_folder(match[1].gsub('/', ''))
          end
        end
      end
    rescue Timeout::Error => e
      error_msg(e.to_s)
      puts 'Waiting to retry in 10 seconds...'
      sleep(10)
      folder_images
    rescue => e
      error_msg(e.to_s)
    end
  end

  def save_image(img, folder = nil)
    folder = (folder ? "#{@folder}/#{folder}" : @folder)
    open(folder ? "#{folder}/#{img}" : img, 'wb') do |file|
      file << open("#{@uri}/#{img}").read unless File.exists?("#{folder}/#{img}")
    end
    puts('File saved: '.fg('#00ff00') + "#{img} in /#{folder.fg('#71b9f8')}")
  end

  def change_folder(folder)
    puts 'Changing folders to ' + folder.fg('#71b9f8')
    Dir.mkdir("#{@folder}/#{folder}") unless Dir.exist?("#{@folder}/#{folder}")
    folder_images(folder) unless folder == ''
  end

  def error_msg(msg)
    puts msg.bg('#FF0000').fg('#000000')
  end
end

GrabImages.new(ARGV[0]).folder_images if ARGV.length > 0
