# Use the hex colors from your Oh My Posh JSON
# Red: #E36464 | Cyan: #56B6C2 | Gold: #DDB15F | Purple: #D4AAFC | Yellow: #DCB977

# Git Segment Configuration (Only shows when in a Git repo)
ZSH_THEME_GIT_PROMPT_PREFIX=" %F{#DDB15F}git(%f%F{#D4AAFC}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%f%F{#DDB15F})%f"
ZSH_THEME_GIT_PROMPT_DIRTY=" %F{#E36464}✗%f" # Optional: red X if files are changed
ZSH_THEME_GIT_PROMPT_CLEAN=""

# Main Prompt
# %n = username
# %~ = current path
# %(?:...) = conditional for last command status (success/fail)
PROMPT='%F{#E36464}@%n%f %F{#56B6C2}%~%f$(git_prompt_info) %F{#DCB977}!%f '

# Use a subtle gray or a dim version of your theme's cyan (#56B6C2)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#5c6370,underline"
