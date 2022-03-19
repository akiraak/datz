#!/usr/bin/env bash
. env_vars
python3 -m flask db upgrade
python3 -m flask run --host=0.0.0.0
