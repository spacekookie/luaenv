# LUAENV

Like RVM but for lua. Like [vert](https://github.com/aconbere/vert) but it sooo much cooler\*. You can either set your default lua version to something other than what your distribution has set or create local `piles` that only have specific dependencies installed for development.

In this article `luaenv` and `pile` are used interchangably. They mean the same thing. An environment for lua stuff.

### Basics

Packages (rocks) will be installed under `~/.local/share/lua/<version>/?.lua` by default.

You can create a "pile" (environment) that will install packages into `~/.local/share/luaenv/<pile_name>@<version>/?.lua`

By default the luaenv path will be set to the default + the main luaenv directory under `~/.local/share/lua/<version>`



luaenv currently only supports the [fish](https://fishshell.org) shell

### Tools available

- `luaenv` is the main luaenv cli tool. It creates, deletes, modifies and switches environments. See the wiki for more documentation.
 - `workon` utility script that switches to a luaenv and `cd` into it's project directory

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
