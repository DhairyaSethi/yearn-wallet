pragma solidity ^0.6.0;
import '@openzeppelin/contracts/token/ERC20/IERC20.sol'; // erc20 interface

interface IYDAI {
	function deposit(uint _amount) external;
	function withdraw(uint _shares) external;
	function balanceOf(address account) external view returns (uint);
	function getPricePerFullShare() external view returns (uint);
}


contract Wallet {
  address admin;

  IERC20 DAI = IERC20(0x5592EC0cfb4dbc12D3aB100b257153436a1f0FEa); 
  IYDAI yDAI = IYDAI(0xC2cB1040220768554cf699b0d863A3cd4324ce32); //mainnet, FIXME

  constructor() public {
  	admin = msg.sender;
  }

  function save(uint amount) external {
  	DAI.transferFrom(msg.sender, address(this), amount);
  	_save(amount);
  }

  function spend(uint amount, address recipient) external {
  	require(msg.sender == admin, 'Only Admin can withdraw.');
  	uint balanceShares = yDAI.balanceOf(address(this));
  	yDAI.withdraw(balanceShares);

  	DAI.transfer(recipient, amount);
  	// reinvest
  	uint balanceDai = DAI.balanceOf(address(this));
  	if(balanceDai > 0) {
  		_save(balanceDai);
  	}
  }

  	function _save(uint amount) internal {
  		DAI.approve(address(yDAI), amount);
  		yDAI.deposit(amount);
  	}

  	function balance() external view returns(uint) {
  		uint price = yDAI.getPricePerFullShare();
  		uint balanceShares = yDAI.balanceOf(address(this));
  		return balanceShares * price;
  	}

  	function () external payable { // configure ens for this, ADD
  		save(msg.value);
  	}

  }

