#! /usr/bin/env ruby

require_relative './ofx_parser'
require_relative './ofx_nodes'
require 'debug'

print "\n\nTesting version 2xx...\n"
parser_v2 = Ofx::Parser.new(260)
tree2 = parser_v2.parse(File.read('./cc_ofx2_resp.qfx'))
if tree2
  print "OK\n"
else
  print "FAIL\n"
end
