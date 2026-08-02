complete --command copypath --no-files
complete --command copypath --condition 'test (count (commandline --tokens-expanded --cut-at-cursor)) -eq 1' --force-files
