#!/bin/sh

f="$HOME/Library/Containers/net.televator.Vimari.SafariExtension/Data/Library/Application Support/userSettings.json"

default='
{
  "excludedUrls": "",
  "linkHintCharacters": "asdfjklqwerzxc",
  "detectByCursorStyle": false,
  "scrollSize": 150,
  "openTabUrl": "about:blank",
  "modifier": "",
  "smoothScroll": true,
  "scrollDuration": 25,
  "transparentBindings": true,
  "bindings": {
      "hintToggle": "f",
      "newTabHintToggle": "shift+f",
      "scrollUp": "k",
      "scrollDown": "j",
      "scrollLeft": "h",
      "scrollRight": "l",
      "scrollUpHalfPage": "u",
      "scrollDownHalfPage": "d",
      "goToPageTop": "g g",
      "goToPageBottom": "shift+g",
      "goToFirstInput": "g i",
      "goBack": "shift+h",
      "goForward": "shift+l",
      "reload": "r",
      "tabForward": "w",
      "tabBack": "q",
      "closeTab": "x",
      "openTab": "t"
  }
}
'

printf "%s\n" "$default" >"$f"
