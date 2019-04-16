#!/usr/bin/env ruby

require 'wolfram-alpha'

require 'pry'

options = { "format" => "plaintext" } # see the reference appendix in the documentation.[1]

client = WolframAlpha::Client.new `apis wa`, options

ARGV.each do|a|
  response = client.query "#{a}"
  # response = client.query "distance to moon"

  input = response["Input"] # Get the input interpretation pod.
  result = response.find { |pod| pod.title == "Result" } # Get the result pod.

  binding.pry
  puts response.methods - Object.methods

  puts "#{input.subpods[0].plaintext} = #{result.subpods[0].plaintext}"
end