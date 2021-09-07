#!/usr/bin/env ruby

# make git-hooks 'executables'
system("chmod +x hooks/*")
# copy-and-paste git-hooks
system("cp -a ./hooks/. ./.git/hooks/")