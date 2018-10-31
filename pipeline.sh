build(){
    pushd ./src/votingapp
    ./deps.sh
    rm -rf ./deploy

    if go build -o ./deploy/votingapp; then
        cp -r ui ./deploy
    else 
        return 1
    fi
    popd
}

run(){
    app='votingapp'
    pushd ./src/$app
    pid=$(ps | grep $app | awk '{ print $1 }' | head -1)
    kill -9 $pid
    ./deploy/$app &
    popd
}

test(){
    http_client(){
        curl --url 'http://localhost:8080/vote' \
        --request $1 \
        --data "$2" \
        --header 'Content-Type: application/json' \
        --silent
    }
   
   topics='{"topics":["bash","python","go"]}'
   expectedWinner='bash'
   
   http_client POST $topics
    echo ""
   for option in bash bash bash python
   do
    #http_client PUT '{"topics":"'$option'"}'
     http_client PUT '{"topic":"'$option'"}'
     echo ""
   done

   winner=$(http_client DELETE | jq -r '.winner')
   echo ""
   echo "Winner is $winner"

    #????
    echo "Given voting topics $topics, When vote for $options, Then winner is $expectedWinner"

    if [ "$expectedWinner" = "$winner" ]; then
        return 0   
    else
        return 1
    fi
}

if build > log 2> error; then
    echo $(pwd)
    echo "Build Completed"
    run
    if test; then
        echo "Test suceeded"
    else
        echo "Test Failed"
    fi
else
    echo "FAILED"
fi