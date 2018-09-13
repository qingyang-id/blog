idString="QmZ7rMjJTZNhGyF3kLNRcuDVr2DSnepjQNjPDEmkbh1wcC"
str="ID\": \""
subIdStr=${idString#*$str}
str1="\","
subIdStr1=${subIdStr%%$str1*}
echo $subIdStr1
sed -i "" "/root: / s/\/ipns\/$subIdStr1\//\//" _config.yml
sed -i "" "/url: / s/http:\/\/ipfs.io\/ipns\/$subIdStr1/http:\/\/yqsailor.github.io/" _config.yml
hexo clean
hexo g -d
sed -i "" "/root: / s/\//\/ipns\/${subIdStr1}\//" _config.yml
sed -i "" "/url: / s/http:\/\/yqsailor.github.io/http:\/\/ipfs.io\/ipns\/${subIdStr1}/" _config.yml
hexo clean
hexo g
string=`ipfs add -r public/`
subStr=${string##*added }
subStr1=${subStr% public}
ipfs name publish $subStr1