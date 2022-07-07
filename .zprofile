# Placeholder so that install scripts e.g. SDKMAN do not create this by accident

case "$(uname -s)" in
    Darwin)
        export PATH="$HOME/Library/Application Support/JetBrains/Toolbox/scripts":$PATH
        ;;
    Linux)
        export PATH="$HOME/.local/share/JetBrains/Toolbox/scripts":$PATH
        ;;
esac
