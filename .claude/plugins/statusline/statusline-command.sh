#!/bin/bash
input=$(cat)

# Debug: capture full input
echo "$input" > ~/.claude/statusline-debug.json

# ============================================
# Plan Configuration
# ============================================
PLAN_NAME="Teams"

# ============================================
# Colors
# ============================================
reset=$'\033[0m'
bold=$'\033[1m'
dim=$'\033[2m'
green=$'\033[32m'
yellow=$'\033[33m'
red=$'\033[1;31m'
orange=$'\033[38;5;208m'
cyan=$'\033[36m'
magenta=$'\033[35m'

# ============================================
# 1. Current directory + git info
# ============================================
cwd=$(echo "$input" | jq -r '.cwd // "unknown"')
dir_name=$(basename "$cwd")

git_info=""
if [ -d "$cwd" ] && git --no-optional-locks -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git --no-optional-locks -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || \
             git --no-optional-locks -C "$cwd" rev-parse --short HEAD 2>/dev/null)
    uncommitted=$(git --no-optional-locks -C "$cwd" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    ahead_behind=$(git --no-optional-locks -C "$cwd" rev-list --left-right --count @{upstream}...HEAD 2>/dev/null)

    git_info=" ${dim}on${reset} ${magenta}${branch}${reset}"
    [ "$uncommitted" -gt 0 ] && git_info+=" ${yellow}●${uncommitted}${reset}"

    if [ -n "$ahead_behind" ]; then
        behind=$(echo "$ahead_behind" | cut -f1)
        ahead=$(echo "$ahead_behind" | cut -f2)
        [ "$ahead" -gt 0 ] && git_info+=" ${green}↑${ahead}${reset}"
        [ "$behind" -gt 0 ] && git_info+=" ${red}↓${behind}${reset}"
    fi
fi

# ============================================
# 2. Model + context window progress bar
# ============================================
model=$(echo "$input" | jq -r '.model.display_name // "unknown"')
ctx=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
ctx_size_k=$((ctx_size / 1000))

bar_filled=$((ctx / 10))
bar_str=""
for ((i=0; i<bar_filled; i++)); do bar_str+="█"; done
for ((i=0; i<(10 - bar_filled); i++)); do bar_str+="░"; done

if   [ "$ctx" -lt 50 ]; then ctx_color=$green
elif [ "$ctx" -lt 75 ]; then ctx_color=$yellow
elif [ "$ctx" -lt 90 ]; then ctx_color=$orange
else                          ctx_color=$red
fi

# ============================================
# 3. Rate limits (5h / 7d)
# ============================================
rl_5h_pct=$(echo "$input" | jq -r '(.rate_limits.five_hour.used_percentage // 0) | floor')
rl_5h_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // 0')
rl_7d_pct=$(echo "$input" | jq -r '(.rate_limits.seven_day.used_percentage // 0) | floor')
rl_7d_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // 0')

# 5-char progress bar (each block = 20%)
make_rate_bar() {
    local pct=$1
    local filled=$(( pct / 20 ))
    [ "$filled" -gt 5 ] && filled=5
    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=filled; i<5; i++)); do bar+="░"; done
    echo "$bar"
}

# Color by usage %
rate_color() {
    local pct=$1
    if   [ "$pct" -ge 90 ]; then echo "$red"
    elif [ "$pct" -ge 75 ]; then echo "$orange"
    elif [ "$pct" -ge 50 ]; then echo "$yellow"
    else                          echo "$green"
    fi
}

# Absolute reset time: HH:MM (today) or MM/DD HH:MM (other day)
format_reset_time() {
    local ts
    ts=$(printf "%.0f" "$1")
    [ "$ts" -eq 0 ] && echo "-" && return
    local now
    now=$(date +%s)
    [ "$((ts - now))" -le 0 ] && echo "soon" && return
    if [ "$(date -r "$ts" '+%Y-%m-%d')" = "$(date '+%Y-%m-%d')" ]; then
        date -r "$ts" "+%H:%M"
    else
        date -r "$ts" "+%m/%d %H:%M"
    fi
}

rl_5h_bar=$(make_rate_bar "$rl_5h_pct")
rl_7d_bar=$(make_rate_bar "$rl_7d_pct")
rl_5h_color=$(rate_color "$rl_5h_pct")
rl_7d_color=$(rate_color "$rl_7d_pct")
rl_5h_reset_fmt=$(format_reset_time "$rl_5h_reset")
rl_7d_reset_fmt=$(format_reset_time "$rl_7d_reset")

# ============================================
# Output
# ============================================
line1="${cyan}📁 ${bold}${dir_name}${reset}${git_info}"
line2="🤖 ${bold}${model}${reset}  ${dim}│${reset}  ${ctx_color}${bar_str}${reset} ${ctx}%${dim}/${ctx_size_k}K${reset}  ${dim}│${reset}  🎫 ${cyan}${bold}${PLAN_NAME}${reset}"
line3="⏱️  ${dim}5h:${reset} ${rl_5h_color}${rl_5h_bar} ${rl_5h_pct}%${reset} ${dim}↻${rl_5h_reset_fmt}${reset}   ${dim}│${reset}   🗓️  ${dim}7d:${reset} ${rl_7d_color}${rl_7d_bar} ${rl_7d_pct}%${reset} ${dim}↻${rl_7d_reset_fmt}${reset}"

printf "%s\n%s\n%s" "$line1" "$line2" "$line3"
