# Initialize cache arrays
declare -gA __VERSION_CACHE

# Set required files
CACHE_FILE="$HOME/.bash-custom-data/cache"
CACHE_LOCK="$HOME/.bash-custom-data/cache.lock"

# =================== CACHE FUNCTIONS ===================
init_cache() {
    [[ -f "$CACHE_FILE" ]] || touch "$CACHE_FILE"
    chmod 600 "$CACHE_FILE"  # Secure permissions
}

get_cached_parent_version() {
    local tech="$1"
    local current_path="${PWD%/}"
    local cache_file="${CACHE_FILE:-"$HOME/.bash-custom-data/cache"}"
    
    (
        flock -s 200 || return 1
        
        # Use faster input splitting
        while IFS='=' read -r key value; do
            # Skip malformed lines
            [[ -z "$key" ]] && continue
            
            # Faster prefix check than [[ == ]]
            if [[ "$key" =~ ^"$tech|"(.*) ]]; then
                local cached_path="${BASH_REMATCH[1]}"
                
                # Exact match case
                if [[ "$current_path" == "$cached_path" ]]; then
                    printf '%s' "$value"
                    exit 0
                fi
                
                # Parent directory match
                if [[ "$current_path" == "$cached_path"/* ]]; then
                    printf '%s' "$value"
                    exit 0
                fi
            fi
        done < "$cache_file"
        
        exit 1
    ) 200<"${CACHE_LOCK:-"$HOME/.bash-custom-data/cache.lock"}"
    
    return $?
}

get_cached() {
    local key="$1"
    (
        flock -s 200 || return 1
        [[ -f "$CACHE_FILE" ]] || return 1
        grep -m1 -F -- "$key=" "$CACHE_FILE" 2>/dev/null | cut -d= -f2-
    ) 200<"$CACHE_LOCK"
}

set_cached() {
    local key="$1" value="$2"
    (
        flock -x 200 || return 1
        init_cache  # Ensure file exists within lock
        
        # Using temp file for atomic write
        tempfile=$(mktemp)
        awk -v key="$key" -v value="$value" '
            BEGIN { FS=OFS="="; found=0 }
            $1 == key { print key "=" value; found=1; next }
            { print }
            END { if (!found) print key "=" value }
        ' "$CACHE_FILE" > "$tempfile" && \
        mv "$tempfile" "$CACHE_FILE"
    ) 200>"$CACHE_LOCK"
}

reset_version_cache() {
    (
        flock -x 200 || return 1
        [[ -f "$CACHE_FILE" ]] && > "$CACHE_FILE"
    ) 200>"$CACHE_LOCK"
}

# =================== VERSION MANAGEMENT FUNCTIONS ===================
get_tech_version() {
  local tech="$1"
  local parent_version; parent_version=$(get_cached_parent_version "$tech") || return 1
  printf '%s' "$parent_version"
}

print_version() {
  local version="$1" icon="$2" color="$3"
  [[ -n "$version" ]] || return
  printf ' \[\e[38;5;245m\]| \[\e[38;5;%dm\]%s %s\[\e[0m\]' "$color" "$icon" "$version"
}

# =================== DATA FUNCTIONS ===================
user_name_value() {
  echo "$USER"
}

computer_name_value() {
  echo "$HOSTNAME"
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
node_ps1()          { local v; v=$(node_version)        && print_version "$v" "⬢" 120; }
php_ps1()           { local v; v=$(php_version)         && print_version "$v" "🐘" 183; }
python_ps1()        { local v; v=$(python_version)      && print_version "$v" "🐍" 159; }
mc_spigot_ps1()     { local v; v=$(mc_spigot_version)   && print_version "$v" "⛏ " 183; }
git_ps1()           { local v; v=$(git_version)         && print_version "$v" "↳" 177; }
