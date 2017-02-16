#!/usr/bin/env ruby

require 'rubygems'
require 'mini_magick'
require 'chunky_png'
require 'rainbow'
require 'open-uri'

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

        height = width * (image.height.to_f / image.width) / 2.4
        image = image.resize("#{width}x#{height}!")
        image.format 'png'
        image.write file.path

        chunky = ChunkyPNG::Image.from_file file.path

        (0..chunky.height-1).each do |row|
          row_pixels = chunky.row row
          row_pixels.each do |pixel|
            r,g,b = ChunkyPNG::Color.to_truecolor_bytes pixel
            print Rainbow(" ").background(r, g, b)
          end
          print "\n"
        end
    end
end
