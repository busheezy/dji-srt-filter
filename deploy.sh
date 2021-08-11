#!/usr/bin/env sh

set -e

# build
npm run build

cd dist

git init
git add -A
git commit -m 'deploy'

git push -f git@github.com:busheezy/dji-srt-filter.git master:gh-pages

cd -