#!/usr/bin/env ruby

# file: arpscanner.rb

require 'resolv' # resolv is a built-in Ruby library
require 'dynarex'
require 'mactovendor'


class ArpScanner
  using ColouredText

  # options:
  # nic: e.g.  eth0, enp2s0f0
  #
  def initialize(nic: `ip addr`[/(?<=global )\w+/], vendors: {}, 
                 nameserver: nil)
    
    package = 'arp-scan'
    @vendors, @nameserver = vendors, nameserver
    
    found = `dpkg --get-selections | grep #{package}`
    
    if found.empty? then
      raise 'ArpScanner: arp-scan package not found'.error
    end
    
    @arpscan_cmd = "sudo #{package} --interface=#{nic} --localnet"
    
  end
  
  def scan()
    
    a = `#{@arpscan_cmd}`.lines
    
    a2 = a[2..-4].map do |x|

      r = %i(ip mfr mac).zip(x.chomp.split("\t").values_at(0,2,1))      
      
      if @nameserver then
                
        begin
          hostname = Resolv::DNS.new(:nameserver => [@nameserver]).getname(r[0][1]).to_s
        rescue
          hostname = ''
          puts ($!).to_s.warning
        end
        
        r.insert(1, [:hostname, hostname])
        
      else
        %i(ip mfr mac).zip(x.chomp.split("\t")).to_h
      end
      
      h = r.to_h
      
      if h[:mfr] == '(Unknown)' then
        vendor = MacToVendor.find h[:mac] 
        h[:mfr] = vendor if vendor
      end
      
      h 
      
    end
    
    # Add additional vendors
    h = {/^b8:27:eb:/ => 'Raspberry Pi Foundation'}.merge(@vendors)
    
    a2.map! do |x|
      
      _, vendor = h.detect {|mac, mfr| x[:mac] =~ mac }
      x[:mfr] = vendor if vendor
      x

    end    
        
    # sort by IP address
    Dynarex.new.import a2.sort_by {|x| x[:ip][/\d+$/].to_i}

  end

  
end
