module UMPTG::EPUB
  class Processor
    def self.process(args = {})
      case
      when args.key?(:epub_file)
        epub_file = File.expand_path(args[:epub_file])
        raise "Error: invalid EPUB file." unless File.exists?(epub_file)
        epub = UMPTG::EPUB::Archive.new(:epub_file => epub_file) if epub.nil?
      when args.key?(:epub)
        epub = args[:epub]
        raise "Error: invalid EPUB." if epub.nil?
      else
        raise "Error: no :epub_file or :epub parameter specified."
      end

      raise "Error: missing :entry_processors parameter." unless args.key?(:entry_processors)
      entry_processors = args[:entry_processors]
      raise "Error: no entry_processors specified." if entry_processors.nil? or entry_processors.empty?


      epub_actions = {}
      epub.spine.each do |entry|
        epub_actions[entry.name] = []
        entry_processors.each do |key,proc|
          entry_proc_actions = proc.action_list(
                      name: entry.name,
                      content: entry.get_input_stream.read
                      )
          epub_actions[entry.name] += entry_proc_actions
        end
      end
      return epub_actions
    end
  end
end
