#!/usr/bin/env ruby

require 'rubygems'
require 'mini_magick'
require 'chunky_png'
require 'rainbow'
require 'open-uri'
require 'pry'

# == Summary
#
# This handy Ruby gem will help you to create awesome ASCII art from images
# for your awesome command-line projects.
#
# == Example
#
#   ascii = ASCII_Image.new("file.jpg")
#   ascii.build(80)
#
# == Contact
#
# Author:: Nathan Campos (nathanpc@dreamintech.net)
# Website:: http://about.me/nathanpc

class Array
  def in_groups_of(number, fill_with = nil)
    if number.to_i <= 0
      raise ArgumentError,
        "Group size must be a positive integer, was #{number.inspect}"
    end

    if fill_with == false
      collection = self
    else
      # size % number gives how many extra we have;
      # subtracting from number gives how many to add;
      # modulo number ensures we don't add group of just fill.
      padding = (number - size % number) % number
      collection = dup.concat(Array.new(padding, fill_with))
    end

    if block_given?
      collection.each_slice(number) { |slice| yield(slice) }
    else
      collection.each_slice(number).to_a
    end
  end
end

class ASCII_Image
    # Initialize the ASCII_Image class.
    #
    # An Error is raised if your ImageMagick quantum depth is higher than 8.
    #
    # Arguments:
    #   uri: (String)
    #   console_width: (Integer)

    def initialize(uri, console_width = 80)
        @uri = uri
        @console_width = console_width

        #if Magick::QuantumDepth > 8
            #raise "Your ImageMagick quantum depth is set to #{Magick::QuantumDepth}. You need to have it set to 8 in order for this app to work."
        #end
    end

    # Convert the image into ASCII and print it to the console.
    #
    # An ArgumentError is raised if the +width+ is bigger than the +console_width+
    #
    # Arguments:
    #   width: (Integer)

    def build(width)
        # Open the resource
        image = MiniMagick::Image.open(@uri)

        # Resize to the desired "text-pixel" size
        if width > @console_width
            raise ArgumentError, "The desired width is bigger than the console width"
        end

        file = Tempfile.new 'foo.png'

        height = width * (image.height.to_f / image.width) / 2.4 * 2
        image = image.resize("#{width}x#{height}!")
        image.format 'png'
        image.write file.path

        chunky = ChunkyPNG::Image.from_file file.path

        rows = chunky.pixels.each_slice(width)

        rows.to_a.in_groups_of(2) do |top_row_pixels, bot_row_pixels|
          top_row_pixels.each_with_index do |top_pixel, index|
            bot_pixel = bot_row_pixels[index]
            top_color = ChunkyPNG::Color.to_truecolor_bytes top_pixel
            bot_color = ChunkyPNG::Color.to_truecolor_bytes bot_pixel
            print Rainbow("\u2584").fg(bot_color).bg(top_color)
          end
          print "\n"
        end
    end
end
