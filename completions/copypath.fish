complete --command copypath --no-files
complete --command copypath --condition 'test (count (commandline --tokenize --cut-at-cursor --current-process)) -eq 1' --force-files
