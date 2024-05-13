// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// contract StakingToken is IERC20 {

//     mapping (address => uint256) private _balances;

//     mapping (address => mapping (address => uint256)) private _allowed;

//     uint256 private _totalSupply;
//     constructor(uint256 initialBalance) {
//         _mint(msg.sender, initialBalance);
//     }

//     function mint(address to, uint256 amount) external {
//         _mint(to, amount);
//     }

//     function totalSupply() public view returns (uint256) {
//         return _totalSupply;
//     }

//     function balanceOf(address account) public view returns(uint256){
//         return _balances[account];
//     }


//     function allowance(
//     address owner,
//     address spender
//    )
//     public
//     view
//     returns (uint256)
//   {
//     return _allowed[owner][spender];
//   }



//   function transfer(address to, uint256 value) public returns (bool) {
//     require(value <= _balances[msg.sender]);
//     require(to != address(0));

//     _balances[msg.sender] = _balances[msg.sender].sub(value);
//     _balances[to] = _balances[to].add(value);
//     emit Transfer(msg.sender, to, value);
//     return true;
//   }

//   /**
//    * Beware that changing an allowance with this method brings the risk that someone may use both the old
//    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
//    * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
//    */
//   function approve(address spender, uint256 value) public returns (bool) {
//     require(spender != address(0));

//     _allowed[msg.sender][spender] = value;
//     emit Approval(msg.sender, spender, value);
//     return true;
//   }


//   function transferFrom(
//     address from,
//     address to,
//     uint256 value
//   )
//     public
//     returns (bool)
//   {
//     require(value <= _balances[from]);
//     require(value <= _allowed[from][msg.sender]);
//     require(to != address(0));

//     _balances[from] = _balances[from].sub(value);
//     _balances[to] = _balances[to].add(value);
//     _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
//     emit Transfer(from, to, value);
//     return true;
//   }

//   function increaseAllowance(
//     address spender,
//     uint256 addedValue
//   )
//     public
//     returns (bool)
//   {
//     require(spender != address(0));

//     _allowed[msg.sender][spender] = (
//       _allowed[msg.sender][spender].add(addedValue));
//     emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
//     return true;
//   }


//   function decreaseAllowance(
//     address spender,
//     uint256 subtractedValue
//   )
//     public
//     returns (bool)
//   {
//     require(spender != address(0));

//     _allowed[msg.sender][spender] = (
//       _allowed[msg.sender][spender].sub(subtractedValue));
//     emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
//     return true;
//   }

//   function _mint(address account, uint256 amount) internal {
//     require(account != 0);
//     _totalSupply = _totalSupply.add(amount);
//     _balances[account] = _balances[account].add(amount);
//     emit Transfer(address(0), account, amount);
//   }

// function _burn(address account, uint256 amount) internal {
//     require(account != 0);
//     require(amount <= _balances[account]);

//     _totalSupply = _totalSupply.sub(amount);
//     _balances[account] = _balances[account].sub(amount);
//     emit Transfer(account, address(0), amount);
//   }
// function _burnFrom(address account, uint256 amount) internal {
//     require(amount <= _allowed[account][msg.sender]);

//     // Should <https://github.com/OpenZeppelin/zeppelin-solidity/issues/707> be accepted,
//     // this function needs to emit an event with the updated approval.
//     _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
//       amount);
//     _burn(account, amount);
//   }
// }

