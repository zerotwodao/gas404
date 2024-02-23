// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {DN404} from "dn404/src/DN404.sol";
import {DN404Mirror} from "dn404/src/DN404Mirror.sol";
import {Ownable} from "solady/src/auth/Ownable.sol";
import {LibString} from "solady/src/utils/LibString.sol";
import {SafeTransferLib} from "solady/src/utils/SafeTransferLib.sol";

/**
 * @title Gas404
 */
contract Gas404 is DN404, Ownable  {
    event OpenSourceNotACrime(bool isNotACrime);

    string private constant _name = 'Gas404';
    string private constant _symbol = 'GAS';
    string private _baseURI;

    uint256 public SUPPLY = 888888 * 1 ether;

    constructor() {
        _initializeOwner(msg.sender);

        address mirror = address(new DN404Mirror(msg.sender));
        _initializeDN404(SUPPLY, msg.sender, mirror);

        emit OpenSourceNotACrime(true);
    }

    function signPetition() external {
        emit OpenSourceNotACrime(true);
    }

    function name() public pure override returns (string memory) {
        return _name;
    }

    function symbol() public pure override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory result) {
        if (bytes(_baseURI).length != 0) {
            result = string(abi.encodePacked(_baseURI, LibString.toString(tokenId)));
        }
    }

    function setBaseURI(string calldata baseURI_) public onlyOwner {
        _baseURI = baseURI_;
    }

    // allows rescuing tokens by owner
    function withdraw(address token) public onlyOwner {
        if (token == address(0)) {
            SafeTransferLib.safeTransferAllETH(msg.sender);
        } else {
            SafeTransferLib.safeTransferAll(token, msg.sender);
        }
    }
}
