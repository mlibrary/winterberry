module UMPTG
  class Press
    # Press symbols and folder names
    @@PRESS_DIR = {
            amherst: "MPS",
            bar:   "MPS",
            ebc:   "UMP",
            heb:   "MPS",
            ummaa: "UMMAA"
            }
    @@PRESS_SUB_DIR = {
            amherst: "Amherst",
            bar:   "BAR",
            heb:   "HEB",
            }
    @@DEFAULT = :ebc

    def self.valid(press)
      return @@PRESS_DIR.key?(press.to_sym)
    end

    def self.press_list()
      list = @@PRESS_DIR.keys.map {|k| k.to_s}
      return list.join('|')
    end

    def self.default()
      return @@DEFAULT
    end

    def self.press_dir(press)
      return @@PRESS_DIR[press.to_sym]
    end

    def self.press_sub_dir(press)
      return @@PRESS_SUB_DIR[press.to_sym]
    end
  end
end