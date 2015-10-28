# Script used to convert a plist file to json
require 'bundler/setup'

require 'CFPropertyList'
require 'set'
require 'pathname'
require 'JSON'

if (__FILE__) == $0
    if ARGV.count == 0 || ARGV.count > 2
        puts "Usage : #{$0} input_plist_file (output_json_file)"
        exit
    end

    # Compute input file
    file_path = Pathname.new(File.expand_path(ARGV[0]))
    if !file_path.exist?
        puts "Error : \"#{file_path}\" not found"
        exit
    end

    # Compute output file
    if (ARGV.count == 1)
        dest_path = Pathname.new(file_path.to_s.sub(".plist", "").concat(".json"))
    else
        dest_path = Pathname.new(ARGV[1])
    end

    # Try to load file content
    input_file_content_plist = CFPropertyList::List.new(:file => file_path)
    if input_file_content_plist == nil
        puts "Error : cannot load \"#{file_path}\""
        exit
    end

    # Load plist content
    data = CFPropertyList.native_types(input_file_content_plist.value)

    # Convert to json
    if (dest_path.exist?())
        dest_path.delete()
    end

    # Open output file
    dest_path.open('w')

    # Write JSON
    dest_path.write(JSON.generate(data));
end