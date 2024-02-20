// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from 'solady/src/tokens/ERC20.sol';

contract WrappedGas404 is ERC20 {
    ERC20 public Gas404;

    /// @dev Emitted when `amount` is deposited from `from`.
    event Deposit(address indexed from, uint256 amount);

    /// @dev Emitted when `amount` is withdrawn to `to`.
    event Withdrawal(address indexed to, uint256 amount);

    constructor(address _Gas404) {
        Gas404 = ERC20(_Gas404);
    }

    /// @dev Returns the name of the token.
    function name() public view virtual override returns (string memory) {
        return "Wrapped Gas404";
    }

    /// @dev Returns the symbol of the token.
    function symbol() public view virtual override returns (string memory) {
        return "WOIL";
    }

    function deposit(uint256 amount) external {
        Gas404.transferFrom(msg.sender, address(this), amount);
        _mint(msg.sender, amount);
        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint256 amount) external {
        _burn(msg.sender, amount);
        Gas404.transfer(msg.sender, amount);
        emit Withdrawal(msg.sender, amount);
    }
}
