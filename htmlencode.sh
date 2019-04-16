#!/bin/bash

perl -C -MHTML::Entities -pe 'encode_entities($_);'
