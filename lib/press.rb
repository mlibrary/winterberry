module UMPTG
  class Press
    # Press symbols and folder names
    @@PRESS_DIR = {
            a2ru: "a2ru",
            aberdeenunipress: "aberdeenunipress",
            amherst: "amherst",
            atg: "ATG",
            belin: "belin",
            bridwell: "bridwell",
            bar:   "barpublishing",
            boydellandbrewer: "boydellandbrewer",
            cjs:   "CJS",
            csas:   "CSAS",
            cseas: "CSEAS",
            dialogue: "dialogue",
            ebc:   "UMP",
            ee:    "ee",
            fia:    "fia",
            heb:   "HEB",
            icmc:  "icmc",
            leverpress: "leverpress",
            livedplaces: "livedplaces",
            lrccs: "LRCCS",
            maizebooks: "maizebooks",
            ummaa: "UMMAA",
            michigan: "UMP",
            seas: "seas",
            umpccn:  "um-pccn",
            vermont: "vermont",
            westminster: "westminster"
            }
=begin
    @@PRESS_SUB_DIR = {
            aberdeenunipress: "Aberdeen",
            amherst: "Amherst",
            bar:   "BAR",
            heb:   "HEB",
            leverpress: "Lever",
            vermont: "UVM",
            westminster: "Westminster"
            }
=end
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
      raise "deprecated"
      return @@PRESS_SUB_DIR[press.to_sym]
    end
  end
end
