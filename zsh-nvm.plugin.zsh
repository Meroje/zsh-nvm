ZSH_NVM_DIR=${0:a:h}

if [[ -z "$NVM_INSTALL_DIR" ]] && (( $+commands[brew] )) && [[ -d "$(brew --prefix nvm 2> /dev/null)" ]]; then
  export NVM_INSTALL_DIR="$(brew --prefix nvm)"
fi
[[ -z "$NVM_INSTALL_DIR" ]] && export NVM_INSTALL_DIR="$HOME/.nvm"
[[ -z "$NVM_DIR" ]] && export NVM_DIR="$HOME/.nvm"

_zsh_nvm_rename_function() {
  test -n "$(declare -f $1)" || return
  eval "${_/$1/$2}"
  unset -f $1
}

_zsh_nvm_has() {
  type "$1" > /dev/null 2>&1
}

_zsh_nvm_global_binaries() {

  # Look for global binaries
  local global_binary_paths="$(echo "$NVM_DIR"/v0*/bin/*(N) "$NVM_DIR"/versions/*/*/bin/*(N))"

  # If we have some, format them
  if [[ -n "$global_binary_paths" ]]; then
    echo "$NVM_DIR"/v0*/bin/*(N) "$NVM_DIR"/versions/*/*/bin/*(N) |
      xargs -n 1 basename |
      sort |
      uniq
  fi
}

_zsh_nvm_load() {

  # Source nvm (check if `nvm use` should be ran after load)
  if [[ "$NVM_NO_USE" == true ]]; then
    source "$NVM_INSTALL_DIR/nvm.sh" --no-use
  else
    source "$NVM_INSTALL_DIR/nvm.sh"
  fi

  # Rename main nvm function
  _zsh_nvm_rename_function nvm _zsh_nvm_nvm

  # Wrap nvm in our own function
  nvm() {
    case $1 in
      'use')
        _zsh_nvm_nvm "$@"
        export NVM_AUTO_USE_ACTIVE=false
        ;;
      *)
        _zsh_nvm_nvm "$@"
        ;;
    esac
  }
}

_zsh_nvm_lazy_load() {

  # Get all global node module binaries including node
  # (only if NVM_NO_USE is off)
  local global_binaries
  if [[ "$NVM_NO_USE" == true ]]; then
    global_binaries=()
  else
    global_binaries=($(_zsh_nvm_global_binaries))
  fi

  # Add yarn lazy loader if it's been installed by something other than npm
  _zsh_nvm_has yarn && global_binaries+=('yarn')

  # Add nvm
  global_binaries+=('nvm')

  # Remove any binaries that conflict with current aliases
  local cmds
  cmds=()
  for bin in $global_binaries; do
    [[ "$(which $bin 2> /dev/null)" = "$bin: aliased to "* ]] || cmds+=($bin)
  done

  # Create function for each command
  for cmd in $cmds; do

    # When called, unset all lazy loaders, load nvm then run current command
    eval "$cmd(){
      unset -f $cmds > /dev/null 2>&1
      _zsh_nvm_load
      $cmd \"\$@\"
    }"
  done
}

autoload -U add-zsh-hook
_zsh_nvm_auto_use() {
  _zsh_nvm_has nvm_find_nvmrc || return

  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [[ -n "$nvmrc_path" ]]; then
    local nvmrc_node_version="$(nvm version $(cat "$nvmrc_path"))"

    if [[ "$nvmrc_node_version" = "N/A" ]]; then
      nvm install && export NVM_AUTO_USE_ACTIVE=true
    elif [[ "$nvmrc_node_version" != "$node_version" ]]; then
      nvm use && export NVM_AUTO_USE_ACTIVE=true
    fi
  elif [[ "$node_version" != "$(nvm version default)" ]] && [[ "$NVM_AUTO_USE_ACTIVE" = true ]]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}

# Don't init anything if this is true (debug/testing only)
if [[ "$ZSH_NVM_NO_LOAD" != true ]]; then

  # Install nvm if it isn't already installed
  [[ ! -f "$NVM_INSTALL_DIR/nvm.sh" ]] && _zsh_nvm_install

  # If nvm is installed
  if [[ -f "$NVM_INSTALL_DIR/nvm.sh" ]]; then

    # Load it
    [[ "$NVM_LAZY_LOAD" == true ]] && _zsh_nvm_lazy_load || _zsh_nvm_load

    # Auto use nvm on chpwd
    [[ "$NVM_AUTO_USE" == true ]] && add-zsh-hook chpwd _zsh_nvm_auto_use && _zsh_nvm_auto_use
  fi

fi

# Make sure we always return good exit code
# We can't `return 0` because that breaks antigen
true
