#!/bin/bash

. ./system-tree.sh

symlinck '/etc/apache2'
symlinck '/etc/letsencrypt'
symlinck '/etc/yapbck.conf'
symlinck '/usr/local/bin'
symlinck '/usr/local/src'
