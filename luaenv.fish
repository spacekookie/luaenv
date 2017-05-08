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

set APPNAME "luaenv"
set APPVERSION "0.1"

set LUA_VERSION 5.3   # Default lua version is the latest
set LUAI_PATH ""      # Set an empty interpreter path (for now)

set COMMAND ""        # The user command for later lookup
set ENV_NAME ""       # The env (pile) we want to work on


set EXIT_OK             0
set EXIT_WRONG_ARGS     255


function options
  echo $argv | sed 's|--*|\\'\n'|g' | grep -v '^$'
end

function strip
  echo (string trim -- $argv)
end

function usage
printf """Usage: $APPNAME <command> <env> [options] 

  Valid commands:
    luaenv create <env> [options]   Create new luaenvs with options
    luaenv destroy <env>            Destroy existing luaenvs
    luaenv use <env>                Use an existing luaenv
    lua workon <env>                Like use but change directory

  Valid options:
    -l <path>                       Create a local env at the specified path
    -v <version>                    Specify a lua version to use
    -i <path>                       Specify a lua interpreter (clashes with -v)

  Please report bugs at https://github.com/spacekookie/luaenv
"""
end

# Set some flags based on arguments we got
for i in (options $argv)
  echo $i | read -l option value

  # Switch over the options we got back
  switch $option

    # Create a new env
    case create
      set COMMAND (strip $option)
      set ENV_NAME (strip $value) # This might be null but we don't care

    # Start using an env
    case use      
      set COMMAND (strip $option)
      set ENV_NAME (strip $value)

    # Use an env and jump to it's working dir
    case workon
      set COMMAND (strip $option)
      set ENV_NAME (strip $value)

    # Cleanly destroy an env
    case destroy
      set COMMAND (strip $option)
      set ENV_NAME (strip $value)

    # Define a local env path
    case l
      set ENV_NAME (strip $value)

    # Set the lua version differently
    case v
      set LUA_VERSION (strip $value)

    # Set the lua interpreter manually
    case i
      set LUAI_PATH (strip $value)
  end
end

##################### CHECK USER INPUTS #####################


# echo "Command '$COMMAND'"
# echo "Env name '$ENV_NAME'"
# echo "Lua version '$LUA_VERSION'"
# echo "Lua I path '$LUAI_PATH'"


# What lua interpreter does she want? 
if [ $LUAI_PATH = "" ]
  set $LUAI_PATH which "lua$LUA_VERSION" ^ /dev/null

# Otherwise we might have been given one!
else

  # We really don't care :)
  if [ $LUA_VERSION != "5.3" ]
    echo "Ignoring provided lua version!"
  end

  which $LUAI_PATH ^ /dev/null > /dev/null
  if not test $status -eq 0
    echo "Invalid lua interpreter: $LUAI_PATH"
    exit $EXIT_OK
  end
end

if [ $ENV_NAME = "" ]
  usage
  exit $EXIT_OK
end


# Switch over the commands and call apropriate functions
switch $COMMAND;
  case wildcard;
    # commands;
end


## Everything is awesome...
exit $EXIT_OK
