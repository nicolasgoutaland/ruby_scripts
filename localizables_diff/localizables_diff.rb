# Script used to detect missing keys accross Localizable.strings files
# Argument : files to be compared
# Output : Date-Report.txt, on desktop

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'bundler/setup'

require 'plist'
require 'set'
require 'pathname'

def localizable_keys_from_file(file)
    # Load file content
    content = File.open(file).read()

    # Prepare regex
    regex = /\/\*(.|[\r\n])*?\*\//

    # Clear comments
    until (match = regex.match(content)).nil?
        content[match.begin(0)..match.end(0)] = ""
    end

    # Clear all lines
    result = Set.new
    content.lines.each {|line|

        # Strip line and process it
        strippedLine = line.strip
        if strippedLine.length > 0
            # Split string
            split = strippedLine.split("=")

            # Extract key
            key = split[0].strip.chop
            key = key[1..key.size-1]

            result.add(key)
        end
    }

    return result
end

if (__FILE__) == $0
    if ARGV.count < 2
        puts "Usage : #{$0} firstFile secondFile {other files}"
        exit
    end

    # Load all keys
    all_keys = Set.new
    keys_by_file = {}
    ARGV.each {|file|
      keys_by_file[file] = localizable_keys_from_file(file)
      all_keys.merge(keys_by_file[file])
    }

    # Generate errors
    errors = []

    keys_by_file.each {|file, file_keys|
      # Compute minus set
      minus_set = all_keys - file_keys

      # If not empty, list all missings keys
      if !minus_set.empty?
        # Store errors
        errors << file
        minus_set.each {|key|
          errors << "\t> " + key
        }
       end
    }

    # Check for errors
    if !errors.empty?
        File.write("#{Dir.home()}/Desktop/#{Time.now.strftime("%Y-%m-%d_%H.%M.%S")}-localizables-errors.txt", errors.join("\n"))
        exit -1
    else
      puts "No missing strings found"
    end
end
