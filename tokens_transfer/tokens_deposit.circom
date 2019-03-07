include "./circuits/mimc.circom";
include "./circuits/eddsamimc.circom";
include "./circuits/bitify.circom";

template Main(n) {
    signal input current_state;

    signal private input paths2old_root_to[n-1];
    signal private input paths2new_root_to[n-1];

    signal private input paths2root_to_pos[n-1];
    
    signal private input to;
    signal private input nonce_to;
    signal private input amount;

    signal private input token_balance_to;

    signal private input token_type_to;

    signal output out;

    var i;

    var NONCE_MAX_VALUE = 100;

    // account non-existence check
    component old_hash_to = MultiMiMC7(1,91);
    old_hash_to.in[0] <== 0;

    component old_merkle_to[n-1];
    old_merkle_to[0] = MultiMiMC7(2,91);
    old_merkle_to[0].in[0] <== old_hash_to.out - paths2root_to_pos[0]* (old_hash_to.out - paths2old_root_to[0]);
    old_merkle_to[0].in[1] <== paths2old_root_to[0] - paths2root_to_pos[0]* (paths2old_root_to[0] - old_hash_to.out);
    
    for (i=1; i<n-1; i++){
    	old_merkle_to[i] = MultiMiMC7(2,91);
    	old_merkle_to[i].in[0] <== old_merkle_to[i-1].out - paths2root_to_pos[i]* (old_merkle_to[i-1].out - paths2old_root_to[i]);
    	old_merkle_to[i].in[1] <== paths2old_root_to[i] - paths2root_to_pos[i]* (paths2old_root_to[i] - old_merkle_to[i-1].out);
    }

    current_state === old_merkle_to[n-2].out;

    // balance checks
    token_balance_to + amount >= token_balance_to;
    
    component new_hash_to = MultiMiMC7(4,91);
    new_hash_to.in[0] <== to;
    new_hash_to.in[1] <== token_balance_to+amount;
    new_hash_to.in[2] <== nonce_to;
    new_hash_to.in[3] <== token_type_to;

	component new_merkle_to[n-1];
    new_merkle_to[0] = MultiMiMC7(2,91);
    new_merkle_to[0].in[0] <== new_hash_to.out - paths2root_to_pos[0]* (new_hash_to.out - paths2new_root_to[0]);
    new_merkle_to[0].in[1] <== paths2new_root_to[0] - paths2root_to_pos[0]* (paths2new_root_to[0] - new_hash_to.out);
    
    for (i=1; i<n-1; i++){
    	new_merkle_to[i] = MultiMiMC7(2,91);
    	new_merkle_to[i].in[0] <== new_merkle_to[i-1].out - paths2root_to_pos[i]* (new_merkle_to[i-1].out - paths2new_root_to[i]);
    	new_merkle_to[i].in[1] <== paths2new_root_to[i] - paths2root_to_pos[i]* (paths2new_root_to[i] - new_merkle_to[i-1].out);
    }

    out <== new_merkle_to[n-2].out;

    }

component main = Main(6);