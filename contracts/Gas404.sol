// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {DN404} from "dn404/src/DN404.sol";
import {DN404Mirror} from "dn404/src/DN404Mirror.sol";
import {Ownable} from "solady/src/auth/Ownable.sol";
import {LibString} from "solady/src/utils/LibString.sol";
import {SafeTransferLib} from "solady/src/utils/SafeTransferLib.sol";

/**
 * @title Gas404
 * @notice DN404 contract that mints 1e18 amount of token with Proof of Gas (More amount, more gas spent)
 * When a user has at least one base unit (10^18) amount of tokens, they will automatically receive an NFT.
 * NFTs are minted as an address accumulates each base unit amount of tokens.
 * Only EOAs with NFT mint allowed would be able to mint
 *
 * If you are reading this code, you know that open source is not a crime, right?
 *
 * 2024 will be the last year to defend this simple ideology.
 *
 * Donate to Justice DAO, now.
 *
 * https://wewantjusticedao.org/
 *
 * #OpenSourceNotACrime
 */
contract Gas404 is DN404, Ownable {
    event OpenSourceNotACrime(bool isNotACrime);

    string private constant _name = 'Gas404';
    string private constant _symbol = 'OIL';
    string private _baseURI;

    uint256 public constant LIQUIDITY_SUPPLY = 488888 * 1e18;
    uint256 public constant AIRDROP_SUPPLY = 200000 * 1e18;
    uint256 public constant MINTING_SUPPLY = 200000 * 1e18;
    uint256 public constant MAX_SUPPLY = LIQUIDITY_SUPPLY + AIRDROP_SUPPLY + MINTING_SUPPLY;

    uint256 public airdroppedAmount;
    uint256 public mintedAmount;

    // pause when we migrate to the next DN404 version
    address public pauser;
    bool public paused;

    struct Airdrop {
        address recipient;
        uint256 amount;
    }

    constructor() {
        _initializeOwner(msg.sender);
        pauser = msg.sender;

        address mirror = address(new DN404Mirror(msg.sender));
        _initializeDN404(LIQUIDITY_SUPPLY, msg.sender, mirror);

        emit OpenSourceNotACrime(true);
    }

    function signPetition() external {
        emit OpenSourceNotACrime(true);
    }

    receive() external payable override {
        mint(1);
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

    /// @dev Returns if `a` has bytecode of non-zero length.
    function getCode(address a) private view returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := extcodesize(a) // Can handle dirty upper bits.
        }
    }

    // This allows anyone to mint more tokens by burning gas
    function mint(uint256 amount) public {
        require(!getCode(msg.sender), 'CONTRACT_NOT_SUPPORTED');
        require(!getSkipNFT(msg.sender), 'SKIPPING_NFT');
        uint256 mintAmount = amount * 1 ether;
        mintedAmount += mintAmount;
        _mint(msg.sender, mintAmount);

        // Support the on-chain petition to defend open-source development, open source is not a crime.
        emit OpenSourceNotACrime(true);
    }

    function airdrop(Airdrop[] memory recipients) external onlyOwner {
        uint256 _airdroppedAmount = airdroppedAmount;

        for (uint256 i; i < recipients.length; ++i) {
            Airdrop memory recipient = recipients[i];
            uint256 airdropAmount = recipient.amount * 1 ether;

            _airdroppedAmount += airdropAmount;

            if (!getCode(recipient.recipient)) {
                _setSkipNFT(recipient.recipient, true);
                _mint(recipient.recipient, airdropAmount);
                _setSkipNFT(recipient.recipient, false);
            } else {
                _mint(recipient.recipient, airdropAmount);
            }
        }

        require(_airdroppedAmount <= AIRDROP_SUPPLY, 'OVERMINT');

        airdroppedAmount = _airdroppedAmount;
    }

    function _mint(address to, uint256 amount) internal virtual override {
        super._mint(to, amount);
        
        if (uint256(_getDN404Storage().totalSupply) <= MAX_SUPPLY) {
            revert TotalSupplyOverflow();
        }
    }

    function _transfer(address from, address to, uint256 amount) internal virtual override {
        require(!paused, 'TRANSFER_PAUSED');
        super._transfer(from, to, amount);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
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

    function pause() external {
        require(msg.sender == pauser, 'NOT_PAUSER');
        paused = (paused == true) ? false : true;
    }

    function changePauser(address _pauser) external {
        require(msg.sender == pauser, 'NOT_PAUSER');
        pauser = _pauser;
    }
}
