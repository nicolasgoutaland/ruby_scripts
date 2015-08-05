# Script used to convert a csv file to json
require 'bundler/setup'

require 'set'
require 'pathname'
require 'CSV'
require 'JSON'

if (__FILE__) == $0
    if ARGV.count == 0 || ARGV.count > 2
        puts "Usage : #{$0} input_csv_file (output_json_file)"
        exit
    end

    # Compute input file
    file_path = Pathname.new(File.expand_path(ARGV[0]))
    if !file_path.exist?
        puts "Error : \"#{file_path}\" not found"
        return
    end

    # Compute output file
    if (ARGV.count == 1)
        dest_path = Pathname.new(file_path.to_s.sub(".csv", "").concat(".json"))
    else
        dest_path = Pathname.new(ARGV[1])
    end

    # Try to load file content
    lines = CSV.read(file_path, :col_sep => ';')
    if lines.nil?
        puts "Error : cannot load \"#{file_path}\""
        return
    end

    # Convert to json
    if (dest_path.exist?())
        dest_path.delete()
    end

    # Extract columns
    columns = lines[0]
    lines.delete_at(0)

    # Open output file
    dest_path.open('w')

    # Write JSON
    result = []
    lines.each_index { |lineIndex|
        # Create dictionary
        dic = {}

        # Fill dctionary with columns
        columns.each_index { |columnIndex|
            dic[columns[columnIndex]] = lines[lineIndex][columnIndex]
        }

        # Add dictionary
        result[lineIndex] = dic
    }

    # Write to JSON
    dest_path.write(JSON.generate(result));
end


