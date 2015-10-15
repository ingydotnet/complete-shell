yaml = require 'js-yaml'
fs = require 'fs'

main = ->
  data = yaml.load fs.readFileSync process.argv[2], "utf8"
  process.stdout.write """
__complete-shell::#{data.cmd}() {
  echo "#{data.sub.join ' '}"
}
"""

main()

# vim: sw=2:
