# LUAENV

Like RVM but for lua. Or [vert](https://github.com/aconbere/vert) but soooooooo much cooler\*. You can either set your default lua version to something other than what your distribution has set or create local `piles` that only have specific dependencies installed for development.

A lua `env` is also called a `pile`. Because...ya know. It's a `pile` of `rocks`. *rimshot*

### Basics

When you use `luarocks --local` packages get installed under `~/.luarocks`. With luaenv you can change that even if you don't want to use an env for a single project only. When setup correctly luaenv creates a new env for each lua version installed under `~/.local/share/luaenv/vanilla/<version>/` that you can switch to easily with `luaenv switch <version>`. Include that command in your `shellrc` if you like.

On the other hand you can create a new env to install packages into under `~/.local/share/luaenv/<pile_name>@<version>/` or locally in whatever directory you desire. If there is both a "local" and "global" env the local one will take precedence.

luaenv currently only supports the [fish](https://fishshell.org) shell

### Tools available

`luaenv` is the core cli tool which gives you access to a variety of functions. It's written entirely in fish which makes it immune to accidentally setting a bad lua path and requires you to have *no* dependencies besides the shell itself.

Functions available are

 - `create` creates new luaenvs with options
 - `destroy` destroys existing luaenvs
 - `lua` switches to the default env with the provided version
 - `use` uses an existing luaenv
 - `stop` stop using the current env. Is ignored if no env is currently in use
 - `workon` like `use` but changes into the registered work directory
 - `ls` lists all globally installed envs

Tools like lua, luajit, luarocks, etc are symlinked into the user path in a way that they shadow the system defaults.

### Usage

A quick rundown of how to use luaenv. We want to create a pile. You can specify a lua version as well as if you want it to be "global" or "local". Global piles will be installed under `~/.local/share/luaenv/`

```bash
$ luaenv create -i 5.1 -l env/
```
When adding `-l` you also need to add a directory that it will use to store the luaenv. Next up we want to activate the env. Because we created a local env, we need to pass the directory as a parameter

```bash
$ luaenv use env/
$ luaenv stop  # This way we could stop using the environment
```

Now when we call `lua -v` we will get:

```bash
Lua 5.1.5  Copyright (C) 1994-2012 Lua.org, PUC-Rio
```

**Hurray!**


### So what exactly is the difference to vert? O.ô

 - luaenv doesn't clutter your home directory with more `.folders`. It uses unix standards where things should be stored
 - It supports my favourite shell [fish](https://fishshell.org) a lot better
 - It's general design is much closer to RVM than vert which is more based on the principles of python virtualenvs

---

\* According to me, with no control group or external input. Margin of error is 100%. I don't even know how to do margin of error. Terms and conditions may and *will* apply.
