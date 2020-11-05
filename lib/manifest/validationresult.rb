module UMPTG::Manifest
  require 'nokogiri'
  
  require_relative File.join('validationresult', 'vnode.rb')
  require_relative File.join('validationresult', 'vrnode.rb')
  require_relative File.join('validationresult', 'vmnode.rb')
  require_relative File.join('validationresult', 'vnodefactory.rb')
  require_relative File.join('validationresult', 'vsaxdocument.rb')
  require_relative File.join('validationresult', 'vtree.rb')
  require_relative File.join('validationresult', 'vtreebuilder.rb')
end
