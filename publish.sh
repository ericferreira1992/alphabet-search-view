#!/bin/bash

# Antes de rodar, conceder permissão de execução:
# chmod 755 prepare_build.sh

function publish() {
    echo  '🏗 - DEPLOYING'
    dart pub publish
    echo  '\n✅ DEPLOY SUCCESSFULLY'
}

publish