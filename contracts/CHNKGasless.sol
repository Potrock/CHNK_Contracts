// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";

contract CHNKGasless is ERC2771Context, ERC20, ERC20Capped, Ownable, ReentrancyGuard {
    event TransferRef(
        address indexed sender,
        address indexed recipient,
        uint256 amount,
        uint256 ref
    );

    /**
     * address _forwarder: The trusted forwarder contract address
     */

    address public childChainManagerProxy;

    constructor(address _forwarder, address _childChainManagerProxy)
        ERC20("Crypto Chunks", "CHNK")
        ERC20Capped(5000000000 ether)
        ERC2771Context(_forwarder)
    {
        childChainManagerProxy = _childChainManagerProxy;
        _mint(_msgSender(), 5000000000 ether);
    }

    function transferWithRef(
        address sender,
        address recipient,
        uint256 amount,
        uint256 ref
    ) public returns (bool) {
        _transfer(sender, recipient, amount);
        emit TransferRef(sender, recipient, amount, ref);
        return true;
    }

    function bulkTransferRef(
        address[] memory recipients,
        uint256[] memory amounts,
        uint256[] memory refs
    ) external returns (bool) {
        for (uint256 i = 0; i < recipients.length; i++) {
            transferWithRef(_msgSender(), recipients[i], amounts[i], refs[i]);
        }
    }

      function mint(address to, uint256 amount) external onlyOwner {
      _mint(to, amount);
  }

    function deposit(address user, bytes calldata depositData) external {
        require(
            _msgSender() == childChainManagerProxy,
            "Address not allowed to deposit."
        );

        uint256 amount = abi.decode(depositData, (uint256));

        _mint(user, amount);
    }

    function withdraw(uint256 amount) external {
        _burn(_msgSender(), amount);
    }

    function updateChildChainManager(address _childChainManagerProxy)
        external
        onlyOwner
    {
        require(
            _childChainManagerProxy != address(0),
            "Bad ChildChainManagerProxy address."
        );

        childChainManagerProxy = _childChainManagerProxy;
    }

    /**
     * Overrides
     */
    function _msgSender()
        internal
        view
        override(Context, ERC2771Context)
        returns (address)
    {
        return super._msgSender();
    }

    function _msgData()
        internal
        view
        override(Context, ERC2771Context)
        returns (bytes calldata)
    {
        return super._msgData();
    }

    function _mint(address to, uint256 amount)
        internal
        override(ERC20, ERC20Capped)
    {
        super._mint(to, amount);
    }
}
