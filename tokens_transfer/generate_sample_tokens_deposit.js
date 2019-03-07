const eddsa = require("./src/eddsa.js");
const snarkjs = require("snarkjs");
const fs = require('fs');
const util = require('util');
const mimcjs = require("./src/mimc7.js");

const bigInt = snarkjs.bigInt;

const DEPTH = 6;

//this is the first account, which we don't touch
const prvKey_neighbour = Buffer.from("0000000000000000000000000000000000000000000000000000000000000001", "hex");
const pubKey_neighbour = eddsa.prv2pub(prvKey_neighbour);
const nonce_neighbour = 0;
const token_type_neighbour = 10;
const token_balance_neighbour = 2000;

//we make a deposit to the second account 
const prvKey_to = Buffer.from("0000000000000000000000000000000000000000000000000000000000000002", "hex");
const pubKey_to = eddsa.prv2pub(prvKey_to);
const nonce_to = 0;
const token_type_to = 10;
const token_balance_to = 0;

//amount deposited into second account
const amount = 100;

//hash of neighbour
const hash_leaf_neighbour = mimcjs.multiHash([pubKey_neighbour[0], token_balance_neighbour, nonce_neighbour, token_type_neighbour]);

//old merkle root (before deposit)
var old_merkle = new Array(DEPTH-1);
old_merkle[0] = mimcjs.multiHash([hash_leaf_neighbour,0]);

var i;
for (i = 1; i < DEPTH-1; i++) { 
  old_merkle[i] = mimcjs.multiHash([old_merkle[i-1],0]);
}

console.log("Initial Root")
console.log(old_merkle[DEPTH-2]);

//new hash of second account 
const new_hash_leaf_to = mimcjs.multiHash([pubKey_to[0], token_balance_to+amount, nonce_to, token_type_to]);

//new merkle root (after deposit)
var new_merkle = new Array(DEPTH-1);
new_merkle[0] = mimcjs.multiHash([hash_leaf_neighbour,new_hash_leaf_to]);
var i;
for (i = 1; i < DEPTH-1; i++) { 
  new_merkle[i] = mimcjs.multiHash([new_merkle[i-1],0]);
}

console.log("Updated Root")
console.log(new_merkle[DEPTH-2]);

const inputs = {

    current_state: old_merkle[DEPTH-2].toString(),

    paths2old_root_to: [hash_leaf_neighbour.toString(), 0, 0, 0, 0],
    paths2new_root_to: [hash_leaf_neighbour.toString(), 0, 0, 0, 0],
    paths2root_to_pos: [1, 0, 0, 0, 0],
    
    to: pubKey_to[0].toString(),
    amount: amount.toString(),

    token_type_to:token_type_to.toString()
}

fs.writeFileSync('./input.json', JSON.stringify(inputs) , 'utf-8');