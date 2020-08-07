# Decentralised voting dApp on Ethereum for universities

## Introduction
The problem of fair and democratic elections is definitely one of the toughest problems faced by the world today. Corruption and distrust everywhere
stand as obstructions to the conduction of such elections. The blockchain technology could definitely help a little in this aspect. Decentralised elections can
fix the issue of trust and guarantee fair elections. However implementing such a solution nationwide is not an easy task considering the presence of people in many
developing countries who are not even familiar with or seen smartphones. NITCVote is a project to tackle a much smaller use case; elections within universities for student representatives. The project is based on Johannes Mols ethVote project and has been enhanced to provide better security and secrecy of votes.

The code for this project is distributed in three repositories:  
[Smart Contracts](https://github.com/farisshajahan/NITCVote)  
[Backend](https://github.com/appu313/NITCVote-backend)  
[Frontend](https://github.com/farisshajahan/NITCVote-react)

## Dependencies
Install these prerequisites to follow along with the tutorial.
- NPM: https://nodejs.org
- Truffle: https://github.com/trufflesuite/truffle
- Ganache: http://truffleframework.com/ganache/
- Metamask: https://metamask.io/
- Geth (for a private ethereum chain deployment)

## Step 1. Clone the project
`git clone https://github.com/farisshajahan/NITCVote`

## Step 2. Install dependencies
```
$ cd election
$ npm install
```
## Step 3. Start Ganache / Geth node
Open the Ganache GUI client that you downloaded and installed. This will start your local blockchain instance.
Alternatively run your own Geth node for a production setup.

## Step 4. Compile & Deploy Election Smart Contract
`$ truffle migrate --reset`
You must migrate the election smart contract each time you restart ganache.

## Step 5. Configure Metamask
- Unlock Metamask
- Connect metamask to your private Etherum blockchain / Ganache
- Import an account from the chain

## Step 6. Front End Application
Visit <https://github.com/farisshajahan/NITCVote-react>

## Step 7. Setup Backend
[Click Here](https://github.com/appu313/NITCVote-backend)
