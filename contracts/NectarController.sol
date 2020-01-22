pragma solidity ^0.5.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "./interfaces/INEC.sol";

contract TokenController {

    function proxyPayment(address _owner) public payable returns(bool);

    function onTransfer(address _from, address _to, uint _amount) public returns(bool);

    function onApprove(address _owner, address _spender, uint _amount) public
        returns(bool);

    function onBurn(address payable _owner, uint _amount) public returns(bool);
}


contract NectarController is TokenController, Ownable {
    using SafeMath for uint256;

    INEC public tokenContract;   // The new token for this Campaign


    /// @dev There are several checks to make sure the parameters are acceptable
    /// @param _tokenAddress Address of the token contract this contract controls

    constructor (
        address _tokenAddress
    ) public {
        tokenContract = INEC(_tokenAddress); // The Deployed Token Contract
    }

/////////////////
// TokenController interface
/////////////////

    /// @notice `proxyPayment()` allows the caller to send ether to the Campaign
    /// but does not create tokens. This functions the same as the fallback function.
    /// @param _owner Does not do anything, but preserved because of MiniMe standard function.
    function proxyPayment(address _owner) public payable returns(bool) {
        return true;
    }


    /// @notice Notifies the controller about a transfer.
    /// Transfers can only happen to whitelisted addresses
    /// @param _from The origin of the transfer
    /// @param _to The destination of the transfer
    /// @param _amount The amount of the transfer
    /// @return False if the controller does not authorize the transfer
    function onTransfer(address _from, address _to, uint _amount) public returns(bool) {
        return true;
    }

    /// @notice Notifies the controller about an approval, for this Campaign all
    ///  approvals are allowed by default and no extra notifications are needed
    /// @param _owner The address that calls `approve()`
    /// @param _spender The spender in the `approve()` call
    /// @param _amount The amount in the `approve()` call
    /// @return False if the controller does not authorize the approval
    function onApprove(address _owner, address _spender, uint _amount) public
        returns(bool)
    {
        return true;
    }

    /// @notice Notifies the controller about a burn attempt. Initially all burns are disabled.
    /// Upgraded Controllers in the future will allow token holders to claim the pledged ETH
    /// @param _owner The address that calls `burn()`
    /// @param _tokensToBurn The amount in the `burn()` call
    /// @return False if the controller does not authorize the approval
    function onBurn(address payable _owner, uint _tokensToBurn) public
        returns(bool)
    {
        // This plugin can only be called by the token contract
        require(msg.sender == address(tokenContract));

        require (tokenContract.destroyTokens(_owner, _tokensToBurn));

        return true;
    }

    /// @notice `onlyOwner` can upgrade the controller contract
    /// @param _newControllerAddress The address that will have the token control logic
    function upgradeController(address _newControllerAddress) public onlyOwner {
        tokenContract.changeController(_newControllerAddress);
        emit UpgradedController(_newControllerAddress);
    }

    /// @dev enableBurning - Allows the owner to activate burning on the underlying token contract
    function enableBurning(bool _burningEnabled) public onlyOwner{
        tokenContract.enableBurning(_burningEnabled);
    }


//////////
// Safety Methods
//////////

    /// @notice This method can be used by the owner to extract mistakenly
    ///  sent tokens to this contract.
    /// @param _token The address of the token contract that you want to recover
    function claimTokens(address _token) public onlyOwner {

        INEC token = INEC(_token);
        uint balance = token.balanceOf(address(this));
        token.transfer(owner(), balance);
        emit ClaimedTokens(_token, owner(), balance);
    }

    /// @dev evacuateToVault - This is only used to evacuate remaining to ether from this contract to the vault address
    function claimEther() public onlyOwner{
        address payable to = address(uint160(owner()));
        to.transfer(address(this).balance);
        emit ClaimedTokens(address(0), owner(), address(this).balance);
    }

////////////////
// Events
////////////////

    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
    event UpgradedController (address newAddress);

}
