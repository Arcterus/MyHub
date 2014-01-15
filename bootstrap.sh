#!/bin/sh

git update-index --assume-unchanged include/MHClientSecret.h
git submodule update --init --recursive
