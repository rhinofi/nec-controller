pragma solidity ^0.5.0;

interface INEC {

    function burningEnabled() external returns(bool);

    function controller() external returns(address);

    function enableBurning(bool _burningEnabled) external;

    function burnAndRetrieve(uint256 _tokensToBurn) external returns (bool success);

    function totalPledgedFees() external view returns (uint);

    function totalSupply() external view returns (uint);

    function destroyTokens(address _owner, uint _amount
      ) external returns (bool);

    function generateTokens(address _owner, uint _amount
      ) external returns (bool);

    function changeController(address _newController) external;

    function balanceOf(address owner) external returns(uint256);

    function transfer(address owner, uint amount) external returns(bool);
}
