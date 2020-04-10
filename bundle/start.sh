#!/usr/bin/env sh

workspace=$(cd $(dirname $0) && pwd -P)
listContainer="docker ps -f network=docker-compose_monitor"
dockerComposeDir="$workspace/docker-compose"

bundle() {
  # bundle
  cd $workspace/example
  find . -type f ! -name "*.tar.gz" | xargs tar -czf rbac.tar.gz
  mv rbac.tar.gz $dockerComposeDir/demo-server
  echo "Rbac files bundled!"

  # discovery
  cd $workspace/discovery
  find . -type f ! -name "*.tar.gz" | xargs tar -czf discovery.tar.gz
  mv discovery.tar.gz $dockerComposeDir/demo-server
  echo "Discovery files bundled!"
}

action="$1"

{
  case $action in
  "start")
    bundle
    cd $dockerComposeDir
    docker-compose -f docker-compose-slim.yaml up -d
    ;;
  "stop")
    cd $dockerComposeDir
    docker-compose -f docker-compose-slim.yaml stop
    ;;
  "start-advance")
    bundle
    cd $dockerComposeDir
    docker-compose -f docker-compose-slim.yaml -f docker-compose-advance.yaml up -d
    ;;
  "stop-advance")
    cd $dockerComposeDir
    docker-compose -f docker-compose-slim.yaml -f docker-compose-advance.yaml stop
    ;;
  "logs")
    [ "$2" == "" ] && echo "Please specify one below container name to see log:\n $($listContainer)" && exit 1
    cId=$(docker ps | grep $2 | cut -d ' ' -f1 | head -n1)
    [ "$cId" != "" ] && docker logs -ft $cId
    ;;
  "decision-log")
    [ "$2" == "" ] && echo "Please provide decision_id" && exit 1
    docker logs golang 2>&1 | grep "$2" --color
    ;;
  "opa-ping")
    echo "Will ping opa-bundle after 3s ..."
    sleep 3
    input="{\"input\": $(cat $workspace/../quick-start/input.json)}"
    curl -s 0.0.0.0:8181/v1/data/rbac/allow -d "$input"
    echo
    curl -s 0.0.0.0:8182/v1/data/rbac/allow -d "$input"
    ;;
  "clean")
    echo "Will clean these container:\n $($listContainer)\n"
    docker rm -f -v $($listContainer -a -q)
    ;;
  *)
    cat <<EOF

Usage:
  slim-version monitor:     start, stop
  advance-version monitor:  start-advance, stop-advance
  container logs:           logs <container name>
  clean all container:      clean
  test opa service:         opa-ping
  query opa decision:       decision-log <decision_id>
EOF
    ;;
  esac
}
