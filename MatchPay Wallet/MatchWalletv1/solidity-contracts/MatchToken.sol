pragma solidity ^0.4.24;

import "./ERC223.sol";
import "./SafeMath.sol";

// change contract name to your contract's name
// i.e. "contract Bitcoin is ERC223Token"
contract MatchToken is ERC223Token {
  using SafeMath for uint256;
  string public name = "MatchPay";
  string public symbol = "MPT";
  // set token's precision
  // pick any number from 0 to 18
  // for example, 4 decimal points means that
  // smallest token using will be 0.0001 TKN
  uint public decimals = 4;
  // total supply of the token
  // for example, for Bitcoin it would be 21000000
  uint public totalSupply = 1000000000 * (10**decimals);

  // Treasure is where ICO funds (ETH/ETC) will be forwarded
  // replace this address with your wallet address!
  // it is recommended that you create a paper wallet for this purpose
  address private treasury = 0x2669c550De4f6C001E7f811D7C04194E2b2d340b;
  
  // ICO price. You will need to do a little bit of math to figure it out
  // given 4 decimals, this setting means "1 ETC = 50,000 TKN"
  uint256 private priceDiv = 2000000000;
  
  event Purchase(address indexed purchaser, uint256 amount);

  constructor() public {
    // This is how many tokens you want to allocate to yourself
    balances[msg.sender] = 850000000 * (10**decimals);
    // This is how many tokens you want to allocate for ICO
    balances[0x0] = 150000000 * (10**decimals);
  }

  function () public payable {
    bytes memory empty;
    if (msg.value == 0) { revert(); }
    uint256 purchasedAmount = msg.value.div(priceDiv);
    if (purchasedAmount == 0) { revert(); } // not enough ETC sent
    if (purchasedAmount > balances[0x0]) { revert(); } // too much ETC sent

    treasury.transfer(msg.value);
    balances[0x0] = balances[0x0].sub(purchasedAmount);
    balances[msg.sender] = balances[msg.sender].add(purchasedAmount);

    emit Transfer(0x0, msg.sender, purchasedAmount);
    emit ERC223Transfer(0x0, msg.sender, purchasedAmount, empty);
    emit Purchase(msg.sender, purchasedAmount);
  }
}
