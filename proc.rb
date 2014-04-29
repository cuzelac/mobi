#!/bin/env ruby

require 'nokogiri'
require 'pry'

doc = Nokogiri::HTML(File.read("The_Adventure_of_the_Speckled_Band.html"))

nbsp = Nokogiri::HTML('&nbsp;').text
space_regexp = Regexp.new("[\s#{nbsp}]")

# remove leading/trailing space from paragraphs
doc.search('p').each do |p|
  new_content = p.content

  new_content.sub!(/^#{space_regexp}*/,'')
  new_content.sub!(/#{space_regexp}*$/,'')

  p.content = new_content
end

binding.pry
