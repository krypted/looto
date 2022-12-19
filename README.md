# looto
A pair of scripts to find which binaries contain dependencies for libraries and scripts. These leverage the built-in otool and nm binaries on a Mac and recursively loop through all directories scanning for binaries that import specified libraries or symbols into a compiled app. 

- Use looto.sh to look up libraries
- use nm.sh to look up symbols

# Usage

## looto
looto.sh [options: -r] [path] [search_param]

## mn
mn.sh [options: -r] [path] [search_param] [grep_flags]
