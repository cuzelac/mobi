#!/bin/env ruby

require 'nokogiri'
require 'pry'
require 'publishr'
require 'logger'

@logger = Logger.new(STDERR)
@logger.level = Logger::DEBUG

doc = Nokogiri::HTML(File.read("The_Adventure_of_the_Speckled_Band.html"))

nbsp = Nokogiri::HTML('&nbsp;').text
space_regexp = Regexp.new("[\s#{nbsp}]")

OUT = "/home/cuzelac/Development/test.html"

def write_html(doc,file=OUT)
  File.open(OUT,'w') do |f|
    f.print doc.to_html
  end
end

# remove leading/trailing space from paragraphs
doc.search('p').each do |p|
  new_content = p.content

  new_content.sub!(/^#{space_regexp}*/,'')
  new_content.sub!(/#{space_regexp}*$/,'')

    p.content = new_content
end

# remove all headings except the title

doc.search('h3').each do |h|
  next if h.content =~ /The adventure of the speckled/i
  h.remove
end

doc.search('hr').remove
doc.search('img').remove
doc.search('a').remove
doc.search('center').remove
doc.search('br').remove

# for some reason, there is a 'body' and an 'omit'
# concatenate them

#body = doc.search('body')
#doc.search('omit').each do |o|
  #@logger.debug "attaching to body: #{o.inspect}"
  #body.add_child o
#end
#binding.pry
#doc.search('omit').remove

FakeElement = Struct.new(:children)
FakeParagraph = Struct.new(:content)
def attach_text(doc,search)
  previous_element = FakeElement.new([FakeParagraph.new("")])
  doc.search(search).children.each do |i|
    @logger.debug "looping over child: #{i.inspect}"
    case i
    when Nokogiri::XML::Text
      @logger.debug "found some text; concatenating to #{previous_element.inspect}"
      new_text = previous_element.children.first.content
      new_text += " " + i.content
      previous_element.children.first.content = new_text
      i.remove
    when Nokogiri::XML::Element
      @logger.debug "found an element; stashing it"
      previous_element = i
    end
  end
end


attach_text(doc,'body')
attach_text(doc,'omit')

write_html(doc)

binding.pry
