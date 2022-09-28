#!/bin/bash

# Antes de rodar, conceder permissão de execução:
# chmod 755 prepare_build.sh

function build() {
    echo  '🏗 - BUILDING'
    cd ./example
    flutter build web --base-href "/alphabet-search-view/"
    cd ../
    echo  '\n✅ BUILD SUCCESSFULLY'
}
function updateGhPages() {
    echo  '\n🔄 - UPDATING GH-PAGES'
    cd ../
    git clone --branch gh-pages https://github.com/ericferreira1992/alphabet-search-view.git alphabet_search_view_dist
    cp -r alphabet-search-view/example/build/web/* alphabet_search_view_dist
    echo  '\n✅ UPDATE SUCCESSFULLY'
}
function deployToGhPages() {
    echo  '\n🚀 - DEPLOYING GH-PAGES'
    cd alphabet_search_view_dist
    git add .
    git commit -m "chore: deploy to Gihub Pages"
    git push origin gh-pages
    echo  '\n✅ DEPLOY SUCCESSFULLY'
}

build
updateGhPages
deployToGhPages