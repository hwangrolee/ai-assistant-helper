#!/bin/bash
input=$(cat)

# Debug: capture full input
echo "$input" > ~/.claude/statusline-debug.json

# ============================================
# Daily Statistics Logging
# ============================================
STATS_DIR="$HOME/.claude/stats"
mkdir -p "$STATS_DIR"

today=$(date "+%Y-%m-%d")
stats_file="$STATS_DIR/$today.jsonl"
session_id=$(echo "$input" | jq -r '.session_id // "unknown"')

# Get current values
current_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
current_input_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
current_output_tokens=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
current_cache_create=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
current_cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
current_model=$(echo "$input" | jq -r '.model.display_name // "unknown"')
current_project=$(echo "$input" | jq -r '.cwd // "unknown"')
current_lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
current_lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

# Get git branch for logging
if [ -d "$current_project" ] && git -C "$current_project" rev-parse --git-dir > /dev/null 2>&1; then
    current_branch=$(git -C "$current_project" symbolic-ref --short HEAD 2>/dev/null || git -C "$current_project" rev-parse --short HEAD 2>/dev/null)
else
    current_branch=""
fi

# Log statistics (cumulative values only, no delta calculation)
total_tokens=$((current_input_tokens + current_output_tokens))
last_state_file="$STATS_DIR/.last_state_${session_id}"

# Check if state changed (to avoid duplicate entries)
should_log=false
current_state="${session_id}|${total_tokens}|${current_cost}"

if [ -f "$last_state_file" ]; then
    last_state=$(cat "$last_state_file")
    if [ "$current_state" != "$last_state" ]; then
        should_log=true
    fi
else
    should_log=true
fi

if [ "$should_log" = true ]; then
    timestamp=$(date "+%Y-%m-%dT%H:%M:%S")

    # Create JSON log entry with cumulative values only
    log_entry=$(jq -n \
        --arg ts "$timestamp" \
        --arg sid "$session_id" \
        --arg model "$current_model" \
        --arg project "$(basename "$current_project")" \
        --arg branch "$current_branch" \
        --argjson in_tokens "$current_input_tokens" \
        --argjson out_tokens "$current_output_tokens" \
        --argjson total_tokens "$total_tokens" \
        --argjson cache_create "$current_cache_create" \
        --argjson cache_read "$current_cache_read" \
        --argjson cost "$current_cost" \
        --argjson lines_added "$current_lines_added" \
        --argjson lines_removed "$current_lines_removed" \
        -c '{
            timestamp: $ts,
            session_id: $sid,
            model: $model,
            project: $project,
            branch: $branch,
            input_tokens: $in_tokens,
            output_tokens: $out_tokens,
            total_tokens: $total_tokens,
            cache_creation_tokens: $cache_create,
            cache_read_tokens: $cache_read,
            cost_usd: $cost,
            lines_added: $lines_added,
            lines_removed: $lines_removed
        }')

    # Use flock to prevent race condition when multiple sessions write simultaneously
    (
      flock -x 200
      echo "$log_entry" >> "$stats_file"
    ) 200>"$stats_file.lock"
    # Save state to detect changes
    echo "$current_state" > "$last_state_file"
fi

# ============================================
# Colors
reset=$'\033[0m'
bold=$'\033[1m'
dim=$'\033[2m'
green=$'\033[32m'
yellow=$'\033[33m'
red=$'\033[1;31m'
orange=$'\033[38;5;208m'
gold=$'\033[38;5;220m'
cyan=$'\033[36m'
magenta=$'\033[35m'

# 1. Current directory
current_dir=$(echo "$input" | jq -r '.cwd // "unknown"')
dir_name=$(basename "$current_dir")

# 2. Git branch + enhanced status
if [ -d "$current_dir" ] && git -C "$current_dir" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$current_dir" symbolic-ref --short HEAD 2>/dev/null || git -C "$current_dir" rev-parse --short HEAD 2>/dev/null)

    # Uncommitted files count
    uncommitted=$(git -C "$current_dir" status --porcelain 2>/dev/null | wc -l | tr -d ' ')

    # Ahead/behind remote
    ahead_behind=$(git -C "$current_dir" rev-list --left-right --count @{upstream}...HEAD 2>/dev/null)
    if [ -n "$ahead_behind" ]; then
        behind=$(echo "$ahead_behind" | cut -f1)
        ahead=$(echo "$ahead_behind" | cut -f2)
        sync_info=""
        [ "$ahead" -gt 0 ] && sync_info+="${green}↑${ahead}${reset}"
        [ "$behind" -gt 0 ] && sync_info+="${red}↓${behind}${reset}"
    else
        sync_info=""
    fi

    # Build git info string
    git_info=" ${dim}on${reset} ${magenta}${branch}${reset}"
    [ "$uncommitted" -gt 0 ] && git_info+=" ${yellow}●${uncommitted}${reset}"
    [ -n "$sync_info" ] && git_info+=" ${sync_info}"
