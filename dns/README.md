# Multisignature wallet

Daniil Gentili's submission (@danogentili, <daniil@daniil.it>).

Upgradable multisignature wallet, with custom scripts to deserialize and inspect the contents of BOC files containing TL-B Message constructors, create, sign and verify wallet requests and wallet code upgrades.
All custom data structures used in the wallet can be viewed as a custom TL-B scheme in proto/scheme.tlb (some basic TON constructors are also included for reference).
Most smart contact get-methods (except for the basic seqno and getPartials methods) return an integer, indicating whether the operation was successful and the requested data was found, followed by a cell/integer with the found data (or an empty cell/0 in case of failure).

## Project structure

Fift scripts:
* `lib.fif` - Library with functions to deserialize and inspect contents of TON messages
    The external TL-B Message X object is deserialized, with info printed to stdout.  
    Then, the custom `multiSigWrapper`, `wrappedMessage`, `modeMessage` and `codeMessage` TL-B objects are deserialized, with info printed to stdout.  
    In the case of `modeMessage` (simple message to be sent by wallet once enough signatures are gathered), a the internal Message X object is also unpacked, with info printed to stdout.  
    In the case of `codeMessage`, the new public key dictionary is unpacked an printed to stdout, along with a csr dump of the code slice and other info.  
* `test.fif` - TVM testing platform
    ```
    usage: test.fif <init-message> <message> <func> [ <message2> <func2> ... ]
    ```

    Runs the function with ID <func> in the TON VM, using initial code and storage data from <init-message>.boc and <message>.boc as message (OR as the only integer parameter of get-method, if <message>.boc does not exist).
    The TVM persistent storage is dumped to console and reused after each method call, allowing detailed debugging of smart contracts, with multiple method calls altering the contract's persistent storage.

* `gen-pub.fif` - Generates public/private keypair
    ```
    usage: gen-pub.fif <privkey>
    ```

    Create public key files from private keys; if `<privkey>` doesn't exist, it will be created.  
    Will also print the hex public key ID.

* `wallet-create.fif` - Creates shared wallet
    ```
    usage: wallet-create.fif <workchain-id> <wallet-name> <n> <k> <privkey1> [<pubkey2> ...]
    ```

    Creates a new multisignature wallet in specified workchain composed of `<n>` (1-10) keys.  
    The first of the keys must be a private key (pre-existing or not), used to generate the wallet; the rest MUST be public keys.  

    Min `<k>` (1-10) signatures required to send an order; load `<n>` pre-existing public keys from files `<key1...n>`.

* `wallet-update.fif` - Creates wallet code update request
    ```
    usage: wallet-update.fif <wallet-name> <wallet-update> <seqno> <n> <k> <key-id> <privkey1> [<pubkey2> ...]
    ```

    Updates an existing multisignature wallet.
    The first of the keys must be a private key (with ID `<key-id>`), used to sign the wallet update request saved to `<wallet-update>.boc`; the rest MUST be public keys.
    Create or generate public key files from private keys using gen-pub.fif privkey

    Min `<k>` (1-10) signatures required to send an order; load `<n>` pre-existing public keys from files `<key1...n>`.

* `create.fif` - Creates simple message to be sent to wallet
    ```
    usage: create.fif <filename-base> <key> <key-id> <dest-addr> <seqno> <amount> [-B <body-boc>] [<savefile>]
    ```

    Creates a request to shared wallet created by wallet-create.fif, with private key `<key-id>` loaded from file `<key>.pk` and address from `<filename-base>.addr`, and saves it into `<savefile>.boc` ('wallet-query.boc' by default)

* `sign.fif` - Adds signature to wallet message
    ```
    usage: sign.fif <input> <output> <key> <key-id>
    ```

    Signs multisig `<input>.boc` file with private key `<key-id>` loaded from file `<key>.pk` and writes result to `<output>.boc`

* `verify.fif` - Verifies signature of message against known public key(s)
    ```
    usage: verify.fif <input> <key1> <key1-id> [<key2> <key2-id> ...]
    ```

    Verify multisig `<input>.boc` file with public key `<keyN-id>` loaded from file `<keyN>.pubkey`

* `merge.fif` - Merges multiple messages with same content and different signatures
    ```
    usage: merge.fif <input1> <input2> [<input3> ...] <output>
    ```

    Merges multisig `<inputx>.boc` files and writes result to `<output>.boc`

