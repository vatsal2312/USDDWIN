/**
 *Submitted for verification at polygonscan.com on 2025-02-23
*/

// SPDX-License-Identifier: MIT
// Dev by Dwin Community
pragma solidity ^0.8.9;

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}



// ERC 20 Token Standard #20 Interface

interface IERC20 {
   
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

   
    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

   
    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}



abstract contract ApproveAndCallFallBack {
   function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public virtual;
}





contract USDDWIN is IERC20 {
     
    event PegAsset(address indexed from, address indexed account, uint amount);
    event Burn(address indexed account, uint amount);
   
    address public creator;

   
   
    constructor(){
       
         creator = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == creator);
        _;
    }

    modifier onlyAdmin {
        require(msg.sender == Admin);
        _;
    }

   
    using SafeMath for uint;

    string public symbol;
    string public  name ;
    uint public decimals;
    uint _totalSupply;

    
    
 

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    mapping(address => uint) Permit;

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
  
    function setDetail()public onlyOwner{
        symbol = "USDW";
        name = "USD DWIN";
        decimals = 6;       
       
    }

    address public Admin;
    address public Minter;
    
   

    function setAdmin(address _admin)public onlyOwner{
     
               Admin = _admin;
             

    }

    function setMinter(address _minter)public onlyAdmin{
       
        Minter = _minter;
    }

    

    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }


    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }


    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] =balances[msg.sender].sub(tokens);
        balances[to] +=tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }


    
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    


    
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] =balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] +=tokens;
        emit Transfer(from, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


   
    function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }


    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public returns (bool success) {
        return IERC20(tokenAddress).transfer(Admin, tokens);
    }
    



   function _mint(address to, uint amount)internal{
       balances[to] = balances[to].add(amount);
       _totalSupply+=amount;

   }

    function _burn(address to, uint amount)internal{
        require(balances[to]>=amount);
        require(_totalSupply>=amount);
       balances[to] = balances[to].sub(amount);
       _totalSupply-=amount;

   }


   function MintForPeg(address to , uint  amount) public returns (bool){
   require((msg.sender==Minter)||(msg.sender==Admin));
   _mint(to,amount);
   emit PegAsset(msg.sender, to, amount);
   return true;

   }

   function BurnAsset(uint amount) public returns(bool){
    require((msg.sender==Minter)||msg.sender==Admin);
    _burn(msg.sender, amount);

    emit Burn(msg.sender, amount);
   return true;


   }






}
