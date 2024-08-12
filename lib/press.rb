module UMPTG
  class Press
    # Press symbols and folder names
    @@PRESS_DIR = {
            aberdeenunipress: "MPS",
            amherst: "MPS",
            bar:   "MPS",
            csas:   "CSAS",
            cseas: "CSEAS",
            cjs:   "CJS",
            ebc:   "UMP",
            heb:   "MPS",
            lrccs: "LRCCS",
            leverpress: "MPS",
            michigan: "UMP",
            ummaa: "UMMAA",
            vermont: "MPS"
            }
    @@PRESS_SUB_DIR = {
            aberdeenunipress: "Aberdeen",
            amherst: "Amherst",
            bar:   "BAR",
            heb:   "HEB",
            leverpress: "Lever",
            vermont: "UVM"
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

    def self.press_subdir(press)
      return @@PRESS_SUB_DIR[press.to_sym]
    end
  end
end
