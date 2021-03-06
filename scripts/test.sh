#!/usr/bin/env bash

# Exit script as soon as a command fails.
set -o errexit

# Executes cleanup function at script exit.
trap cleanup EXIT

cleanup() {
# Kill the testrpc instance that we started (if we started one and if it's still running).
if [ -n "$testrpc_pid" ] && ps -p $testrpc_pid > /dev/null; then
    kill -9 $testrpc_pid
fi
}

testrpc_port=8545

testrpc_running() {
    nc -z localhost "$testrpc_port"
}


start_testrpc() {
    # We define 10 accounts with balance 1M ether, needed for high-value tests.
    local accounts=(
        --account="0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501200,1000000000000000000000000"
        --account="0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501201,1000000000000000000000000"
        --account="0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501202,1000000000000000000000000"
        --account="0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501203,1000000000000000000000000"
        --account="0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501204,1000000000000000000000000"
        --account="0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501205,1000000000000000000000000"
        --account="0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501206,1000000000000000000000000"
        --account="0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501207,1000000000000000000000000"
        --account="0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501208,1000000000000000000000000"
        --account="0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501209,1000000000000000000000000"
    )

    if [ "$COVERAGE" = true ]; then
        node --max-old-space-size=8192 node_modules/.bin/testrpc-sc --gasLimit 0xfffffffff --port "$testrpc_port" "${accounts[@]}" > /dev/null &
    else
        node_modules/.bin/ganache-cli -p 9000 --gasLimit 8000000 "${accounts[@]}" > /dev/null &
    fi

    testrpc_pid=$!
}

if testrpc_running; then
    echo "Using existing testrpc instance"
else
    echo "Starting our own testrpc instance"
    start_testrpc
fi

if [ "$COVERAGE" = true ]; then
    node --max_old_space_size=8192 node_modules/.bin/solidity-coverage
    if [ "$CIRCLECI" = true ]; then
        cat coverage/lcov.info | node_modules/.bin/coveralls || echo 'Failed to report coverage to Coveralls'
    fi
else
    node --max-old-space-size=8192 node_modules/.bin/truffle test `find test/*.js`
fi