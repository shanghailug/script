#!/usr/bin/env bash

# avoid cross day boundary
export TZ=GMT

Q=$((($(date +%-m)-1)/3+1))

RES_REPO=$HOME/proj/doc/res`date +%Y`q$Q
WEB_REPO=$HOME/proj/doc/shanghailug.github.io
DIR=$(dirname $(readlink -f "$0"))

RES_REMOTE="/res`date +%Y`q$Q"

confirm () {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure?} [Y/n] " response
    case $response in
        [nN][oO]|[nN])
            false
            ;;
        *)
            true
            ;;
    esac
}

fmt() {
  y=`date +%-y`
  m=`date +%-m`
  d=`date +%d`
  t="0123456789abcdefghijklmnopqrstuvwxyz"
  echo "${t:$y:1}${t:$m:1}$d"
}

for i in "$@"; do
  echo "publish $i"
done
confirm "continue " || exit

dir="`fmt`.h4"

dst="$RES_REPO/$dir"

mkdir -p "$dst"

echo "copy images to '$dst'"

cp "$@" "$dst"

cd "$dst"

trans() {
    a=${1%.jpg}
    b=${a%.JPG}
    echo "${b}.1920p.jpg"
}

for i in "$@"; do
    c=`trans $i`
    echo "$i -> $c"
    $DIR/jpg_1920p_1000k.sh "$i"
done

git add *.JPG
git add *.jpg

git commit -a -m "Add photos for Hacking Thursday Night of $(date +%F)"

confirm "push to remote" || exit

git push

echo "------ now do post ---------"

prefix=`date +%Y-%m-%d`
post_file="$WEB_REPO/_posts/${prefix}-h4-photo.markdown"

echo "---
layout: post
title:  \"今晚Hacking Thursday Night活动照片\"
date:   $(date '+%F %H:%M:%S %z')
categories: h4
---
" > $post_file

for i in $@; do
  j=`trans $i`
  echo "[<img src='$RES_REMOTE/$dir/$j' style='margin:10px'>]($RES_REMOTE/$dir/$i)" \
    >> $post_file
done


echo "
有关Hacking Thursday活动的介绍：
http://www.shlug.org/about/#hacking-thursday

SHLUG的新浪微博地址：http://weibo.com/shanghailug 有每次活动照片以及信息发布

" >> $post_file

echo "$post_file"
echo ">>>>>>>>>>>>>"

cat $post_file

confirm "post " || exit

cd "$WEB_REPO"

git add "$post_file"
git commit -m "Post H4 photos for `date +%F`"

git push
