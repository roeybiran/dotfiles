#!/bin/sh

# level
swda setHandler --app "com.apple.TextEdit" --UTI "dyn.ah62d4rv4ge8063xt"            # nfo
swda setHandler --app "com.microsoft.VSCode" --UTI "public.mpeg-2-transport-stream" # ts
swda setHandler --app "com.microsoft.VSCode" --UTI "dyn.ah62d4rv4ge81k652"          # tsx

swda setHandler --app "com.microsoft.VSCode" --UTI "dyn.ah62d4rv4ge8027pb" # lua
swda setHandler --app "com.microsoft.VSCode" --UTI "org.lua.lua"
swda setHandler --app "com.microsoft.VSCode" --UTI "org.lua.lua-source"

swda setHandler --app "com.microsoft.VSCode" --UTI "net.daringfireball.markdown" # markdown
swda setHandler --app "com.microsoft.VSCode" --UTI "dyn.ah62d4rv4ge8043a"        # markdown

swda setHandler --app "com.microsoft.VSCode" --UTI "com.apple.property-list"
swda setHandler --app "com.microsoft.VSCode" --UTI "public.zsh-script"
swda setHandler --app "com.microsoft.VSCode" --UTI "com.netscape.javascript-source"
swda setHandler --app "com.microsoft.VSCode" --UTI "public.bash-script"
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
