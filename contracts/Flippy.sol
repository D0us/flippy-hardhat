// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

error Flippy__InsufficientWager();
error Flippy__InsufficientContractFunds();
error Flippy_PlayerAlreadyInGame();
error Flippy__TransferFailed();

contract Flippy {
    enum CoinFace {
        HEADS,
        TAILS
    } // uint256 0 = HEADS, 1 = TAILS

    /* state vars */
    uint256 private immutable i_minimumBalance;
    uint256 private immutable i_fee;

    /* Use maps as we plan on letting players verse eachother later on */
    mapping(address => uint256) private s_playersToBalances;
    mapping(address => CoinFace) private s_playersToCoinFaceSelection;

    event CoinFlipped(address indexed player, uint256 wager, CoinFace faceSelected, CoinFace faceFlipped, uint256 prize);

    constructor(uint256 minimumWager, uint256 fee) {
        i_minimumBalance = minimumWager;
        i_fee = fee;
    }

    /**
     */
    function flipCoin(CoinFace playerCoinFaceSelection) public payable {
        if (msg.value < i_minimumBalance) {
            revert Flippy__InsufficientWager();
        }
        if ((msg.value * 2) > address(this).balance) {
            revert Flippy__InsufficientContractFunds();
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
        } else {
            emit CoinFlipped(playerAddress, wager, playerCoinFaceSelection, result, 0);
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
}
