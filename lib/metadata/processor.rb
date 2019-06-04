class Processor
  def start_element(name, attrs = [])
    #puts "<#{name}: #{attrs.map {|x| x.inspect}.join(', ')}>"
  end

  def end_element(name)
    #puts "</#{name}>"
  end

  def characters(string)
    #return if string =~ /^\w*$/     # whitespace only
  end
end
