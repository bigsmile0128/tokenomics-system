// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FixedCapTokenSale is Ownable {
    IERC20 public token;
    uint256 public rate; // Number of tokens per ETH
    address public usdc; // USDC token address
    mapping(address => bool) public whitelist;

    event TokensPurchased(address indexed buyer, uint256 amount);
    event Whitelisted(address indexed account, bool isWhitelisted);
    event Withdrawn(address indexed to, uint256 amount);

    constructor(address _token, address _usdc, uint256 _rate) Ownable(msg.sender) {
        require(_token != address(0), "Invalid token address");
        require(_usdc != address(0), "Invalid USDC address");
        require(_rate > 0, "Rate must be greater than 0");

        token = IERC20(_token);
        usdc = _usdc;
        rate = _rate;
    }

    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], "Not whitelisted");
        _;
    }

    function buyTokens() external payable onlyWhitelisted {
        require(msg.value > 0, "Send ETH to buy tokens");

        uint256 tokensToBuy = msg.value * rate;
        require(token.balanceOf(address(this)) >= tokensToBuy, "Not enough tokens in contract");

        token.transfer(msg.sender, tokensToBuy);
        emit TokensPurchased(msg.sender, tokensToBuy);
    }

    function buyWithUSDC(uint256 usdcAmount) external onlyWhitelisted {
        require(usdcAmount > 0, "USDC amount must be greater than 0");

        uint256 tokensToBuy = usdcAmount * rate;
        require(token.balanceOf(address(this)) >= tokensToBuy, "Not enough tokens in contract");

        IERC20(usdc).transferFrom(msg.sender, address(this), usdcAmount);
        token.transfer(msg.sender, tokensToBuy);
        emit TokensPurchased(msg.sender, tokensToBuy);
    }

    function setWhitelist(address _account, bool _status) external onlyOwner {
        whitelist[_account] = _status;
        emit Whitelisted(_account, _status);
    }

    function withdrawFunds(address payable _to) external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        (bool success, ) = _to.call{value: balance}("");
        require(success, "Withdraw failed");

        emit Withdrawn(_to, balance);
    }

    function withdrawTokens(address _to, uint256 amount) external onlyOwner {
        require(token.balanceOf(address(this)) >= amount, "Not enough tokens");

        token.transfer(_to, amount);
        emit Withdrawn(_to, amount);
    }
}
