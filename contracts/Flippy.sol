// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "hardhat/console.sol";

error Flippy__InsufficientWager();
error Flippy__InsufficientContractFunds();
error Flippy_PlayerAlreadyInGame();
error Flippy__TransferFailed();
error Flippy__NotOwner();
error Flippy__InsufficientFundsToSatisfyWithdrawal();
error Flippy__OwnerCouldNotWithdraw();

contract Flippy {
    enum CoinFace {
        HEADS,
        TAILS
    } // uint256 0 = HEADS, 1 = TAILS

    struct Game {
        address player;
        uint256 wager;
        CoinFace faceSelected;
        CoinFace faceFlipped;
        uint256 prize;
    }

    /* state vars */
    uint256 private immutable i_minimumBalance;
    address private immutable i_owner;
    Game[] public s_games;
    uint256 private immutable i_feePercentage;

    /* Use maps as we plan on letting players verse eachother later on */
    mapping(address => uint256) private s_playersToBalances;
    mapping(address => CoinFace) private s_playersToCoinFaceSelection;

    event CoinFlipped(address indexed player, uint256 wager, CoinFace faceSelected, CoinFace faceFlipped, uint256 prize);
    event Funded(address fromAddress, uint256 amount);
    event Withdrew(uint256 amount);

    constructor(
        address owner,
        uint256 minimumWager,
        uint256 feePercentage
    ) {
        i_owner = owner;
        i_minimumBalance = minimumWager;
        i_feePercentage = feePercentage;
    }

    /**
     */
    function flipCoin(CoinFace playerCoinFaceSelection) public payable {
        if ((msg.value * 2) > address(this).balance) {
            revert Flippy__InsufficientContractFunds();
        }
        if (msg.value < i_minimumBalance) {
            revert Flippy__InsufficientWager();
        }
        if (isAddressInBalances(msg.sender)) {
            revert Flippy_PlayerAlreadyInGame();
        }

        address playerAddress = payable(msg.sender);
        uint256 wager = msg.value;
        s_playersToCoinFaceSelection[playerAddress] = playerCoinFaceSelection;
        s_playersToBalances[playerAddress] = wager;

        CoinFace result = getFlipResult();
        if (result == playerCoinFaceSelection) {
            uint256 prize = (wager * 2);
            (bool success, ) = playerAddress.call{value: prize}("");
            if (!success) {
                //TODO: If it fails here we gobble up the funds as there is no way to reinitiate the flip
                // Maybe split into into two functins - enter game and flip coin
                revert Flippy__TransferFailed();
            }
            emit CoinFlipped(playerAddress, wager, playerCoinFaceSelection, result, prize);
            s_games.push(Game(playerAddress, wager, playerCoinFaceSelection, result, prize));
        } else {
            emit CoinFlipped(playerAddress, wager, playerCoinFaceSelection, result, 0);
            s_games.push(Game(playerAddress, wager, playerCoinFaceSelection, result, 0));
        }
        delete s_playersToBalances[playerAddress];
        delete s_playersToCoinFaceSelection[playerAddress];
    }

    function getFlipResult() public pure returns (CoinFace) {
        return CoinFace.HEADS;
    }

    /**
     * @dev Check whether a player currently exists in the list of active balances
     *
     */
    function isAddressInBalances(address playerAddress) public view returns (bool) {
        if (s_playersToBalances[playerAddress] > 0) {
            return true;
        }
        return false;
    }

    function getMinimumWager() public view returns (uint256) {
        return i_minimumBalance;
    }

    function getGameCount() public view returns (uint256) {
        return s_games.length;
    }

    function getGame(uint256 index)
        public
        view
        returns (
            address player,
            uint256 wager,
            CoinFace faceSelected,
            CoinFace faceFlipped,
            uint256 prize
        )
    {
        return (s_games[index].player, s_games[index].wager, s_games[index].faceSelected, s_games[index].faceFlipped, s_games[index].prize);
    }

    function fund() public payable {
        emit Funded(msg.sender, msg.value);
    }

    function withdrawAll() public payable onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = msg.sender.call{value: amount}("");
        if (!success) {
            revert Flippy__OwnerCouldNotWithdraw();
        }
        emit Withdrew(amount);
    }

    function withdraw(uint256 amount) public payable onlyOwner {
        if (amount > address(this).balance) {
            revert Flippy__InsufficientFundsToSatisfyWithdrawal();
        }
        (bool success, ) = msg.sender.call{value: amount}("");
        if (!success) {
            revert Flippy__OwnerCouldNotWithdraw();
        }
        emit Withdrew(amount);
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert Flippy__NotOwner();
        }
        _;
    }

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }
}
