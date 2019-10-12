# Multisignature wallet

Daniil Gentili's submission (@danogentili, <daniil@daniil.it>).

Project structure:

Fift scripts:
* `gen-pub.fif` - Generates public/private keypair
* `wallet-create.fif` - Creates shared wallet
* `wallet-create.fif` - Creates wallet code update request
* `create.fif` - Creates simple message to be sent to wallet
* `sign.fif` - Adds signature to wallet message
* `verify.fif` - Verifies signature of message against known public key
* `merge.fif` - Merges multiple messages with same content and different signatures
* `inspect.fif` - Inspects the contents of request
* `lib.fif` - Library with functions to deserialize and inspect contents of TON messages

FunC code:
* `wallet-code.fc` - Wallet code
* `wallet-code-update.fc` - Wallet code with minor change to test wallet code upgrade

Scripts:
* `test.sh` - Creates wallet, set of signed requests and tests wallet in TON VM
* `test-update.sh` - Tests wallet code upgrade functionality (after `test.sh`) in TON VM

## Testing

The `test.sh` scripts contains a full set of commands to test every script.
```
usage: fift -s wallet/wallet-create.fif <workchain-id> <wallet-name> <n> <k> <privkey1> [<pubkey2> ...]
```

Creates a new multisignature wallet in specified workchain composed of <n> (1-10) keys.  
The first of the keys must be a private key (pre-existing or not), used to generate the wallet; the rest MUST be public keys.  

Min <k> (1-10) signatures required to send an order; load <n> pre-existing public keys from files <key1...n>.


```
usage: gen-pub.fif <privkey>
```

Create public key files from private keys; if <privkey> doesn't exist, it will be created.
Will also print the hex public key ID.

* `inspect
Upgradable multisignature wallet.
Included signature verification scripts to avoid problems with eventual preloaded orders with invalid signatures.

Code can be upgraded via a special multisignature message.

```
```