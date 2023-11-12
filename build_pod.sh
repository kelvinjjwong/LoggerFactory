if [[ "$1" = "help" ]] || [[ "$1" = "--help" ]]  || [[ "$1" = "--?" ]]; then
   echo "Sample:"
   echo "./build_pod.sh"
   echo "./build_pod.sh version up"
   echo "./build_pod.sh version down"
   echo
   exit 0
fi

versionChange=0
if [[ "$1 $2" = "version up" ]]; then
   versionChange=1
fi

if [[ "$1 $2" = "version down" ]]; then
   versionChange=-1
fi

pod trunk me
if [[ $? -ne 0 ]]; then
  exit -1
fi

PODSPEC=`ls *.podspec | awk -F' ' '{print $1}' | head -1`

if [[ $versionChange -ne 0 ]]; then
    CURRENT_VERSION=`grep s.version $PODSPEC | head -1 | awk -F' ' '{print $NF}' | sed 's/"//g'`
    if [[ $versionChange -eq 1 ]]; then
        NEW_VERSION=`echo $CURRENT_VERSION | awk -F'.' '{print $1"."$2"."$3+1}'`
    else
        NEW_VERSION=`echo $CURRENT_VERSION | awk -F'.' '{print $1"."$2"."$3-1}'`
    fi
    echo "Current version: $CURRENT_VERSION"
    echo "   Next version: $NEW_VERSION"
    sed -i .bak -e 's/s.version     = ".*"/s.version     = "'$NEW_VERSION'"/' $PODSPEC; rm -f $PODSPEC.bak
    sed -i .bak -e 's/"'$CURRENT_VERSION'"/"'$NEW_VERSION'"/g' -e 's/~> '$CURRENT_VERSION'/~> '$NEW_VERSION'/g' README.md; rm -f README.md.bak
fi

GIT_BRANCH=`git status | grep "On branch" | head -1 | awk -F' ' '{print $NF}'`
CURRENT_VERSION=`grep s.version $PODSPEC | head -1 | awk -F' ' '{print $NF}' | sed 's/"//g'`

if [[ "$GIT_BRANCH" != "$CURRENT_VERSION" ]]; then
    git branch $CURRENT_VERSION
    git checkout $CURRENT_VERSION
fi
git commit -am "build version $CURRENT_VERSION"
if [[ $? -ne 0 ]]; then
   exit -1
fi

git push --set-upstream origin $CURRENT_VERSION
if [[ $? -ne 0 ]]; then
   exit -1
fi

pod spec lint $PODSPEC --allow-warnings
if [[ $? -eq 0 ]]; then
    SOURCE_URL=`grep s.source $PODSPEC | head -1 | awk -F'"' '{print $2}' | sed 's/.\{4\}$//'`
    echo "If success, you can then:"
    echo
    echo "1 # publish new release by tagging new version [$CURRENT_VERSION] in git repository"
    echo "$SOURCE_URL/releases"
    echo ""
    echo "2 # push new version to Cocoapods trunk"
    echo "pod trunk push $PODSPEC"
    echo
fi
