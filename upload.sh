#!/bin/bash
ROOT='http://localhost:5984';
putpage() {
    URL=${ROOT}/static/${1}
    curl -s -X PUT -d '{"root":"index.htm"}' ${URL}
    REV=$(curl -s -X GET ${URL} | jq -r '._rev')
    echo "Overwriting $REV of $URL/index.htm"
    curl -s -X PUT -H "Content-Type: text/html" --data-binary @${2} ${URL}/index.htm?rev=${REV}
}

putstatic() {
    URL=${ROOT}/static/${1}
    if [ $# -eq 3 ]; then
        MIMETYPE="${3}"
    else
        MIMETYPE=$(file --mime-type ${2}|cut -d' ' -f2)
        echo "DETECTED MIMETYPE ${MIMETYPE}"
    fi
    FNAME=$(basename ${2})
    curl -s -X PUT -H "Content-type: $MIMETYPE" --data-binary @${2} ${URL}/${FNAME}
    REV=$(curl -s -X GET ${URL} | jq -r '._rev')
    echo "Overwriting ${REV} of ${URL}/${FNAME} of type $MIMETYPE"
    curl -s -X PUT -H "Content-type: $MIMETYPE" --data-binary @${2} ${URL}/${FNAME}?rev=${REV}
}

putdoc() {
    URL=${ROOT}/${1}
    curl -s -X PUT -H "Content-type: application/json" -d @${2} ${URL}
    REV=$(curl -s -X GET ${URL} | jq -r '._rev')
    echo "Overwriting ${REV} of ${URL}"
    curl -s -X PUT -H "Content-type: application/json" -d @${2} ${URL}?rev=${REV}
}

echo "MAKING DBS"
curl -s -X PUT ${ROOT}/static
curl -s -X PUT ${ROOT}/posts
echo "PUTTING PAGES"
putpage davenport davenport.htm
putstatic davenport prophat.jpg
putstatic davenport sharkBBS.htm
putdoc posts/_design/posts posts.json
putstatic davenport d3.js application/javascript