* `inspect.fif` - Inspects the contents of request
    ```
    usage: inspect.fif <input>
    ```

    Inspects contents of multisig `<input>.boc` file.


FunC code:
* `wallet-code.fc` - Wallet code
* `wallet-code-update.fc` - Wallet code with minor change to test wallet code upgrade

Scripts:
* `test.sh` - Creates wallet, set of signed requests and tests wallet in TON VM
* `test-update.sh` - Tests wallet code upgrade functionality (after `test.sh`) in TON VM

## Testing

The `test.sh` script contains a full set of commands to test every fift script.
You might want to run each command inside `test.sh` separately (there are also multiple comments explaining what each line does in detail), or run `./test.sh | less` to be able to better review the output of each command.

The script starts by creating ten public/private keypairs using `gen-pub.fif`:  
```
for f in {a..j}; do fift -s ../gen-pub.fif $f;done
```

Next, the script creates a constructor message for the shared wallet smart contract using `wallet-create.fif`, creating a `pony-create.boc` file:
```
fift -s ../wallet-create.fif 0 pony 10 10 {a..j} | tee log
```

After extracting the computed wallet address from `log`, the scripts generates an initial wallet request, requesting to send 10 grams to itself (just as a test, saving to `a.boc`).
```
fift -s ../create.fif pony a 0 $address 0 10 a
```

Here, note the `a 0`: to save space, I have chosen to not use the entire ecdh key as key in the signature dictionary.
Instead, a **key ID** is used to distinguish signatures made by certain keys: this is a simple 4-bit value (instead of 256 bits!), equal to the position of the key in the `wallet-create` argument list.
In this case, the `a` key was the first key (`{a..j}` in Bash is shorthand for `a b c .. j`), so the ID is `0`.
What follows is the address, the seqno, the amount of grams and the savefile (`a`) for the query.


Some helper Bash functions are defined:
```
chr() { [ "$1" -lt 256 ] || return 1; printf "\\$(printf '%03o' "$1")"; }
ord() { LC_CTYPE=C printf '%d' "'$1"; }
```

Sign the query using all keys separately, creating eight more boc files, each signed by TWO keys only (key `a` and key `{b..j}`):
```
for f in {1..9}; do fift -s ../sign.fif a $(chr $((97+f))) $(chr $((97+f))) $f;done
```

Merge all queries:
```
fift -s ../merge.fif {a..j} merge
```

Inspect the merged query:
```
fift -s ../inspect.fif merge
```


Finally run the generated files in the VM in the following order

* First init VM with constructor message
* Then load the first file with only one signature by key a (ID 0, method -1)
* Run seqno get-method (method 85143)
* Run getPartialsByKeyId get-method (method 113609)
* Load file with all signatures (and send message, method -1)
* Run getPartialsByKeyId get-method (method 113609)

```
fift -s ../test.fif \
    pony-create \
    a -1 \
    0 85143 \
    0 113609 \
    merge -1 \
    0 113609
```

## Upgrading code

`test-update.sh` should be run after `test.sh`, it executes a similar set of operations:

* The wallet is initialized as before (10 signatures required to send message)
* A simple message is created with only 1 signature (`a`), sending 10 grams to the wallet itself
* This message is sent to the wallet and stored, waiting for further (9 more) signatures
* A **code upgrade** message is created with only 1 signature (`a`): the upgrade sets to 3 the minimum number of required signatures
* This message is sent to the wallet and stored, waiting for further (9 more) signatures
* 9 more signatures (`b-j`) are appended to the **code upgrade** message
* The full **code upgrade** message is sent to the wallet, setting to **3** the minimum number of signatures required to send the message, also modifying the code by adding a new method.
    
    This code upgrade message, however, was signed by all **10** users, so it's really just a simpler way to upgrade a wallet: instead of creating new wallet => moving all funds to new upgraded wallet, a simple code upgrade message is signed.
* 2 more signatures (`b`, `c`) are appended to the **simple** message
* The simple message with additional signatures (`b`, `c`) is sent to the wallet, sending out wallet funds since all **3 required signatures** are gathered.

If we were running on the blockchain, at this point the smart contract code root would be updated to point to the new code, allowing us to use the new `getMagic` (77784) method that returns (420, 69) when called.
Since we're running in a local TVM instance, and fift's `runvm` primitives have no way of returning the output action list (including changes to the code), the code isn't actually updated, but the modified signature list and minSig data structures in the persistent contract storage are indeed returned to the fift stack and re-used for the next TVM method call, allowing us to test the feature.
