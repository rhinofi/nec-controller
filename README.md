# Nectar Controller Upgrade

This repository contains an upgrade to the 'Controller' contract for the Nectar token.

This is an extension of the original Nectar token design at https://github.com/ethfinex/nectar

The upgrade:

1. Removes permanently the whitelist of addresses used to limit ownership to those who had completed KYC during the genesis of Nectar token on Ethfinex
2. Allows tokens to be burned by any contract or token holder, which will be used by the DeversiFi NEC Auctions, where a part of fees generated on DeversiFi will be used to buy NEC and destroy it.
3. Will allow the token controller's owner to be transferred to the recently launched necDAO. All future upgrades will then be initiated by the DAO.

Learn more at https://nectar.community/whitepaper

### Install & Test

`yarn`

`ganache-cli`

`yarn test`

Code coverage results can be seen using `open ./coverage/index.html` and can be refreshed by running `yarn coverage`
