#My custom functions

# Access to GPT in the CLI. Requires https://github.com/openai/openai-python
gpt() {
    openai api chat_completions.create -m gpt-3.5-turbo -g user "\"$*\""
}

# Create and CD into folder 
function mkcd() {
  mkdir -p "$1" && cd "$1"
}