else
    git_info=""
fi

# 3. Model name
model=$(echo "$input" | jq -r '.model.display_name // "unknown"')

# 4. Context window with progress bar
ctx=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
ctx_size_k=$((ctx_size / 1000))

# Progress bar (10 chars)
bar_filled=$((ctx / 10))
bar_empty=$((10 - bar_filled))
bar_str=""
for ((i=0; i<bar_filled; i++)); do bar_str+="█"; done
for ((i=0; i<bar_empty; i++)); do bar_str+="░"; done

# Color based on usage
if [ "$ctx" -lt 50 ]; then
    ctx_color=$green
elif [ "$ctx" -lt 75 ]; then
    ctx_color=$yellow
elif [ "$ctx" -lt 90 ]; then
    ctx_color=$orange
else
    ctx_color=$red
fi

# 5. Tokens (input/output breakdown)
input_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
output_tokens=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')

# Format tokens (K for thousands)
format_tokens() {
    local num=$1
    if [ "$num" -ge 1000 ]; then
        printf "%.1fK" "$(echo "scale=1; $num/1000" | bc)"
    else
        printf "%d" "$num"
    fi
}
in_display=$(format_tokens "$input_tokens")
out_display=$(format_tokens "$output_tokens")

# 5.1 Cache hit rate
cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
cache_create=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
total_cache=$((cache_read + cache_create))

if [ "$total_cache" -gt 0 ]; then
    cache_rate=$(echo "scale=0; $cache_read * 100 / $total_cache" | bc)
    # Color based on cache efficiency
    if [ "$cache_rate" -ge 80 ]; then
        cache_color=$green
    elif [ "$cache_rate" -ge 50 ]; then
        cache_color=$yellow
    else
        cache_color=$orange
    fi
    cache_display="${cache_color}⚡${cache_rate}%${reset}"
else
    cache_display="${dim}⚡-${reset}"
fi

# 6. Cost with color coding
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
cost_display=$(printf "%.2f" "$cost")

# Cost color: green < $1, yellow < $5, orange < $10, red >= $10
cost_int=$(printf "%.0f" "$cost")
if [ "$(echo "$cost < 1" | bc)" -eq 1 ]; then
    cost_color=$green
elif [ "$(echo "$cost < 5" | bc)" -eq 1 ]; then
    cost_color=$gold
elif [ "$(echo "$cost < 10" | bc)" -eq 1 ]; then
    cost_color=$orange
else
    cost_color=$red
fi

# 7. Lines changed
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

# 8. Session duration
duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
duration_sec=$((duration_ms / 1000))
duration_min=$((duration_sec / 60))
duration_hour=$((duration_min / 60))
remaining_min=$((duration_min % 60))
remaining_sec=$((duration_sec % 60))

if [ "$duration_hour" -gt 0 ]; then
    duration_display="${duration_hour}h ${remaining_min}m"
elif [ "$duration_min" -gt 0 ]; then
    duration_display="${duration_min}m ${remaining_sec}s"
else
    duration_display="${duration_sec}s"
fi

start_time=$(date -v-${duration_sec}S "+%H:%M")
current_time=$(date "+%H:%M")

# 9. Historical statistics (today, 7d, 30d)
format_cost() {
    local cost=$1
    if [ "$(echo "$cost >= 1000" | bc)" -eq 1 ]; then
        printf "%.1fK" "$(echo "scale=1; $cost/1000" | bc)"
    else
        printf "%.1f" "$cost"
    fi
}

