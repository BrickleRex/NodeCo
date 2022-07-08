# NodeCo
NodeCo is a DeFi nodes platform, that allows users to purchase &quot;nodes&quot;, that represent investments on the user&#39;s behalf. The funds from these nodes are then used to generate returns, which are then returned to the investors, after being taxed. This repository contains the smart contract code used for the platform.

## Functions

* **getBalanceOf(address user)** : Returns the number of nodes owned by a user

* **setOwner(address newOwner)** : Sets the given address as the new owner of the contract

* **setRewardRate(uint rewardRate)** : Sets the return rate per node

* **setTaxRate(uint taxRate)** : Sets the tax rate to be deducted from user withdrawals

* **setNodePriceInUSD(uint nodePrice)** : Sets the price of each node in USDT

 * **setMinWithdrawal(uint minReward)** : Sets the minimum withdrawal by a user

* **setReferralRate(uint newReferralRate)** : Sets the number of nodes required to get a free referral node

* **setExtraNodeRate(uint newRate)** : Sets the number of nodes a user needs to buy to obtain a free node

* **setTimelock(uint timelock)** : Sets the number of days before the user can withdraw their earnings

* **setMarketingWallet(address newMarketingWallet)** : Sets the wallet address that will receive the tax proceeds

* **setTreasuryWallet(address newTreasuryWallet)** : Sets the wallet address that will hold the investments and provide withdrawals for the user

* **getUnclaimedNonTimeLockedRewards(address user)** : Gets the unclaimed rewards/profits for a user

* **reverse(Node[] storage a)** : Utility function to reverse an array of Node instances

* **cancelNodes(address user, uint numNodes)** : Deletes a certain number of nodes belonging to a user

* **buyNode(string memory nameForNode, address referralAddr)** : Function to deduct ERC-20 token (USDT) from user balance, send it to treasury, and append a Node to user&#39;s balances

* **claimRewards()** : Function to transfer ERC-20 token from treasury wallet to user, and make changes to state to reflect new balances

* **uintToString(uint \_i)** : Utility function to convert int to string

* **concatenate(string memory a,string memory b)** : Utility function to concatenate two strings

* **awardNodes(address recv, uint numOfNodes, uint nodeTimeCreated, uint nodeTimeClaimed)** : Function to provide free nodes to a certain wallet, with options to add a specific time for creation of the node. Useful for testing, and upgrades.

* **getNodeStats(address sender)** : Returns a JSON description of the nodes belonging to an address allowing smoother migration to future versions.

* **getReferralNodesCount(address user)** : Returns the number of referrals received by the user that count towards the next free node

* **togglePaused()** : Pauses/Unpauses the contract operations

* **toggleAffiliatePaused()** : Pauses/Unpauses the affiliate system

* **toggleExtraNodePaused()** : Pauses/Unpauses the extra node program

**Disclaimer**

I am not a founder/owner or partner of NodeCo. My task was to design and develop the contract + dapp. Therefore, I am not responsible for any losses incurred by the users of this platform.
```
