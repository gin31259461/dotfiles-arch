#!/usr/bin/env bash
# Changes Zsh theme dynamically

# preview of theme can be view here: https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# after choosing theme, TTY need to be closed and re-open

iDIR="$HOME/.config/swaync/images"
rofi_theme="$HOME/.config/rofi/config-zsh-theme.rasi"

themes_dir="$HOME/.oh-my-zsh/themes"
file_extension=".zsh-theme"

mapfile -t themes_array < <(find -L "$themes_dir" -type f -name "*${file_extension}" -printf "%f\n" | sed "s/${file_extension}//")
themes_array=("Random" "${themes_array[@]}")

rofi_command=(rofi -i -dmenu -config "$rofi_theme")

main() {
  choice=$(printf '%s\n' "${themes_array[@]}" | "${rofi_command[@]}")
  [[ -z "$choice" ]] && exit 0

  zsh_path="$HOME/.zshrc"

  if [[ "$choice" == "Random" ]]; then
    themes_only=("${themes_array[@]:1}")
    random_theme="${themes_only[$((RANDOM % ${#themes_only[@]}))]}"
    theme_to_set="$random_theme"
    notify-send -i "$iDIR/ja.png" "Random theme:" "selected: $random_theme"
  else
    theme_to_set="$choice"
    notify-send -i "$iDIR/ja.png" "Theme selected:" "$choice"
  fi

  if [[ -f "$zsh_path" ]]; then
    safe_theme=$(printf '%s' "$theme_to_set" | sed 's/[\/&]/\\&/g')
    sed -i "s/^ZSH_THEME=.*/ZSH_THEME=\"${safe_theme}\"/" "$zsh_path"
    notify-send -i "$iDIR/ja.png" "OMZ theme" "applied. restart your terminal"
  else
    notify-send -i "$iDIR/error.png" "E-R-R-O-R" "~.zshrc file not found!"
  fi
}

# Check if rofi is already running
if pgrep -x rofi >/dev/null; then
  pkill rofi
fi

main
