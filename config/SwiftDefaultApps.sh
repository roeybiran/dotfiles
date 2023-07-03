#!/bin/sh

if ! command -v swda 1>/dev/null; then
	exit
fi

# level
swda setHandler --app "com.microsoft.VSCode" --UTI "public.mpeg-2-transport-stream" # ts
swda setHandler --app "com.microsoft.VSCode" --UTI "public.tsx"                     # tsx

swda setHandler --app "com.microsoft.VSCode" --UTI "public.php-script"     # php
swda setHandler --app "com.microsoft.VSCode" --UTI "org.lua.lua"
swda setHandler --app "com.microsoft.VSCode" --UTI "org.lua.lua-source"

swda setHandler --app "com.uranusjr.macdown" --UTI "net.daringfireball.markdown" # markdown

swda setHandler --app "com.microsoft.VSCode" --UTI "public.zsh-script"
swda setHandler --app "com.microsoft.VSCode" --UTI "com.netscape.javascript-source"
swda setHandler --app "com.microsoft.VSCode" --UTI "public.bash-script"
swda setHandler --app "com.microsoft.VSCode" --UTI "org.bash.source"
swda setHandler --app "com.microsoft.VSCode" --UTI "public.shell-script"
swda setHandler --app "com.microsoft.VSCode" --UTI "public.yaml"
swda setHandler --app "com.microsoft.VSCode" --UTI "public.python-script"
# level
swda setHandler --app "com.microsoft.VSCode" --UTI "public.script"
# level
swda setHandler --app "com.microsoft.VSCode" --UTI "public.css"
swda setHandler --app "com.microsoft.VSCode" --UTI "public.json"
swda setHandler --app "com.microsoft.VSCode" --UTI "public.source-code"
# level

# level
swda setHandler --app "com.microsoft.VSCode" --UTI "public.data"
# level
swda setHandler --app "com.microsoft.VSCode" --UTI "public.item"
# level
swda setHandler --app "com.microsoft.VSCode" --UTI "public.content"
