#!/usr/bin/env ruby

# file: arpscanner.rb


class ArpScanner
  
  def initialize()
    
    package = 'arp-scan'
    
    found = `dpkg --get-selections | grep #{package}`
    
    if found.empty? then
      raise 'ArpScanner: arp-scanner package not found'
    end
    
    @arpscan_cmd = "sudo #{package} --interface=eth0 --localnet"
    
  end
  
  def scan()
    
    a = `#{@arpscan_cmd}`.lines
    a.shift 2
    a2 = a.map {|x| %i(ip mac mfr).zip(x.chomp.split("\t")).to_h}
    
    # Add additional vendors
    h = {/^b8:27:eb:/ => 'Raspberry Pi Foundation'}
    
    a2.map do |x|
      
      _, vendor = h.detect {|mac, mfr| x[:mac] =~ mac }
      x[:mfr] = vendor if vendor
      x

    end

  end
  
end
