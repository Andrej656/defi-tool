// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

contract DeFiLeverage is Ownable {
    using SafeMath for uint256;

    IERC20 public nativeToken;
    IERC721Enumerable public nftToken;
    uint256 public leverageRatio; // e.g., 2x leverage

    mapping(address => uint256) public userDeposits;
    uint256 public totalDeposits;

    mapping(address => bool) public hasClaimedNFT; // To track NFT claiming

    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    event Liquidation(address indexed user, uint256 liquidationAmount);
    event SwapNativeToken(address indexed user, uint256 nativeTokenAmount);
    event GasFeePaid(address indexed user, uint256 gasFeeAmount);
    event InterestAccrued(address indexed user, uint256 interestAmount);
    event NFTClaimed(address indexed user, uint256 tokenId); // Event for NFT claiming

    constructor(IERC20 _nativeToken, IERC721Enumerable _nftToken, uint256 _leverageRatio) {
        nativeToken = _nativeToken;
        nftToken = _nftToken;
        leverageRatio = _leverageRatio;
    }

    function deposit(uint256 depositAmount) external {
        require(depositAmount > 0, "Deposit amount must be greater than 0");

        // Ensure the contract has the allowance to transfer native tokens on behalf of the user
        require(
            nativeToken.transferFrom(msg.sender, address(this), depositAmount),
            "Token transfer failed"
        );

        uint256 leveragedAmount = depositAmount.mul(leverageRatio);

        require(
            nativeToken.balanceOf(address(this)) >= leveragedAmount,
            "Insufficient native token balance"
        );

        userDeposits[msg.sender] = userDeposits[msg.sender].add(depositAmount);
        totalDeposits = totalDeposits.add(depositAmount);

        // Reward the user with an NFT (assuming you have a mintNFT function)
        uint256 tokenId = mintNFT(msg.sender);

        emit Deposit(msg.sender, depositAmount);
        emit NFTClaimed(msg.sender, tokenId);
    }

    function withdraw(uint256 withdrawAmount) external {
        uint256 userDeposit = userDeposits[msg.sender];

        require(userDeposit >= withdrawAmount, "Insufficient balance");

        // Perform necessary checks and calculations for withdrawal
        // ...

        userDeposits[msg.sender] = userDeposit.sub(withdrawAmount);
        totalDeposits = totalDeposits.sub(withdrawAmount);

        // Transfer funds to the user
        require(
            nativeToken.transfer(msg.sender, withdrawAmount),
            "Token transfer failed"
        );

        emit Withdrawal(msg.sender, withdrawAmount);
    }
    function liquidate(address userToLiquidate) external onlyOwner {
    uint256 userDeposit = userDeposits[userToLiquidate];

    require(userDeposit > 0, "No deposits to liquidate");

    // Hypothetical liquidation logic - calculate liquidationAmount
    uint256 liquidationAmount = userDeposit / 2; // For example, liquidate half of the user's deposit

    // Perform liquidation logic, transfer funds to the liquidator, etc.
    // ...

    emit Liquidation(userToLiquidate, liquidationAmount);

    }

    function swapForNativeToken(uint256 amountToSwap) external {
        require(amountToSwap > 0, "Amount to swap must be greater than 0");

        // Perform the swap logic to exchange tokens for nativeToken
        // ...

        emit SwapNativeToken(msg.sender, amountToSwap);
    }

    function payGasFee(uint256 gasFeeAmount) external {
        require(gasFeeAmount > 0, "Gas fee amount must be greater than 0");

        // Deduct gas fee from the user's deposit or balance
        // ...

        emit GasFeePaid(msg.sender, gasFeeAmount);
    }

    function accrueInterest(uint256 interestAmount) external {
        require(interestAmount > 0, "Interest amount must be greater than 0");

        // Add interest to the user's deposit or balance
        // ...

        emit InterestAccrued(msg.sender, interestAmount);
    }

    function claimNFT() external {
    require(!hasClaimedNFT[msg.sender], "NFT already claimed");

    // Implement the NFT claiming logic here
    // For example, mint the NFT to the user
    uint256 tokenId = mintNFT(msg.sender);

    hasClaimedNFT[msg.sender] = true;

    emit NFTClaimed(msg.sender, tokenId); // Provide the tokenId of the claimed NFT
    }

    // Function to update the leverage ratio (onlyOwner)
    function setLeverageRatio(uint256 _newLeverageRatio) external onlyOwner {
        leverageRatio = _newLeverageRatio;
    }

  // Function to mint an NFT (to be implemented)
    function mintNFT(address to) internal returns (uint256) {
    // Implement your NFT minting logic here
    // ...

    // Assuming you mint an NFT and obtain its tokenId somehow
    uint256 tokenId = 123; // Replace with the actual tokenId

    // Emit an event for the minted NFT
    emit NFTClaimed(to, tokenId);

    return tokenId;
}
    }

