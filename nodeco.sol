// SPDX-License-Identifier: GPL-3.0

/*
Devloper: bricklerex
Email: aarash.ab@gmail.com
*/

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface ICronaSwapPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

contract Nodes {

    struct Node {
        string nodeName;
        uint timeCreated;
        uint nodeRewardRate;
        uint lastClaimed;
        uint pricePaid;
    }


    address public owner;
    address dev_address;
    bool public paused;
    bool public affiliatePaused;
    bool public extraNodesProgramPaused;
    uint public rewardRateGlobal;
    uint public nodePriceInUSD;
    uint public taxRateGlobal;
    uint public timeLockInDays;
    uint public totalNodes;
    uint public minWithdraw;
    uint public referralRate;
    uint public extraNodeRate;
    address treasuryWallet;
    address marketingWallet;
    address devWallet;
    address[] public buyers;

    //0x873c905681Fb587cc12a29DA5CD3c447bE61F146 Testnet
    //0x5C7F8A570d578ED84E63fdFA7b1eE72dEae1AE23 mainnet
    ERC20 erctoken = ERC20(0x5C7F8A570d578ED84E63fdFA7b1eE72dEae1AE23);

    mapping (address=>Node[]) public balances;
    mapping (address=>uint) public referralNodesCurrent;
    mapping (address=>uint) public referralNodesTotal;
    mapping (address=>uint) public boughtNodesCurrent;


    constructor() {
        owner = msg.sender;
        paused = false;
        affiliatePaused = false;
        extraNodesProgramPaused = false;
        rewardRateGlobal = 3;//3
        nodePriceInUSD = 100;//100
        taxRateGlobal = 10;
        timeLockInDays = 3;//3
        minWithdraw = 1;
        extraNodeRate = 10;//10
        referralRate = 10;//10
        treasuryWallet = 0x9B66E15ACc9f6E194Ad1cf1Ea5f68035aF7bd701;
        marketingWallet = 0x4d334707D731F6F2f1F4C92AAE60d5D20032Bf98;
        devWallet = 0xD683793Ac867f5D4539E498D25ecb4B94c88ea7A;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier notPaused() {
        require(paused == false, "Contract Paused");
        _;
    }

    function getBalanceOf(address user) public view returns (uint){
        return balances[user].length;
    }

    function getReferralNodesCount(address user) public view returns (uint){
        return referralNodesTotal[user];
    }

    function setOwner(address newOwner) onlyOwner public {
        owner = newOwner;
    }

    function togglePaused() onlyOwner public {
        paused = !paused;
    }

    function toggleAffiliatePaused() onlyOwner public {
        affiliatePaused = !affiliatePaused;
    }

    function toggleExtraNodePaused() onlyOwner public {
        extraNodesProgramPaused = !extraNodesProgramPaused;
    }

    function setRewardRate(uint rewardRate) onlyOwner public {
        rewardRateGlobal = rewardRate;
    }

    function setTaxRate(uint taxRate) onlyOwner public {
        taxRateGlobal = taxRate;
    }

    function setNodePriceInUSD(uint nodePrice) onlyOwner public {
        nodePriceInUSD = nodePrice;
    }

    function setMinWithdrawal(uint minReward) onlyOwner public {
        minWithdraw = minReward;
    }

    function setReferralRate(uint newReferralRate) onlyOwner public {
        referralRate = newReferralRate;
    }

    function setExtraNodeRate(uint newRate) onlyOwner public {
        extraNodeRate = newRate;
    }

    function setTimelock(uint timelock) onlyOwner public {
        timeLockInDays = timelock;
    }

    function setMarketingWallet(address newMarketingWallet) onlyOwner public {
        marketingWallet = newMarketingWallet;
    }

    function setTreasuryWallet(address newTreasuryWallet) onlyOwner public {
        treasuryWallet = newTreasuryWallet;
    }

    function getUnclaimedNonTimeLockedRewards(address user) public view returns (uint) {
        Node[] memory allNodes = balances[user];
        uint totalRewards = 0;
        uint daysElapsed;
        uint nodeReward;

        for (uint i = 0; i < allNodes.length; i++) {
            if(block.timestamp > allNodes[i].timeCreated + timeLockInDays * 1 days) {//days
                daysElapsed = (block.timestamp - allNodes[i].lastClaimed)/86400;//86400
                nodeReward = (rewardRateGlobal * nodePriceInUSD * daysElapsed)/100;
                totalRewards = totalRewards + nodeReward;
            }
        }

        return totalRewards;
    }

    function reverse(Node[] storage a) internal returns (bool) {
        Node memory t;
        for (uint i = 0; i < a.length / 2; i++) {
            t = a[i];
            a[i] = a[a.length - i - 1];
            a[a.length - i - 1] = t;
        }
        return true;
    }

    function cancelNodes(address user, uint numNodes) onlyOwner public returns (bool) {
        require(numNodes <= balances[user].length, "You are cancelling more nodes than the user owns");
        reverse(balances[user]);
        
        for(uint i = 0; i < numNodes; i++) {
            balances[user].pop();
            totalNodes--;
        }

        reverse(balances[user]);

        return true;
    }

    function buyNode(string memory nameForNode, address referralAddr) notPaused public returns (bool) {

        uint bal = erctoken.balanceOf(msg.sender);

        uint priceInCRO = getNodePriceInCRO(nodePriceInUSD);

        require(bal >= priceInCRO, "Not enough balance");
        require(erctoken.allowance(msg.sender, address(this)) >= priceInCRO, "Need higher approvals");

        erctoken.transferFrom(msg.sender, treasuryWallet, priceInCRO);

        balances[msg.sender].push(Node({nodeName: nameForNode, timeCreated: block.timestamp, nodeRewardRate: rewardRateGlobal, lastClaimed: block.timestamp, pricePaid: getNodePriceInCRO(nodePriceInUSD)}));

        if(balances[msg.sender].length < 1) {
            buyers.push(msg.sender);
        }
        
        totalNodes = totalNodes + 1;

        if(!affiliatePaused) {
            referralNodesCurrent[referralAddr] = referralNodesCurrent[referralAddr] + 1;
            referralNodesTotal[referralAddr] = referralNodesTotal[referralAddr] + 1;
        }

        if(!extraNodesProgramPaused) {
            referralNodesCurrent[msg.sender] = referralNodesCurrent[msg.sender] + 1;
            referralNodesTotal[msg.sender] = referralNodesTotal[msg.sender] + 1;
        }

        if(!affiliatePaused) {
            while(referralNodesCurrent[referralAddr] >= referralRate) {
                if(balances[referralAddr].length < 1) {
                    buyers.push(referralAddr);
                }

                balances[referralAddr].push(Node({nodeName: nameForNode, timeCreated: block.timestamp, nodeRewardRate: rewardRateGlobal, lastClaimed: block.timestamp, pricePaid: getNodePriceInCRO(nodePriceInUSD)}));
                totalNodes++;
                referralNodesCurrent[referralAddr] = referralNodesCurrent[referralAddr] - referralRate;
            }
        }

        if(!extraNodesProgramPaused) {
            while(referralNodesCurrent[msg.sender] >= extraNodeRate) {
                if(balances[msg.sender].length < 1) {
                    buyers.push(msg.sender);
                }

                balances[msg.sender].push(Node({nodeName: nameForNode, timeCreated: block.timestamp, nodeRewardRate: rewardRateGlobal, lastClaimed: block.timestamp, pricePaid: getNodePriceInCRO(nodePriceInUSD)}));
                totalNodes++;
                referralNodesCurrent[msg.sender] = referralNodesCurrent[msg.sender] - extraNodeRate;
            }
        }

        return true;
    }

    fallback() external payable { revert(); }
    receive() external payable { revert(); }

    function claimRewards() notPaused public returns (bool) {
        uint totalRewards = getNodePriceInCRO(getUnclaimedNonTimeLockedRewards(msg.sender));
        uint taxAmount = totalRewards/10;

        uint devTax = (taxAmount*3)/10;
        uint marketingTax = taxAmount - devTax;

        totalRewards = totalRewards - taxAmount;

        require(totalRewards >= minWithdraw*(10**18), "Less than minimum withdrawal. Please wait until the rewards accumulate more.");

        erctoken.transferFrom(treasuryWallet, msg.sender, totalRewards);
        erctoken.transferFrom(treasuryWallet, marketingWallet, marketingTax);
        erctoken.transferFrom(treasuryWallet, devWallet, devTax);

        Node[] memory allNodes = balances[msg.sender];

        for (uint i = 0; i < allNodes.length; i++) {
            if(block.timestamp > allNodes[i].timeCreated + timeLockInDays * 1 days) {//days
                balances[msg.sender][i].lastClaimed = block.timestamp;
            }
        }

        return true;
    }

    function uintToString(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function concatenate(string memory a,string memory b) public pure returns (string memory){
        return string(abi.encodePacked(a,' ',b));
    }

    function awardNodes(address recv, uint numOfNodes, uint nodeTimeCreated, uint nodeTimeClaimed) onlyOwner public returns (bool) {
        if(balances[recv].length < 1) {
            buyers.push(recv);
        }

        for (uint i = balances[recv].length; i < numOfNodes; i++) {
            balances[recv].push(Node({nodeName: concatenate("Node ", uintToString(i+1)), timeCreated: nodeTimeCreated, nodeRewardRate: rewardRateGlobal, lastClaimed: nodeTimeClaimed, pricePaid: getNodePriceInCRO(nodePriceInUSD)}));
            totalNodes = totalNodes + 1;
        }

        return true;
    }

    function getNodeStats(address sender) public view returns (string memory) {
        string memory obj = "[{";

        Node[] memory allNodes = balances[sender];

        for (uint i = 0; i < allNodes.length; i++) {
            string memory nameString = string(abi.encodePacked("'name'",":","'Node ", uintToString(i+1),"',"));
            string memory timeCreatedString = string(abi.encodePacked("'created'",":", uintToString(allNodes[i].timeCreated),","));
            string memory nodePricePaid = string(abi.encodePacked("'pricePaid'",":", uintToString(allNodes[i].pricePaid), ","));
            string memory lastClaimedString;

            if(allNodes[i].timeCreated == allNodes[i].lastClaimed) {
                lastClaimedString = string(abi.encodePacked("'claimed'",":", "false",","));
            } else {
                lastClaimedString = string(abi.encodePacked("'claimed'",":", uintToString(allNodes[i].lastClaimed),","));
            }

            string memory locked;

            if(block.timestamp >= (allNodes[i].timeCreated + timeLockInDays * 1 days)) {//days
                locked = "false";
            } else {
                locked = "true";
            }

            string memory lockedString = string(abi.encodePacked("'locked'",":","'", locked,"'}"));

            obj = string(abi.encodePacked(obj, nameString, timeCreatedString, nodePricePaid, lastClaimedString, lockedString));

            if(i != allNodes.length-1) {
                obj = string(abi.encodePacked(obj,",{"));
            } else {
                obj = string(abi.encodePacked(obj,"]"));
            }
        }

        return obj;
    }
}