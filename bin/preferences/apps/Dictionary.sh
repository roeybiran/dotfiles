#!/bin/bash

# [✓] New Oxford American Dictionary (American English)
# [✓] Oxford American Writer's Thesaurus (American English)
# [✓] Wikipedia
# [✓] Apple Dictionary
# [✓] Hebrew
defaults write 'com.apple.DictionaryServices' DCSActiveDictionaries -array \
'com.apple.dictionary.NOAD' \
'com.apple.dictionary.OAWT' \
'/System/Library/Frameworks/CoreServices.framework/Frameworks/DictionaryServices.framework/Resources/Wikipedia.wikipediadictionary' \
'com.apple.dictionary.AppleDictionary' \
'com.apple.dictionary.he.oup'
