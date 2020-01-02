KUBE_PS1_PREFIX=''
KUBE_PS1_SUFFIX=''
KUBE_PS1_SEPARATOR=''

LINUX=$'\uf83c'		# Tux from nerd fonts
RARROW=$'\uf061'	# Right arrow
DIR=$'\uf413'		# Directory icon
CLOCK=$'\uf43a'		# Clock icon
PYTHON=$'\ue235'	# Python from nerd fonts

# Print virtual env name with Python icon, if virtual env is set
function venv {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        echo -e "%{$fg[yellow]%}$PYTHON $(basename $VIRTUAL_ENV)%{$reset_color%} "
    fi
}

# Custom kube prompt (requires kube-ps1 plugin)
function custom_kube_ps1 {
    local reset_color="%{$reset_color%}"
    if [[ $KUBE_PS1_CONTEXT == *"prod"* || $KUBE_PS1_CONTEXT == *"prd"* ]]; then
        # prod kube contexts are in red
        KUBE_PS1_COLOR_CONTEXT="%F{red}"
    else
        # non-prod in blue
        KUBE_PS1_COLOR_CONTEXT="%F{blue}"
    fi

    KUBE_PS1="${reset_color}$KUBE_PS1_PREFIX"
    KUBE_PS1+="${KUBE_PS1_COLOR_SYMBOL}$(_kube_ps1_symbol)"
    KUBE_PS1+="${reset_color}$KUBE_PS1_SEPARATOR"
    KUBE_PS1+="${KUBE_PS1_COLOR_CONTEXT}$KUBE_PS1_CONTEXT${reset_color}"
    KUBE_PS1+="$KUBE_PS1_DIVIDER"
    KUBE_PS1+="${KUBE_PS1_COLOR_NS}$KUBE_PS1_NAMESPACE${reset_color}"
    KUBE_PS1+="$KUBE_PS1_SUFFIX"

    echo "${KUBE_PS1}"
}

source "${GITSTATUS_DIR:-${${(%):-%x}:h}}/gitstatus.plugin.zsh" || return

function gitstatus_prompt_update() {
  emulate -L zsh
  typeset -g  GITSTATUS_PROMPT=''

  gitstatus_query 'MY'                  || return 1  # error
  [[ $VCS_STATUS_RESULT == 'ok-sync' ]] || return 0  # not a git repo

  local      reset='%f'       # no foreground
  local      clean='%F{076}'  # green foreground
  local   modified='%F{011}'  # yellow foreground
  local  untracked='%F{014}'  # teal foreground
  local conflicted='%196F'    # red foreground

  local p

  # color git icon and branch name according to status
  if (( VCS_STATUS_HAS_CONFLICTED )); then
    p+="$conflicted"
  elif (( VCS_STATUS_HAS_STAGED || VCS_STATUS_HAS_UNSTAGED )); then
    p+="$modified"
  elif (( VCS_STATUS_HAS_UNTRACKED )); then
    p+="$untracked"
  else
    p+="$clean"
  fi

  p+=$'\uf418 '  # git icon from nerd fonts

  local where  # branch name, tag or commit
  if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
    where=$VCS_STATUS_LOCAL_BRANCH
  elif [[ -n $VCS_STATUS_TAG ]]; then
    p+='%f#'
    where=$VCS_STATUS_TAG
  else
    p+='%f@'
    where=${VCS_STATUS_COMMIT[1,8]}
  fi

  (( $#where > 32 )) && where[13,-13]="…"  # truncate long branch names and tags
  p+="${where//\%/%%}${reset}"             # escape %

  (( VCS_STATUS_NUM_STAGED     )) && p+="${modified}+"
  (( VCS_STATUS_NUM_UNSTAGED   )) && p+="${modified}!"
  (( VCS_STATUS_NUM_UNTRACKED  )) && p+="${untracked}?"

  (( VCS_STATUS_COMMITS_BEHIND )) && p+=" ${clean}⇣${VCS_STATUS_COMMITS_BEHIND}"
  (( VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )) && p+=" "
  (( VCS_STATUS_COMMITS_AHEAD  )) && p+="${clean}⇡${VCS_STATUS_COMMITS_AHEAD}"
  (( VCS_STATUS_STASHES        )) && p+=" ${clean}*${VCS_STATUS_STASHES}"
  [[ -n $VCS_STATUS_ACTION     ]] && p+=" ${conflicted}${VCS_STATUS_ACTION}"
  (( VCS_STATUS_NUM_CONFLICTED )) && p+=" ${conflicted}~${VCS_STATUS_NUM_CONFLICTED}"

  GITSTATUS_PROMPT="${reset}${p}${reset}"
}

# Start gitstatus
gitstatus_start -s -1 -u -1 -c -1 -d -1 'MY'

autoload -Uz add-zsh-hook
add-zsh-hook precmd gitstatus_prompt_update

# Set the prompts
PROMPT='$LINUX %{$fg[yellow]%}$RARROW%{$reset_color%} $(custom_kube_ps1)%f${GITSTATUS_PROMPT:+ $GITSTATUS_PROMPT} $(venv)%{$fg_bold[blue]%}$DIR %~%{$reset_color%} %(?,$ ,%{$fg[red]%}FAIL: %? $ %{$reset_color%})'

RPROMPT='%{$fg[green]%}$CLOCK %*%{$reset_color%}'
