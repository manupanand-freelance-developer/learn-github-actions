git add .
echo what was the commit for?
read commit
git commit -m "${commit}"
git push origin main
git status