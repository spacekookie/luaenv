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

set LUA_VERSION 5.3         # Default lua version is the latest
set LUAI_PATH ""            # Set an empty interpreter path (for now)

set COMMAND ""              # The user command for later lookup
set ENV_NAME ""             # The env (pile) we want to work on
set ENV_LOCATION "global"   # We prefer global envs. Big pile, big fun 
set LUA_SCOPE "system"      # We will also include system rocks

set EXIT_OK                 0
set EXIT_WRONG_ARGS         255


function options
  echo $argv | sed 's|--*|\\'\n'|g' | grep -v '^$'
end

function strip
  echo (string trim -- $argv)
end

function usage
printf "Usage: $APPNAME <command> <env> [options] 

  Valid commands:
    luaenv create <env> [options]   Create new luaenvs with options
    luaenv destroy <env>            Destroy existing luaenvs
    luaenv use <env>                Use an existing luaenv
    luaenv workon <env>             Like use but change directory

  Valid options:
    -l <path>                       Create a local env at the specified path
    -v <version>                    Specify a lua version to use
    -i <path>                       Specify a lua interpreter (clashes with -v)

  Please report bugs at https://github.com/spacekookie/luaenv
"
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
      set ENV_LOCATION "local"

    # Set the lua version differently
    case v
      set LUA_VERSION (strip $value)

    # Set the lua interpreter manually
    case i
      set LUAI_PATH (strip $value)

    case L
      set LUA_SCOPE "local"
  end
end

##################### CHECK USER INPUTS #####################


# What lua interpreter does she want? 
if [ $LUAI_PATH = "" ]
  set $LUAI_PATH which "lua$LUA_VERSION" ^ /dev/null

# Otherwise we might have been given one!
else

  # We really don't care :)
  if [ $LUA_VERSION != "5.3" ]
    echo "Ignoring provided lua version!"
  end

  # Make sure the interpreter actually exists
  which $LUAI_PATH ^ /dev/null > /dev/null
  if not test $status -eq 0
    echo "Invalid lua interpreter: $LUAI_PATH"
    exit $EXIT_WRONG_ARGS
  end
end

# Fail if we weren't given an env-name
if [ $ENV_NAME = "" ]
  usage

  # TODO: Change this to EXIT_WRONG_ARGS
  exit $EXIT_OK 
end

# Expand $ENV_NAME to ENV_PATH
if test $ENV_LOCATION = "global" 
  set ENV_PATH (readlink -f ~/.local/luaenv)/$ENV_NAME
else if test $ENV_LOCATION = "local"
  set ENV_PATH (readlink -f $ENV_NAME)
else
  echo "Some error has occured!"
  exit $EXIT_WRONG_ARGS
end


# Check if the env already exists


# Switch over the commands and call apropriate functions
switch $COMMAND;
  
  # Creating an env is:
  #   - Where?
  #   - With what?
  #   - Copy existing lua-packages
  case create
    mkdir -p $ENV_PATH
    mkdir -p $ENV_PATH/bin
    mkdir -p $ENV_PATH/lua

    # Copy the correct lua versions
    cp -v /usr/bin/lua$LUA_VERSION $ENV_PATH/bin/lua
    cp -v /usr/bin/luarocks-$LUA_VERSION $ENV_PATH/bin/luarocks_backend
    echo "\
#!/usr/bin/fish
$ENV_PATH/bin/luarocks_backend --tree $ENV_PATH/lua/ \$argv
" > $ENV_PATH/bin/luarocks
    chmod +x $ENV_PATH/bin/luarocks

    # Metadata info for later uses
    echo $LUA_VERSION > $ENV_PATH/VERSION
    echo $ENV_NAME > $ENV_PATH/NAME
    echo $LUA_SCOPE > $ENV_PATH/SCOPE

  # Activating an env is:
  #   - Check env is valid (check metadata)
  #   - Change $PATH to include $ENV_PATH in the front
  #   - Change luarocks --tree $ENV_PATH --
  #   - Set luapath to only use the pile + system
  case use

    # Check if $ENV_NAME exists under ~/.local/luaenv/
    if test -d (readlink -f ~/.local/luaenv)/$ENV_NAME
      set ENV_PATH (readlink -f ~/.local/luaenv)/$ENV_NAME
    end

    # Check if $ENV_NAME is a path - it takes precedence
    if test -d $ENV_NAME
      set ENV_PATH (readlink -f $ENV_NAME)
    end

    # Restore previous state
    set LUA_VERSION (cat $ENV_PATH/VERSION)
    set ENV_NAME (cat $ENV_PATH/NAME)
    set LUA_SCOPE (cat $ENV_PATH/SCOPE)

    # Change $PATH
    set LUAENV_BACKUP_PATH $PATH
    set PATH $ENV_PATH/bin $PATH 

    echo "You are now using $ENV_NAME@lua$LUA_VERSION"

    # Either make a big lua path
    if test LUA_SCOPE = "system"

      set LUA_PATH

    # or a really small one
    else

    end

end

## Everything is awesome...
exit $EXIT_OK
