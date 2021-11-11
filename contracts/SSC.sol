// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract BPContract {
  function protect(
    address sender,
    address receiver,
    uint256 amount
  ) external virtual;
}

contract SSC is ERC20, ERC20Burnable, ERC20Snapshot, Ownable {
  BPContract public BP;
  bool public bpEnabled;
  bool public BPDisabledForever = false;

  constructor() ERC20("SSC", "SSC") {
    _mint(msg.sender, 100000000 * 10**decimals());
  }

  function snapshot() public onlyOwner {
    _snapshot();
  }

  function setBPAddrss(address _bp) external onlyOwner {
    require(address(BP) == address(0), "Can only be initialized once");
    BP = BPContract(_bp);
  }

  function setBpEnabled(bool _enabled) external onlyOwner {
    bpEnabled = _enabled;
  }

  function setBotProtectionDisableForever() external onlyOwner {
    require(BPDisabledForever == false);
    BPDisabledForever = true;
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal override(ERC20, ERC20Snapshot) {
    if (bpEnabled && !BPDisabledForever) {
      BP.protect(from, to, amount);
    }
    super._beforeTokenTransfer(from, to, amount);
  }
}
