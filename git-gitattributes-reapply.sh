git status
git ls-files > git-ls-files.txt
xargs rm < git-ls-files.txt
xargs git checkout < git-ls-files.txt
git status
