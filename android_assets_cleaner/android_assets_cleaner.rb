# Script used to clean assets folder for android application, using ios assets
require 'bundler/setup'

require 'set'
require 'pathname'

DELETED_SUFFIXES = ["@3x", "~ipad", "@2x~ipad"]
RENAMED_SUFFIXES = ["@2x~iphone", "@2x"]

def clean_assets(path)
    puts "Entering folder \"#{path}\""
    
    # Update plugins
    path.each_child {|childPath|
        if childPath.directory?
            clean_assets childPath
        else
            #Delete unusfull files
            DELETED_SUFFIXES.each{|suffix|
                if (childPath.basename.to_s.include?(suffix))
                    puts "Deleting #{childPath}"
                    childPath.delete()
                    break;
                end;
            }
        
            # If file still exists, check for @2x
            if childPath.exist?
                RENAMED_SUFFIXES.each{|suffix|
                  if childPath.basename.to_s.include?(suffix)
                      cleanedPathname = Pathname.new(childPath.to_s.delete(suffix))
                      if cleanedPathname.exist?
                          cleanedPathname.delete()
                          childPath.rename(cleanedPathname)
                      end
                  end
                }
            end
        end
    }
end
if (__FILE__) == $0
    if ARGV.count != 1
        puts "Usage : #{$0} assets_folder_path"
        exit
    end

    folderDir = Pathname.new(File.expand_path(ARGV[0]))

    puts "Cleaning folder at path \"#{folderDir}\""

    clean_assets(folderDir)
end



