# =================== REQUIRED FILES DEFINITIONS ===================
CACHE_FILE="$HOME/.zsh-custom-data/cache"
CACHE_LOCK="$HOME/.zsh-custom-data/cache.lock"

# Load zsh/system module for zsystem flock
zmodload zsh/system 2>/dev/null

# =================== CACHE FUNCTIONS ===================
init_cache() {
  [[ -f "$CACHE_FILE" ]] || touch "$CACHE_FILE"
  chmod 600 "$CACHE_FILE"  # Secure permissions
}

# Acquire lock using mkdir (atomic on all Unix systems)
acquire_lock() {
  local lock_dir="${CACHE_LOCK}.d"
  local max_wait=50  # 5 seconds max wait (50 * 0.1s)
  local count=0

  while ! mkdir "$lock_dir" 2>/dev/null; do
    ((count++))
    if ((count >= max_wait)); then
      # Stale lock check: if older than 10 seconds, remove it
      if [[ -d "$lock_dir" ]]; then
        local lock_age=$(($(date +%s) - $(stat -f %m "$lock_dir" 2>/dev/null || echo 0)))
        if ((lock_age > 10)); then
          rmdir "$lock_dir" 2>/dev/null
          continue
        fi
      fi
      return 1
    fi
    sleep 0.1
  done
  return 0
}

# Release lock
release_lock() {
  local lock_dir="${CACHE_LOCK}.d"
  rmdir "$lock_dir" 2>/dev/null
}

get_cached_parent_version() {
  local tech="$1"
  local current_path="${PWD%/}"
  local cache_file="${CACHE_FILE:-"$HOME/.zsh-custom-data/cache"}"

  [[ -f "$cache_file" ]] || return 1

  # Use faster input splitting
  while IFS='=' read -r key value; do
    # Skip malformed lines
    [[ -z "$key" ]] && continue

    # Faster prefix check than [[ == ]]
    if [[ "$key" == "$tech|"* ]]; then
      local cached_path="${key#$tech|}"

      # Exact match case
      if [[ "$current_path" == "$cached_path" ]]; then
        printf '%s' "$value"
        return 0
      fi

      # Parent directory match
      if [[ "$current_path" == "$cached_path"/* ]]; then
        printf '%s' "$value"
        return 0
      fi
    fi
  done < "$cache_file"

  return 1
}

get_cached() {
  local key="$1"
  [[ -f "$CACHE_FILE" ]] || return 1
  grep -m1 -F -- "$key=" "$CACHE_FILE" 2>/dev/null | cut -d= -f2-
}

set_cached() {
  local key="$1" value="$2"

  acquire_lock || return 1
  init_cache  # Ensure file exists

  # Using temp file for atomic write
  local tempfile
  tempfile=$(mktemp)
  awk -v key="$key" -v value="$value" '
    BEGIN { FS=OFS="="; found=0 }
    $1 == key { print key "=" value; found=1; next }
    { print }
    END { if (!found) print key "=" value }
  ' "$CACHE_FILE" > "$tempfile" && \
  mv "$tempfile" "$CACHE_FILE"

  release_lock
}

reset_version_cache() {
  acquire_lock || return 1
  [[ -f "$CACHE_FILE" ]] && > "$CACHE_FILE"
  release_lock
}

# =================== VERSION MANAGEMENT FUNCTIONS ===================
get_tech_version() {
  local tech="$1"
  local parent_version; parent_version=$(get_cached_parent_version "$tech") || return 1
  printf '%s' "$parent_version"
}

print_version() {
  local version="$1" icon="$2" color="$3"
  [[ -n "${version// /}" ]] || return
  printf ' %%F{245}| %%F{%d}%s %s%%f' "$color" "$icon" "$version"
}

# =================== DATA FUNCTIONS ===================
user_name_value() {
  echo "$USER"
}

computer_name_value() {
  echo "$HOST"
}

battery_value() {
  local percentage=$(upower -i /org/freedesktop/UPower/devices/battery_BAT1 2>/dev/null | grep percentage | awk '{print $2}')
  echo "${percentage:-N/A}"
}

node_version() {
  get_tech_version "node" || {
    [[ -f "$PWD/package.json" ]] || return
    local version=$(node --version 2>/dev/null)
    [[ -n "$version" ]] && set_cached "node|$PWD" "${version#v}" && echo "${version#v}"
  }
}

php_version() {
  get_tech_version "php" || {
    [[ -f "$PWD/composer.json" || -f "$PWD/index.php" ]] || return
    local version=$(php -r "echo PHP_VERSION;" 2>/dev/null)
    [[ -n "$version" ]] && set_cached "php|$PWD" "${version#v}" && echo "$version"
  }
}

python_version() {
  get_tech_version "python" || {
    local py_cmd=$(command -v python3 || command -v python 2>/dev/null)
    [[ -z "$py_cmd" ]] || [[ ! ( -n $(find . -maxdepth 1 -name '*.py' -print -quit) || -f requirements.txt || -f setup.py || -f main.py || -f index.py || -f pyproject.toml ) ]] && return
    local version=$($py_cmd --version 2>&1 | awk '{print $2}')
    [[ -n "$version" ]] && set_cached "python|$PWD" "${version#v}" && echo "$version"
  }
}

python_environment() {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    echo "venv:$(basename "$VIRTUAL_ENV")"
  elif [[ -n "$CONDA_DEFAULT_ENV" && "$CONDA_DEFAULT_ENV" != "base" ]]; then
    echo "conda:$(basename "$CONDA_DEFAULT_ENV")"
  fi
}

mc_spigot_version() {
  get_tech_version "mc_spigot" || {
    [[ -f "version_history.json" ]] || return
    local version=$(grep -m1 -oP '"currentVersion":\s*"\K\d+\.\d+\.\d+' version_history.json 2>/dev/null)
    [[ -n "$version" ]] && set_cached "mc_spigot|$PWD" "${version#v}" && echo "$version"
  }
}

git_version() {
  local branch=$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --exact-match HEAD 2>/dev/null)
  [[ -n "$branch" ]] && echo "$branch"
}

# =================== PRINT FUNCTIONS ===================
user_name_ps1()     { local v; v=$(user_name_value)     && print_version "$v" "👤" 250; }
computer_name_ps1() { local v; v=$(computer_name_value) && print_version "$v" "💻" 180; }
battery_ps1()       { local v; v=$(battery_value)       && print_version "$v" "⚡" 226; }
node_ps1()          { local v; v=$(node_version)        && print_version "$v" "⬢" 120; }
php_ps1()           { local v; v=$(php_version)         && print_version "$v" "🐘" 183; }
python_ps1()        {
  local v env
  v=$(python_version 2>/dev/null) || return  # Handle errors too
  [[ -z "$v" ]] && return  # Handle empty strings
  env=$(python_environment 2>/dev/null)
  print_version "${v}${env:+ ($env)}" "🐍" 159  # Optional space separator
}
mc_spigot_ps1()     { local v; v=$(mc_spigot_version)   && print_version "$v" "⛏ " 183; }
git_ps1()           { local v; v=$(git_version)         && print_version "$v" "↳" 177; }
