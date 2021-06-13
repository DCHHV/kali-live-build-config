# Supported options are (from build.sh):
# -d | --distribution <distro>
# -p | --proposed-updates
# -a | --arch <architecture>
# -v | --verbose
# -D | --debug
# -s | --salt
#      --installer
#      --live
#      --variant <variant>
#      --version <version>
#      --subdir <directory-name>
#      --get-image-path
#      --no-clean
#      --clean
#      --no-firmware
#      --no-installer

BUILD_OPTS_SHORT="d:pa:vDs"
BUILD_OPTS_LONG="distribution:,proposed-updates,arch:,verbose,debug,salt,installer,live,variant:,version:,subdir:,get-image-path,no-clean,clean,no-firmware,no-installer"
