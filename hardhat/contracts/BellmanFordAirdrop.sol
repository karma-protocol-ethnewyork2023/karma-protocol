// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { AxiomV2Client } from './AxiomV2Client.sol';
import './Verifier.sol';

contract BFAirdropAxiom is AxiomV2Client {
  mapping(uint256 => mapping(uint256 => uint256)) public edges;
  mapping(address => uint256) public nodes; // addr to nodes
  mapping(uint256 => address) public nodeToAddr;
  mapping(address => uint256) public balances;
  uint32[] public edgesSrc;
  uint32[] public edgesDst;

  uint256 private index;
  Groth16Verifier public verifier;
  uint64 public callbackSourceChainId;
  bytes32 public axiomCallbackQuerySchema;

  constructor(
    address _axiomV2QueryAddress,
    uint64 _callbackSourceChainId,
    bytes32 _axiomCallbackQuerySchema
  ) AxiomV2Client(_axiomV2QueryAddress) {
    callbackSourceChainId = _callbackSourceChainId;
    axiomCallbackQuerySchema = _axiomCallbackQuerySchema;
    index = 1;
    verifier = new Groth16Verifier();
  }

  function _axiomV2Callback(
    uint64 sourceChainId,
    address callerAddr,
    bytes32 querySchema,
    bytes32 queryHash,
    bytes32[] calldata axiomResults,
    bytes calldata callbackExtraData
  ) internal virtual override {

    if (nodes[callerAddr] == 0) {
      register(callerAddr);
    }

    // Parse results
    bytes32 eventSchema = axiomResults[0];
    uint256 srcId = uint256(axiomResults[1]);
    uint256 dstId = uint256(axiomResults[2]);
    uint256 recpient1 = uint256(axiomResults[3]);
    uint256 recpient2 = uint256(axiomResults[4]);
    uint256 recpient3 = uint256(axiomResults[5]);

    linkEdges(srcId, dstId);

    uint256[3] memory recipients = [recpient1, recpient2, recpient3];

    reward(srcId, dstId, recipients);
  }

  function _validateAxiomV2Call(
    uint64 sourceChainId,
    address callerAddr,
    bytes32 querySchema
  ) internal virtual override {
    require(sourceChainId == callbackSourceChainId, "AxiomV2: caller sourceChainId mismatch");
    require(querySchema == axiomCallbackQuerySchema, "AxiomV2: query schema mismatch");
  }

  function linkEdges(uint256 src, uint256 dst) internal {
    edges[src][dst] = 1;
    edges[dst][src] = 1;
  }

  function connect(
    address from,
    address to,
    uint256[3] calldata recipients,
    uint256[1] calldata inputs,
    uint256[8] calldata proof) public {
    require(from != to, "Cannot connect to self");
    require(nodes[from] != 0, "From address not registered");
    require(nodes[to] != 0, "To address not registered");
    require(verifier.verifyProof(
      [proof[0], proof[1]],
      [
        [proof[2], proof[3]],
        [proof[4], proof[5]]
      ],
      [proof[6], proof[7]],
      inputs), "Invalid proof");

    uint256 fromId = nodes[from];
    uint256 toId = nodes[to];

    linkEdges(fromId, toId);
    reward(fromId, toId, recipients);
  }

  function register(address addr) public {
    require(addr != address(0), "Cannot have null address");
    require(nodes[addr] == 0, "Address already registered");
    nodes[addr] = index;
    nodeToAddr[index] = addr;
    index++;
  }

  function reward(uint256 src,
                  uint256 dst,
                  uint256[3] memory recipients) internal {
    for (uint256 i = 0; i < recipients.length; i++) {
      if (nodeToAddr[recipients[i]] != address(0)) {
        address recipient = nodeToAddr[recipients[i]];
        balances[recipient] += 1;
      }
    }
    balances[nodeToAddr[src]] += 1;
    balances[nodeToAddr[dst]] += 1;
  }
}

contract BFAirdrop {
  mapping(uint256 => mapping(uint256 => uint256)) public edges;
  mapping(address => uint256) public nodes; // addr to nodes
  mapping(uint256 => address) public nodeToAddr;
  mapping(address => uint256) public balances;
  uint32[] public edgesSrc;
  uint32[] public edgesDst;

  uint256 private index;
  Groth16Verifier public verifier;

  constructor() {
    index = 1;
    verifier = new Groth16Verifier();
  }

  function linkEdges(uint256 src, uint256 dst) internal {
    edges[src][dst] = 1;
    edges[dst][src] = 1;
  }

  function connect(
    address from,
    address to,
    uint256[3] calldata recipients,
    uint256[1] calldata inputs,
    uint256[8] calldata proof) public {
    require(from != to, "Cannot connect to self");
    require(nodes[from] != 0, "From address not registered");
    require(nodes[to] != 0, "To address not registered");
    require(verifier.verifyProof(
      [proof[0], proof[1]],
      [
        [proof[2], proof[3]],
        [proof[4], proof[5]]
      ],
      [proof[6], proof[7]],
      inputs), "Invalid proof");

    uint256 fromId = nodes[from];
    uint256 toId = nodes[to];

    linkEdges(fromId, toId);
    reward(fromId, toId, recipients);
  }

  function register(address addr) public {
    require(addr != address(0), "Cannot have null address");
    require(nodes[addr] == 0, "Address already registered");
    nodes[addr] = index;
    nodeToAddr[index] = addr;
    index++;
  }

  function reward(uint256 src,
                  uint256 dst,
                  uint256[3] memory recipients) internal {
    for (uint256 i = 0; i < recipients.length; i++) {
      if (nodeToAddr[recipients[i]] != address(0)) {
        address recipient = nodeToAddr[recipients[i]];
        balances[recipient] += 1;
      }
    }
    balances[nodeToAddr[src]] += 1;
    balances[nodeToAddr[dst]] += 1;
  }
}