# Calculate actual cost/tokens occurred on a specific day
# Strategy:
#   - If session exists in previous day: cost = today_last - yesterday_last
#   - If session is new (not in prev day): cost = today_last (base = 0)
# Note: Handles both old format (cumulative field) and new format (direct fields)
get_day_stats() {
    local date_str=$1
    local file="$STATS_DIR/$date_str.jsonl"
    local prev_date=$(date -v-1d -j -f "%Y-%m-%d" "$date_str" "+%Y-%m-%d" 2>/dev/null)
    local prev_file="$STATS_DIR/$prev_date.jsonl"

    if [ ! -f "$file" ]; then
        echo "0|0"
        return
    fi

    # Get previous day's last values per session
    local prev_data="{}"
    if [ -f "$prev_file" ]; then
        prev_data=$(jq -s '
            group_by(.session_id) |
            map(.[-1] as $last | {
                key: $last.session_id,
                value: {
                    cost: ($last.cumulative.cost_usd // $last.cost_usd // 0),
                    tokens: (if $last.cumulative then ($last.cumulative.input_tokens + $last.cumulative.output_tokens) else ($last.total_tokens // 0) end)
                }
            }) |
            from_entries
        ' "$prev_file" 2>/dev/null || echo "{}")
    fi

    # Calculate today's cost per session
    # If session in prev_data, use prev as base; otherwise base is 0 (new session)
    local result=$(jq -s --argjson prev "$prev_data" '
        group_by(.session_id) |
        map(
            .[-1] as $last |
            $last.session_id as $sid |
            (($last.cumulative.cost_usd // $last.cost_usd // 0)) as $last_cost |
            ((if $last.cumulative then ($last.cumulative.input_tokens + $last.cumulative.output_tokens) else ($last.total_tokens // 0) end)) as $last_tokens |
            (if $prev[$sid] then $prev[$sid] else {cost: 0, tokens: 0} end) as $base |
            {
                cost: ($last_cost - $base.cost),
                tokens: ($last_tokens - $base.tokens)
            }
        ) |
        {
            tokens: (map(.tokens) | add // 0),
            cost: (map(.cost) | add // 0)
        }
    ' "$file" 2>/dev/null)

    local day_tokens=$(echo "$result" | jq -r '.tokens // 0')
    local day_cost=$(echo "$result" | jq -r '.cost // 0')

    echo "$day_tokens|$day_cost"
}

get_period_stats() {
    local days=$1
    local total_cost=0
    local total_tokens=0

    for i in $(seq 0 $((days - 1))); do
        local date_str=$(date -v-${i}d "+%Y-%m-%d")
        local day_stats=$(get_day_stats "$date_str")
        local day_tokens=$(echo "$day_stats" | cut -d'|' -f1)
        local day_cost=$(echo "$day_stats" | cut -d'|' -f2)
        total_cost=$(echo "$total_cost + $day_cost" | bc)
        total_tokens=$((total_tokens + day_tokens))
    done

    echo "$total_tokens|$total_cost"
}

# Get stats for this month (from 1st of current month to today)
get_this_month_stats() {
    local total_cost=0
    local total_tokens=0
    local today_day=$(date "+%d" | sed 's/^0//')  # Remove leading zero

    for i in $(seq 0 $((today_day - 1))); do
        local date_str=$(date -v-${i}d "+%Y-%m-%d")
        local day_stats=$(get_day_stats "$date_str")
        local day_tokens=$(echo "$day_stats" | cut -d'|' -f1)
        local day_cost=$(echo "$day_stats" | cut -d'|' -f2)
        total_cost=$(echo "$total_cost + $day_cost" | bc)
        total_tokens=$((total_tokens + day_tokens))
    done

    echo "$total_tokens|$total_cost"
}

# Get stats for last month (same period: 1st to same day of last month)
get_last_month_stats() {
    local total_cost=0
    local total_tokens=0
    local today_day=$(date "+%d" | sed 's/^0//')  # Current day of month
    local last_month_last_day=$(date -v1d -v-1d "+%d" | sed 's/^0//')  # Last day of previous month

    # Use minimum of current day and last month's last day
    local days_to_check=$today_day
    if [ "$today_day" -gt "$last_month_last_day" ]; then
        days_to_check=$last_month_last_day
    fi

    for i in $(seq 1 $days_to_check); do
        local date_str=$(date -v1d -v-1m -v+$((i-1))d "+%Y-%m-%d")
        local day_stats=$(get_day_stats "$date_str")
        local day_tokens=$(echo "$day_stats" | cut -d'|' -f1)
        local day_cost=$(echo "$day_stats" | cut -d'|' -f2)
        total_cost=$(echo "$total_cost + $day_cost" | bc)
        total_tokens=$((total_tokens + day_tokens))
    done

    echo "$total_tokens|$total_cost"
}

# Format delta with color (green for positive savings, red for increase)
format_delta() {
    local current=$1
    local previous=$2
    local delta=$(echo "$current - $previous" | bc)
    local abs_delta=$(echo "$delta" | sed 's/^-//')

    if [ "$(echo "$delta > 0" | bc)" -eq 1 ]; then
        printf "${red}+\$%.1f${reset}" "$delta"
    elif [ "$(echo "$delta < 0" | bc)" -eq 1 ]; then
        printf "${green}-\$%.1f${reset}" "$abs_delta"
    else
        printf "${dim}±\$0${reset}"
    fi
}

# Get stats for each period (file already contains current session's latest values)
today_stats=$(get_period_stats 1)
today_tokens=$(echo "$today_stats" | cut -d'|' -f1)
today_cost=$(echo "$today_stats" | cut -d'|' -f2)

yesterday_stats=$(get_day_stats "$(date -v-1d '+%Y-%m-%d')")
yesterday_tokens=$(echo "$yesterday_stats" | cut -d'|' -f1)
yesterday_cost=$(echo "$yesterday_stats" | cut -d'|' -f2)

# Current 7 days and previous 7 days (for delta)
week_stats=$(get_period_stats 7)
week_tokens=$(echo "$week_stats" | cut -d'|' -f1)
week_cost=$(echo "$week_stats" | cut -d'|' -f2)

# Previous 7 days (days 8-14 ago)
prev_week_cost=0
for i in $(seq 7 13); do
    day_stats=$(get_day_stats "$(date -v-${i}d '+%Y-%m-%d')")
    day_cost=$(echo "$day_stats" | cut -d'|' -f2)
    prev_week_cost=$(echo "$prev_week_cost + $day_cost" | bc)
done

this_month_stats=$(get_this_month_stats)
this_month_tokens=$(echo "$this_month_stats" | cut -d'|' -f1)
this_month_cost=$(echo "$this_month_stats" | cut -d'|' -f2)

last_month_stats=$(get_last_month_stats)
last_month_tokens=$(echo "$last_month_stats" | cut -d'|' -f1)
last_month_cost=$(echo "$last_month_stats" | cut -d'|' -f2)

# Format deltas
today_delta=$(format_delta "$today_cost" "$yesterday_cost")
week_delta=$(format_delta "$week_cost" "$prev_week_cost")
month_delta=$(format_delta "$this_month_cost" "$last_month_cost")

# Format for display
today_display="\$$(format_cost $today_cost)(${today_delta})"
week_display="\$$(format_cost $week_cost)(${week_delta})"
this_month_display="\$$(format_cost $this_month_cost)(${month_delta})"

# 10. Stats file size check
if [ -f "$stats_file" ]; then
    stats_size=$(stat -f%z "$stats_file" 2>/dev/null || echo "0")
else
    stats_size=0
fi

# Format size for display
format_size() {
    local bytes=$1
    if [ "$bytes" -ge 1048576 ]; then
        printf "%.1fMB" "$(echo "scale=1; $bytes/1048576" | bc)"
    elif [ "$bytes" -ge 1024 ]; then
        printf "%.0fKB" "$(echo "scale=0; $bytes/1024" | bc)"
    else
        printf "%dB" "$bytes"
    fi
}

# Color based on file size
# Green: < 500KB, Yellow: 500KB-2MB, Orange: 2MB-5MB, Red: > 5MB
if [ "$stats_size" -lt 512000 ]; then
    size_color=$green
elif [ "$stats_size" -lt 2097152 ]; then
    size_color=$yellow
elif [ "$stats_size" -lt 5242880 ]; then
    size_color=$orange
else
    size_color=$red
fi

stats_size_display="${size_color}$(format_size $stats_size)${reset}"

# Output
line1="${cyan}📁 ${bold}${dir_name}${reset}${git_info}"
line2="🤖 ${bold}${model}${reset}  ${dim}│${reset}  ${ctx_color}${bar_str}${reset} ${ctx}%${dim}/${ctx_size_k}K${reset}  ${dim}│${reset}  📊 ${dim}in:${reset}${in_display} ${dim}out:${reset}${out_display} ${cache_display}  ${dim}│${reset}  💰 ${cost_color}\$${cost_display}${reset}"
line3="⏳ ${duration_display} ${dim}(${start_time}~${current_time})${reset}  ${dim}│${reset}  📝 ${green}+${lines_added}${reset} ${red}-${lines_removed}${reset}"
line4="📈 ${dim}Today:${reset}${cyan}${today_display}${reset} ${dim}│${reset} ${dim}7d:${reset}${yellow}${week_display}${reset} ${dim}│${reset} ${dim}Month:${reset}${gold}${this_month_display}${reset} ${dim}│${reset} 🗂️ ${stats_size_display}"

printf "%s\n%s\n%s\n%s" "$line1" "$line2" "$line3" "$line4"
