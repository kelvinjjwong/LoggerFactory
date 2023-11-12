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
PREV_VERSION=`grep s.version $PODSPEC | head -1 | awk -F' ' '{print $NF}' | sed 's/"//g'`

if [[ $versionChange -ne 0 ]]; then
    if [[ $versionChange -eq 1 ]]; then
        NEW_VERSION=`echo $PREV_VERSION | awk -F'.' '{print $1"."$2"."$3+1}'`
    else
        NEW_VERSION=`echo $PREV_VERSION | awk -F'.' '{print $1"."$2"."$3-1}'`
    fi
    echo "Current version: $PREV_VERSION"
    echo "   Next version: $NEW_VERSION"
    sed -i .bak -e 's/s.version     = ".*"/s.version     = "'$NEW_VERSION'"/' $PODSPEC; rm -f $PODSPEC.bak
    sed -i .bak -e 's/"'$PREV_VERSION'"/"'$NEW_VERSION'"/g' -e 's/~> '$PREV_VERSION'/~> '$NEW_VERSION'/g' README.md; rm -f README.md.bak
fi

GIT_BRANCH=`git status | grep "On branch" | head -1 | awk -F' ' '{print $NF}'`
CURRENT_VERSION=`grep s.version $PODSPEC | head -1 | awk -F' ' '{print $NF}' | sed 's/"//g'`

if [[ "$GIT_BRANCH" != "$CURRENT_VERSION" ]]; then
    git branch $CURRENT_VERSION
    git checkout $CURRENT_VERSION
fi
git commit -am "build version $CURRENT_VERSION"
if [[ $? -eq 0 ]]; then
    git push --set-upstream origin $CURRENT_VERSION
    if [[ $? -ne 0 ]]; then
       exit -1
    fi
fi

pod spec lint $PODSPEC --allow-warnings
if [[ $? -ne 0 ]]; then
    exit -1
fi

GH=`which gh`
if [[ "$GH" != "" ]]; then
    gh pr status
    gh pr create --title "$CURRENT_VERSION" --body "**Full Changelog**: https://github.com/kelvinjjwong/LoggerFactory/compare/$PREV_VERSION...$CURRENT_VERSION"
    gh pr list
    GH_PR=`gh pr list | tail -1 | tr '#' ' ' | awk -F' ' '{print $1}'`
    gh pr merge $GH_PR -m
    if [[ $? -ne 0 ]]; then
        exit -1
    fi
    gh pr status
    git pull
    git checkout master
    git pull
    gh release create $CURRENT_VERSION --generate-notes
    if [[ $? -ne 0 ]]; then
        exit -1
    fi
    pod trunk push $PODSPEC
else
    SOURCE_URL=`grep s.source $PODSPEC | head -1 | awk -F'"' '{print $2}' | sed 's/.\{4\}$//'`
    echo "If success, you can then:"
    echo
    echo "1 # publish new release by tagging new version [$CURRENT_VERSION] in git repository"
    echo "$SOURCE_URL/releases"
    echo "with auto markdown release note"
    echo "**Full Changelog**: $SOURCE_URL/compare/$PREV_VERSION...$CURRENT_VERSION"
    echo ""
    echo "2 # push new version to Cocoapods trunk"
    echo "pod trunk push $PODSPEC"
    echo
    echo "OR install GitHub CLI to automate these steps:"
    echo "brew install gh"
    echo "https://cli.github.com"
    echo
fi
