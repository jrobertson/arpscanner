Gem::Specification.new do |s|
  s.name = 'arpscanner'
  s.version = '0.4.1'
  s.summary = 'A wrapper for the package arp-scan. It can detect if a ' + 
      'found MAC address belongs to a Raspberry Pi.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/arpscanner.rb']
  s.add_runtime_dependency('dynarex', '~> 1.8', '>=1.8.27')
  s.add_runtime_dependency('mactovendor', '~> 0.1', '>=0.1.0')
  s.signing_key = '../privatekeys/arpscanner.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/arpscanner'
end
