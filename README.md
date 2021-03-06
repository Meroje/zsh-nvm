# zsh-nvm [![Build Status](https://travis-ci.org/Meroje/zsh-nvm.svg?branch=master)](https://travis-ci.org/Meroje/zsh-nvm)

> Zsh plugin for loading `nvm`

[`nvm`](https://github.com/creationix/nvm) is an awesome tool but it can be kind of a pain to install and keep up to date. This zsh plugin allows you to quickly setup `nvm` once, save it in your dotfiles, then never worry about it again.

Although this is written as a zsh plugin, it also works with bash if you follow the [manual installation instructions](#manually).

## Usage

Once the plugin's installed `nvm` will be available. You'll probably want to load this as one of your first plugins so `node`/`npm` is available for any other plugins that may require them.

## Options

### Custom Directory

You can specify a custom directory to use with `nvm` by exporting the `NVM_DIR` environment variable. It must be set before `zsh-nvm` is loaded.

For example, if you are using antigen, you would put the following in your `.zshrc`:

```shell
export NVM_DIR="$HOME/.custom-nvm-dir"
antigen bundle Meroje/zsh-nvm
```

### Lazy Loading

If you find `nvm` adds too much lag to your shell startup you can enable lazy loading by exporting the `NVM_LAZY_LOAD` environment variable and setting it to `true`. It must be set before `zsh-nvm` is loaded.

Lazy loading is around 70x faster (874ms down to 12ms for me), however the first time you run `nvm`, `npm`, `node` or a global module you'll get a slight delay while `nvm` loads first. You'll only get this delay once per session.

For example, if you are using antigen, you would put the following in your `.zshrc`:

```shell
export NVM_LAZY_LOAD=true
antigen bundle Meroje/zsh-nvm
```

Performance comparison:

```shell
% time (source "$NVM_DIR/nvm.sh")
( source "$NVM_DIR/nvm.sh"; )  0.58s user 0.37s system 109% cpu 0.874 total

% time (_zsh_nvm_lazy_load)
( _zsh_nvm_lazy_load; )  0.01s user 0.01s system 168% cpu 0.012 total
```

### Don't autoload node

By default when `nvm` is loaded it'll automatically run `nvm use default` and load your default `node` version along with `npm` and any global modules. You can disable this behaviour by exporting the `NVM_NO_USE` environment variable and setting it to `true`. It must be set before `zsh-nvm` is loaded.

If you enable this option you will then need to manually run `nvm use <version>` before you can use `node`.

For example, if you are using antigen, you would put the following in your `.zshrc`:

```shell
export NVM_NO_USE=true
antigen bundle Meroje/zsh-nvm
```

### Auto use

If you have lots of projects with an `.nvmrc` file you may find the auto use option helpful. If it's enabled, when you `cd` into a directory with an `.nvmrc` file, `zsh-nvm` will automatically load or install the required node version in `.nvmrc`. You can enable it by exporting the `NVM_AUTO_USE` environment variable and setting it to `true`. It must be set before `zsh-nvm` is loaded.

If you enable this option and don't have `nvm` loaded in the current session (`NVM_LAZY_LOAD` or `NVM_NO_USE`) it won't work until you've loaded `nvm`.

For example, if you are using antigen, you would put the following in your `.zshrc`:

```shell
export NVM_AUTO_USE=true
antigen bundle Meroje/zsh-nvm
```

## Installation

### Using [Antigen](https://github.com/zsh-users/antigen)

Bundle `zsh-nvm` in your `.zshrc`

```shell
antigen bundle Meroje/zsh-nvm
```

### Using [zplug](https://github.com/b4b4r07/zplug)
Load `zsh-nvm` as a plugin in your `.zshrc`

```shell
zplug "Meroje/zsh-nvm"

```
### Using [zgen](https://github.com/tarjoilija/zgen)

Include the load command in your `.zshrc`

```shell
zgen load Meroje/zsh-nvm
```

### As an [Oh My ZSH!](https://github.com/robbyrussell/oh-my-zsh) custom plugin

Clone `zsh-nvm` into your custom plugins repo

```shell
git clone https://github.com/Meroje/zsh-nvm ~/.oh-my-zsh/custom/plugins/zsh-nvm
```
Then load as a plugin in your `.zshrc`

```shell
plugins+=(zsh-nvm)
```

Keep in mind that plugins need to be added before `oh-my-zsh.sh` is sourced.

### Manually
Clone this repository somewhere (`~/.zsh-nvm` for example)

```shell
git clone https://github.com/Meroje/zsh-nvm.git ~/.zsh-nvm
```
Then source it in your `.zshrc` (or `.bashrc`)

```shell
source ~/.zsh-nvm/zsh-nvm.plugin.zsh
```

## Tests

To run the tests you'll need to install [Urchin](https://github.com/tlevine/urchin#install). You'll also need to run the tests in an environment that doesn't already have `node` or `nvm` loaded.

You can remove `nvm` from the existing session with:

```shell
nvm deactivate && nvm unload
```

Run the tests with:

```shell
urchin -s zsh tests
```



## Related

- [`zsh-better-npm-completion`](https://github.com/lukechilds/zsh-better-npm-completion) - Better completion for `npm`

## License

MIT © Luke Childs
