// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract CHNK is ERC20, ERC20Capped, Ownable, ReentrancyGuard {

  event TransferRef(address indexed sender, address indexed recipient, uint256 amount, uint256 ref);

  /**
   * address _forwarder: The trusted forwarder contract address (WRLD_Forwarder_Polygon contract)
   * address _depositManager: The trusted polygon contract address for bridge deposits
   */

  constructor()
  ERC20("Crypto Chunks", "CHNK")
  ERC20Capped(5000000000 ether) {
  }


  function transferWithRef(address sender, address recipient, uint256 amount, uint256 ref) public returns (bool) {
    _transfer(sender, recipient, amount);
    emit TransferRef(sender, recipient, amount, ref);
    return true;
  }

  function bulkTransferRef(address[] memory recipients, uint256[] memory amounts, uint256[] memory refs) external returns (bool) {
    for (uint i = 0; i < recipients.length; i++) {
      transferWithRef(_msgSender(), recipients[i], amounts[i], refs[i]);
    }
  }

  /**
   * Overrides
   */

  function _mint(address to, uint256 amount) internal override(ERC20, ERC20Capped) {
    super._mint(to, amount);
  }

  function mint(address to, uint256 amount) external onlyOwner {
      _mint(to, amount);
  }
}