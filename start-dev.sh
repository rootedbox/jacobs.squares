#!/bin/bash

echo "Starting Jacobs Squares development servers..."
echo "========================================"

trap 'kill $(jobs -p)' EXIT

echo "Starting backend server..."
cd "$(dirname "$0")"
npm run dev &

sleep 2

echo "Starting frontend server..."
cd frontend
npm start &

wait

