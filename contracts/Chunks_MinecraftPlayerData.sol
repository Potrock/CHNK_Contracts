// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract Chunks_MinecraftPlayerData is
    ERC2771Context,
    Ownable,
    ReentrancyGuard
{
    using EnumerableSet for EnumerableSet.AddressSet;
    using ECDSA for bytes32;

    mapping(address => string) public walletToUUID;
    mapping(string => address) private uuidToWallet;
    mapping(string => EnumerableSet.AddressSet) private uuidToSecondaryWallets;
    mapping(string => mapping(address => string)) private playerStats;
    address private authority;

    event PlayerWalletSet(
        string indexed playerUUIDIndex,
        string playerUUID,
        address indexed setWalletAddress
    );
    event PlayerSecondaryWalletSet(
        string indexed playerUUIDIndex,
        string playerUUID,
        address indexed setWalletAddress
    );
    event PlayerSecondaryWalletRemoved(
        string indexed playerUUIDIndex,
        string playerUUID,
        address indexed removedWalletAddress
    );

    constructor(address _forwarder) ERC2771Context(_forwarder) {
        authority = _msgSender();
    }

    function getWalletByUUID(string calldata _playerUUID)
        external
        view
        returns (address)
    {
        string memory lcUUID = _stringToLower(_playerUUID);
        return uuidToWallet[lcUUID];
    }

    function setPlayerPrimaryWallet(string calldata _playerUUID, bytes calldata _signature) public {
        string memory lcPlayerUUID = _stringToLower(_playerUUID);

        require(_isSignedByServer(keccak256(abi.encode(_msgSender(), lcPlayerUUID)), _signature), "Unauthorized Mapping");

        require(bytes(walletToUUID[_msgSender()]).length == 0, "Wallet already assigned");

        walletToUUID[uuidToWallet[lcPlayerUUID]] = "";

        walletToUUID[_msgSender()] = lcPlayerUUID;
        uuidToWallet[lcPlayerUUID] = _msgSender();

        emit PlayerWalletSet(lcPlayerUUID, lcPlayerUUID, _msgSender());
    }

    /**
     * Utils
     */

    function _stringToLower(string memory _base)
        internal
        pure
        returns (string memory)
    {
        bytes memory _baseBytes = bytes(_base);

        for (uint256 i = 0; i < _baseBytes.length; i++) {
            _baseBytes[i] = (_baseBytes[i] >= 0x41 && _baseBytes[i] <= 0x5A)
                ? bytes1(uint8(_baseBytes[i]) + 32)
                : _baseBytes[i];
        }

        return string(_baseBytes);
    }

    /**
     * Auth
     */

    function _isSignedByServer(bytes32 hash, bytes calldata signature)
        internal
        view
        returns (bool)
    {
        return hash.toEthSignedMessageHash().recover(signature) == authority;
    }

    /**
    * Team
    */
    function setAuthority(address _authority) external onlyOwner {
      require(_authority != address(0), "Invalid Authority");
      authority = _authority;
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
}
