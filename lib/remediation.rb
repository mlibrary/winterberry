module UMPTG
  require_relative 'action'
  require_relative 'epub'

  require_relative File.join('remediation', 'fixhrefaction')
  require_relative File.join('remediation', 'fixidaction')
  require_relative File.join('remediation', 'fiximagewidthaction')
  require_relative File.join('remediation', 'fixtitleaction')
  require_relative File.join('remediation', 'removemarginbottomaction')
  require_relative File.join('remediation', 'removemargintopaction')
  require_relative File.join('remediation', 'removetextalignaction')

  require_relative File.join('remediation', 'defaultprocessor')
end
