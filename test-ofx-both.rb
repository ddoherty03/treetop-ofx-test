#! /usr/bin/env ruby

require_relative './ofx_parser'
require_relative './ofx_nodes'
require 'rainbow/refinement'
using Rainbow
require 'debug'

print "Testing version 1xx..."
parser_v1 = Ofx::Parser.new(160)
tree1 = parser_v1.parse(File.read('./cc_ofx1_resp.sgml'))
if tree1
  print "OK".green
else
  print "FAIL".red
end

print "\n\nTesting version 2xx..."
parser_v2 = Ofx::Parser.new(260)
tree2 = parser_v2.parse(File.read('./cc_ofx2_resp.qfx'))
if tree2
  print "OK".green
else
  print "FAIL".red
end
print "\n"
