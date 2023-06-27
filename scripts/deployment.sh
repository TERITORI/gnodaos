#!/bin/sh

# guide
# https://docs.onbloc.xyz/tutorials/start-writing-a-realm

gnokey add gopher
- addr: g1x2xyqca98auaw9lnat2h9ycd4lx3w0jer9vjmt
stuff visit shoe prevent manage capable atom spell drip thunder cave sea fee visa pipe disease brain bounce left escape wage atom tip because
# creates an address using the existing seed phrase
# gnokey add gopher --recover

GOPHER=g1x2xyqca98auaw9lnat2h9ycd4lx3w0jer9vjmt
# check balance
gnokey query bank/balances/$GOPHER -remote="test3.gno.land:36657"

gnokey maketx addpkg  \
  -deposit="1ugnot" \
  -gas-fee="1ugnot" \
  -gas-wanted="5000000" \
  -broadcast="true" \
  -remote="test3.gno.land:36657" \
  -chainid="test3" \
  -pkgdir="./r/gnodao" \
  -pkgpath="gno.land/r/demo/gnodao_v01" \
  gopher
# https://gnoscan.io/transactions/329084_0