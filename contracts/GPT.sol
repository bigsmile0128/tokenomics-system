// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract DTVTToken is ERC20, AccessControl {
    uint256 public constant MAX_SUPPLY = 850_000_000 * 10**18;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant REGISTRAR_ROLE = keccak256("REGISTRAR_ROLE");

    mapping(bytes32 => bool) private registrationKeys;

    constructor(address admin) ERC20("dtvt", "DTVT") {
        require(admin != address(0), "Invalid admin address");
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _mint(admin, MAX_SUPPLY);
    }

    function addRegistrationKey(bytes32 key) external onlyRole(ADMIN_ROLE) {
        registrationKeys[key] = true;
    }

    function removeRegistrationKey(bytes32 key) external onlyRole(ADMIN_ROLE) {
        registrationKeys[key] = false;
    }

    function isRegistrationKeyValid(bytes32 key) external view returns (bool) {
        return registrationKeys[key];
    }

    function transferWithKey(address recipient, uint256 amount, bytes32 key) external {
        require(registrationKeys[key], "Invalid registration key");
        _transfer(msg.sender, recipient, amount);
    }

    function addRegistrar(address registrar) external onlyRole(ADMIN_ROLE) {
        grantRole(REGISTRAR_ROLE, registrar);
    }

    function removeRegistrar(address registrar) external onlyRole(ADMIN_ROLE) {
        revokeRole(REGISTRAR_ROLE, registrar);
    }
}
