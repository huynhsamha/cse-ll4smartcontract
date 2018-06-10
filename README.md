# Linear Logic for Smart Contract (ll4smartcontract)


Assignment for Mathematic Model at HCM University of Technology.

## Report
You can see my team report [here](https://github.com/huynhsamha/cse-ll4smartcontract/blob/master/Report/main.pdf).


## Smart contract with Solidity

My team use [Solidity](https://github.com/ethereum/solidity) language in [Ethereum](https://www.ethereum.org/) to implement smart contract. The contract run on [Remix](https://remix.ethereum.org), web browser allow to write Solidity smart contract, deploy and run on Ethereum network (or Test net).

### Solidity, Ethereum and Remix?
#### What is Solidity?
> Solidity is a contract-oriented, high-level language for implementing smart contracts. It was influenced by C++, Python and JavaScript and is designed to target the Ethereum Virtual Machine (EVM). Solidity is statically typed, supports inheritance, libraries and complex user-defined types among other features.

#### What is Ethereum?
> Ethereum is an open software platform based on blockchain technology that enables developers to build and deploy decentralized applications (dApp)

#### What is Remix?
> Remix, previously known as Browser Solidity, is a web browser based IDE that allows you to write Solidity smart contracts, then deploy and run the smart contract. 

> You can run Remix from your web browser by navigating to [https://ethereum.github.io/browser-solidity/](https://ethereum.github.io/browser-solidity/), or by installing and running in on your local computer.

### Implementation
We implemented contract [`Transport`](https://github.com/huynhsamha/cse-ll4smartcontract/blob/master/Solidity/Transport.sol) using other contract [`DateTime`](https://github.com/huynhsamha/cse-ll4smartcontract/blob/master/Solidity/DateTime.sol), which is open source contract on Ethereum network (you can see api [here](https://github.com/pipermerriam/ethereum-datetime)).


You can open [https://remix.ethereum.org/](https://remix.ethereum.org/), add our contracts, compile, run and deploy contracts on Test-Net, with JavaScript Virtual Machine (choose option JavaScript VM on `Run`).


### Snapshot
The following is snapshots for the demo.

<img src="/Report/snapshot/1.png"/>
