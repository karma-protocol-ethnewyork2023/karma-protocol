// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import './Verifier.sol';

contract Counter {
  mapping(uint256 => uint256) public edges;
  mapping(address => uint256) public nodes;
  mapping(uint256 => address) private nodeToAddr;
  mapping(address => uint256) public balances;

  uint256 private index;
  Groth16Verifier public verifier;

  constructor() {
    index = 1;
    verifier = new Groth16Verifier();
  }

  function connect(address from, address to) public {
    require(from != address(0), "Cannot have null address");
    require(to != address(0), "Cannot have null address");
    require(from != to, "Cannot connect to self");

    if (nodes[from] == 0) {
      register(from);
    }

    if (nodes[to] == 0) {
      register(to);
    }

    uint256 fromId = nodes[from];
    uint256 toId = nodes[to];

    // directional graph.
    edges[fromId] = toId;
  }

  function register(address addr) public {
    require(addr != address(0), "Cannot have null address");
    require(nodes[addr] == 0, "Address already registered");
    nodes[addr] = index;
    nodeToAddr[index] = addr;
    index++;
  }

  function getNodeId(address addr) internal view returns (uint256) {
    return nodes[addr];
  }

  function assertProofInputs(uint256[1] calldata inputs) internal returns(bool) {
    // TODO: Do assertions for inputs and contract state here.
    // Verify (nodes, edges) and inputs for equality check of same graph.
    // Verify recipients and path.
    return true;
  }

  // Needs to be called by contract owner to claim the balance for recipient.
  function reward(uint256[] calldata recipients,
                  uint256[] calldata rewards,
                  uint256[1] calldata inputs,
                  uint256[8] calldata proof) public {
    require(recipients.length != 0, "Cannot have empty recipients");
    require(recipients.length == rewards.length, "Recipients and rewards length mismatch");
    require(assertProofInputs(inputs), "Invalid inputs");
    // gate by proof.
    require(verifier.verifyProof(
      [proof[0], proof[1]],
      [
        [proof[2], proof[3]],
        [proof[4], proof[5]]
      ],
      [proof[6], proof[7]],
      inputs), "Invalid proof");

    for (uint256 i = 0; i < recipients.length; i++) {
      address recipient = nodeToAddr[recipients[i]];
      balances[recipient] += rewards[i];
    }
  }
}
