pragma solidity ^0.5.0;

import "@openzeppelin/contracts/math/SafeMath.sol";

/// @notice NEC Auction Engine
interface Engine {

    function payFeesInEther() external payable;

    function thaw() external;

    function getPriceWindow() external view returns (uint window);

    function percentageMultiplier() external view returns (uint);

    function enginePrice() external view returns (uint);

    function ethPayoutForNecAmount(uint necAmount) external view returns (uint);

    function sellAndBurnNec(uint necAmount) external;

    function getNextPriceChange() external view returns (
        uint newPrice,
        uint nextChangeTimeSeconds );

    function getNextAuction() external view returns (
        uint nextStartTimeSeconds,
        uint predictedEthAvailable,
        uint predictedStartingPrice
        );


}
