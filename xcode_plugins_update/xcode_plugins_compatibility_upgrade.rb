# Script used to upgrade installed plugins compatibily for current xcode version
require 'bundler/setup'

require 'CFPropertyList'
require 'set'
require 'pathname'

def current_xcode_version
  xcode_plist_path = "/Applications/Xcode.app/Contents/Info.plist"

  if !File.exist?(xcode_plist_path)
    puts "Error : Xcode info.plist file not found"
    return nil
  end

  xcode_plugins_plist = CFPropertyList::List.new(:file => xcode_plist_path)
  if xcode_plugins_plist == nil
    puts "Error : cannot load info.plist file"
    return nil
  end

  # Load data
  data = CFPropertyList.native_types(xcode_plugins_plist.value)
  xcode_plugins_uid = data["DVTPlugInCompatibilityUUID"]
  if xcode_plugins_uid == nil
    puts "Error : DVTPlugInCompatibilityUUID key not found in info.plist file"
    return nil
  end

  return xcode_plugins_uid
end


def upgrade_plugin_compatibility(plugin_path, plugin_uuid)
  # Load plug-in plist
  info_plist_path = plugin_path + "/Contents/Info.plist"
  if !File.exists? info_plist_path
    puts "Error : Cannot find #{info_plist_path} file"
    return
  end

  xcode_plugin_plist = CFPropertyList::List.new(:file => info_plist_path)
  if xcode_plugin_plist == nil
    puts "Error : cannot load #{info_plist_path} file"
    return
  end

  # Load data
  data = CFPropertyList.native_types(xcode_plugin_plist.value)
  xcode_plugins_uids = data["DVTPlugInCompatibilityUUIDs"]
  if xcode_plugins_uids == nil
    puts "Error : DVTPlugInCompatibilityUUID key not found in info.plist file"
    return
  end

  plugin_name = Pathname.new(plugin_path).basename
  if xcode_plugins_uids.include? plugin_uuid
    puts "Plug in #{plugin_name} already up to date"
    return
  end

  # Add new uuid
  puts "Plug in #{plugin_name} needs update"
  xcode_plugins_uids << plugin_uuid

  # Update data
  data["DVTPlugInCompatibilityUUIDs"] = xcode_plugins_uids
  xcode_plugin_plist.value = CFPropertyList.guess(data)
  
  # Save new plist
  xcode_plugin_plist.save(info_plist_path, CFPropertyList::List::FORMAT_BINARY)
end

if (__FILE__) == $0
  xcode_plugin_version = current_xcode_version
  if (xcode_plugin_version == nil)
    return
  end

  puts "Current xcode plugin version #{xcode_plugin_version}"

  # Update plugins
  Dir[Dir.home + "/Library/Application Support/Developer/Shared/Xcode/Plug-ins/*"].each {|file|
    upgrade_plugin_compatibility(file, xcode_plugin_version)
  }
end



