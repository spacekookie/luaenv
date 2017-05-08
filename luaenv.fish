#!/usr/bin/env fish

###############################################################################
#
# This is the core utility for luaenv. It takes care of creating 
#   new environments (piles) or switching to existing ones.
#
# It also stores default path configs so that when calling `luaenv stop`
#   it has the ability to restore the system defaults for you.
#
# 
# Quick rundown of the script
#
#   - Parses commandline arguments and makes sure they're valid
#   - Checks if a luaenv is currently active
#      - If not it stores the current path variables
#   - Execute commands parsed earlier:
#
#   - create: copy a bunch of files into a directory
#   - use: set a bunch of path variables to point to all the right tools
#   - destroy: rm -rf / --no-preserve-root
#
###############################################################################


# Parse options that we're given
function options
  echo $argv | sed 's|--*|\\'\n'|g' | grep -v '^$'
end

set LUA_VERSION 5.3   # Default lua version is the latest
set LUAI_PATH ""      # Set an empty interpreter path (for now)

set COMMAND ""        # The user command for later lookup
set ENV_NAME ""       # The env (pile) we want to work on

for i in (options $argv)
  echo $i | read -l option value

  # Switch over the options we got back
  switch $option

    # Create a new env
    case create
      set COMMAND $option
      set ENV_NAME $value # This might be null but we don't care

    # Start using an env
    case use      
      set COMMAND $option
      set ENV_NAME $value

    # Use an env and jump to it's working dir
    case workon
      set COMMAND $option
      set ENV_NAME $value

    # Cleanly destroy an env
    case destroy
      set COMMAND $option
      set ENV_NAME $value

    # Define a local env path
    case l
      set ENV_NAME $value

    # Set the lua version differently
    case v
      set LUA_VERSION $value

    # Set the lua interpreter manually
    case i
      set LUAI_PATH $value
  end
end


##################### CHECK USER INPUTS #####################

echo "Command '$COMMAND'"
echo "Env name '$ENV_NAME'"
echo "Lua version '$LUA_VERSION'"
echo "Lua I path '$LUAI_PATH'"

# What lua interpreter does she want? 
if [ $LUAI_PATH = "" ]
  echo "Need to build the LUAI PATH"
  set $LUAI_PATH which "lua$LUA_VERSION" ^ /dev/null

else

  which $LUAI_PATH ^ /dev/null > /dev/null
  if not test $status -eq 0
    echo "Invalid lua interpreter: $LUAI_PATH"
    exit 0
  end

end

# echo "Lua interpreter: $LUAI_PATH"

# ### Check if the lua version is even installed
# which "lua$LUA_VERSION" ^ /dev/null
# if not test $status -eq 0
#   echo "Invalid lua version: $LUA_VERSION"
#   exit 255
# end

