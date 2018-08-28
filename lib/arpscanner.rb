#!/usr/bin/env ruby

# file: arpscanner.rb

require 'dynarex'

class ArpScanner

  # options:
  # nic: e.g.  eth0, enp2s0f0
  #
  def initialize(nic: 'eth0', vendors: {})
    
    package = 'arp-scan'
    @vendors = vendors
    
    found = `dpkg --get-selections | grep #{package}`
    
    if found.empty? then
      raise 'ArpScanner: arp-scanner package not found'
    end
    
    @arpscan_cmd = "sudo #{package} --interface=#{nic} --localnet"
    
  end
  
  def scan()
    
    a = `#{@arpscan_cmd}`.lines

    a2 = a[2..-3].map {|x| %i(ip mac mfr).zip(x.chomp.split("\t")).to_h}
    
    # Add additional vendors
    h = {/^b8:27:eb:/ => 'Raspberry Pi Foundation'}.merge(@vendors)
    
    a2.map! do |x|
      
      _, vendor = h.detect {|mac, mfr| x[:mac] =~ mac }
      x[:mfr] = vendor if vendor
      x

    end
    
    @dx = Dynarex.new
    @dx.import a2    

  end

  
end
