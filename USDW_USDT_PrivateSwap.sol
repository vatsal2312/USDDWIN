/**
 *Submitted for verification at BscScan.com on 2024-12-30
*/

// SPDX-License-Identifier: MIT
// Developed by DWIN Community

pragma solidity 0.8.16;
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


interface IBEP20 {
   
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

   
    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

   
    function transferFrom(
        address from,
        address to,
        uint amount
    ) external returns (bool);
}

abstract contract ApproveAndCallFallBack {
   function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public virtual;
}


contract USDW_USDT_PrivateSwap is IBEP20{


   
    address  public owner;
    address public Admin;
    
    uint public ContractBalance;
     mapping(address => mapping(address => uint)) allowed;
    mapping(address => uint) public balances;
    IBEP20 public USDT; //18 decimals
    IBEP20 public USDW; // 6 decimals
    uint public SetUSDTAllowance = 0;
    uint public SetUSDWAllowance = 0;  
    bool public SwapUSDW_Allowance =false;
    bool public SwapUSDT_Allowance =false;    
    using SafeMath for uint;
     
     string public symbol;
    string public  name ;
    uint public decimals;
    uint _totalSupply;


     constructor() {
       owner = msg.sender;
        
     } 

     bool internal locked;
    modifier noReentrant(){
       require(!locked,"No re-entrancy");
           locked = true;
            _;
          locked = false;
    }

     function setDetail()public onlyOwner{
        symbol = "DWIN";
        name = "USDT-USDW-Swap";
        decimals = 6;       
       
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier OnlyRightAddress {
        require((msg.sender == owner)||(msg.sender==Admin));
        _;
    }  

    function SetRightPerson(address _admin) onlyOwner public {
        Admin = _admin;
    }

//one time setting limited
    function SetUSDT(IBEP20 _usdt) onlyOwner public {
        require(SetUSDTAllowance==0);
        USDT = _usdt;
        SetUSDTAllowance +=1;
    } 

//one time setting limited
    function SetUSDW(IBEP20 _usdw) onlyOwner public {
        require(SetUSDWAllowance==0);
        USDW = _usdw;
        SetUSDWAllowance +=1;
    }

//0 => Not Allow USDW swap to be USDT
//1 => Allow USDW swap to be USDT
    function SetUSDTSwapMode(uint _mode) OnlyRightAddress public {
      require(_mode<2);
        if(_mode==0){
            SwapUSDT_Allowance = false;
        }

        if(_mode==1){
            SwapUSDT_Allowance = true;
        }
    }  


    //0 => Not Allow USDT swap to be USDW
    //1 => Allow USDT swap to be USDW
    function SetUSDWSwapMode(uint _mode) OnlyRightAddress public {
      require(_mode<2);
        if(_mode==0){
            SwapUSDW_Allowance = false;
        }

        if(_mode==1){
            SwapUSDW_Allowance = true;
        }
    }  

     function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    

    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }

    function transfer(address to, uint tokens) public returns (bool success) {
        require(balances[msg.sender]>=tokens, "Not enough Token");
        balances[msg.sender] -= tokens;
        balances[to] += tokens;
        //emit Transfer(msg.sender, to, tokens);
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
        return IBEP20(tokenAddress).transfer(Admin, tokens);
    }
    

   function CheckUSDTInContract()public view returns(uint){
       
       return USDT.balanceOf(address(this));     
   }

   function CheckUSDWInContract()public view returns(uint){
       
       return USDW.balanceOf(address(this));     
   }

// USDT swap to be USDW ,1:1 swap
  function SwaptoUSDW(uint _amount)public noReentrant returns(bool){
    require(CheckUSDWInContract()>= _amount.div(10**12));
    require(_amount>=10**12);
    require(SwapUSDW_Allowance == true);

    USDT.transferFrom(msg.sender, address(this), _amount);
    USDW.transfer(msg.sender, _amount.div(10**12) );

    return true;

  }


  // USDW swap to be USDT ,1:1 swap 
  function SwaptoUSDT(uint _amount)public noReentrant returns(bool){
    require(CheckUSDTInContract()>= _amount.mul(10**12));   
    require(SwapUSDT_Allowance == true);

    USDW.transferFrom(msg.sender, address(this), _amount);
    USDT.transfer(msg.sender, _amount.mul(10**12) );

    return true;

  }


  function transferUSDT(uint _amount)public noReentrant returns(bool){
    require(msg.sender==Admin);
    require(CheckUSDTInContract()>= _amount);
        USDT.transfer(msg.sender, _amount);
   return true;
  }

  function transferUSDW(uint _amount)public noReentrant returns(bool){
    require(msg.sender==Admin);
    require(CheckUSDWInContract()>= _amount);
        USDW.transfer(msg.sender, _amount);
   return true;
  }


     

}
