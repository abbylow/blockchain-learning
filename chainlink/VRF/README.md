# Verifiable Random Function (VRF)
In cryptography, a verifiable random function (VRF) is a random number generator (RNG) that generates an output that can be cryptographically verified as random. 

## What Is a Verifiable Random Function (VRF)?
A cryptographic function that takes a series of inputs, computes them, and produces a pseudorandom output, along with a proof of authenticity that can be verified by anyone.

### Inputs and Outputs of VRF
Inputs: a public/private key pair (AKA a verification key and secret key) and a seed 

Although the inputs take in public key, only private key and seed are used to generate a random number. 

Outputs: a random number along with a proof

## Why do we need Chainlink VRF? 
On-chain applications do not have access to a secure RNG due to the deterministic nature of blockchain networks. 

Using on-chain blockhashes as a source of randomness can result in manipulation by blockchain miners/validators who discard blocks with unfavorable hashes and can “re-roll the dice,” changing the RNG value. 

Naive off-chain solutions are opaque and provide no proof that the RNG value produced is legitimate and has not been manipulated by either the data source or oracle node.

Verifiable randomness is essential to many blockchain applications because its tamper-proof unpredictability enables exciting gameplay, rare NFTs, and unbiased outcomes.

## Features of VRF
#### Verifiable
While only the holder of the VRF secret key can compute the hash, anyone with the public key can inspect the proof and verify the correctness of the hash.

#### Random
The output of a VRF is entirely unpredictable (uniformly distributed) to anyone who doesn’t know the seed or private key and follows no pattern. 

#### Function
For a function to be considered a VRF, the RNG must keep the seed hidden (implicit) to preserve its unpredictability, while the proof must be explicit and calculable by everyone (explicit) to ensure its verifiability.


## Benefits of Chainlink VRF
#### Unpredictability
No one can predict the randomness to increase their odds of success because block data is unknown at the time the request is being made.

#### Fairness
Chainlink VRF is fair and unbiased because the random number is based on uniform distribution, meaning that all numbers in the range have an equal chance of being selected.

#### Randomness
Chainlink VRF is provably random because it relies on blockhashes that are unknown ahead of time as the seed for the RNG that is built into the VRF node.

#### Tamper-proof
Chainlink VRF is tamper-proof because no one—not the oracle, external entities, or the development team—can tamper with the RNG process.


## How Chainlink VRF Works


## How to use VRF

## Example 

## Reference
https://chain.link/education-hub/verifiable-random-function-vrf 

https://blog.chain.link/chainlink-vrf-on-chain-verifiable-randomness/ 
