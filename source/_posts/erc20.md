---
title: OpenZeppelin ERC20源码分析
date: 2018-09-15 17:45:05
categories: 区块链
tags: [以太坊, 区块链, ERC20]
---
ERC20：Ethereum Request for Comments 20，是一个基于以太坊代币的接口标准（协议）。所有符合 ERC-20 标准的代币都能立即兼容以太坊钱包，它能让用户和交易所，都能非常方便的管理多种代币，转账、存储、ICO 等等。

OpenZeppelin 的 Token 中实现了 ERC20 的一个安全的合约代码，本篇主要来分析一下源码，了解一下 ERC20 的实现，由于代码之间的调用可能略复杂，直接每个文件每个文件的来看会有点绕，我直接画了一个继承和调用关系的思维导图，可以帮助更容易地看源码。

{% asset_img images/open-zeppeline-erc20.png OpenZeppeline ERC20 %}

<!-- more -->
# ERC20Basic.sol
```
pragma solidity ^0.4.23;

contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}
```

ERC20Basic 合约主要定义了 ERC20 的基本接口，定义了必须要实现的方法:

totalSupply 返回总共发行量
balanceOf 查询指定 address 的余额
transfer 发送指定数目的 token 到指定账户，同时发送后需要触发Transfer事件
Transfer事件,任何 token 发送发生时，必须触发该事件，即使是 0 额度。 当一个 token 合约创建时，应该触发一个 Transfer 事件，token 的发送方是 0x0，也就是说凭空而来的 token，简称空气币。

# ERC20.sol
```
pragma solidity ^0.4.23;

import "./ERC20Basic.sol";

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}
```
ERC20 合约继承了 ERC20Basic，另外定义了 approve 相关的方法:

allowance 获取指定用户的批准额度，控制代币的交易，如可交易账号及资产, 控制 Token 的流通
transferFrom 从一个地址向另外一个地址转账指定额度的 token，这个方法可以理解为一个收款流程，允许合约来代表 token 持有者发送代币。比如，合约可以帮助你向另外一个人发送 token 或者索要 token。前提是 token 拥有者必须要通过某些机制对这个请求进行确认，比如通过 MetaMask 进行 confirm。否则，执行将失败。 跟 transfer 一样，即使发送 0 代币，也要触发Transfer事件。
approve 批准额度，允许一个账户最多能从你的账户你取现指定额度。重复调用时，以最后一次的额度为主。为了防止攻击，最开始这个额度必须设置为 0。
Approval事件，当 approve 被调用时，需要触发该事件。

# DetailedERC20.sol
```
pragma solidity ^0.4.23;

import "./ERC20.sol";

contract DetailedERC20 is ERC20 {
  string public name;
  string public symbol;
  uint8 public decimals;

  constructor(string _name, string _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }
}
```
DetailedERC20 主要定义了 token 的展示信息:

name token 的名称,比如”XXXToken”
symbol token 的符号,比如”XXX”
decimals token 精确的小数点位数，比如 18

# BasicToken.sol
```
pragma solidity ^0.4.23;

import "./ERC20Basic.sol";
import "../../math/SafeMath.sol";


/**
 * @title 实现ERC20基本合约的接口
 * @dev 基本的StandardToken，不包含allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev 返回存在的token总数
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev 给特定的address转token
  * @param _to 要转账到的address
  * @param _value 要转账的金额
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    //做相关的合法验证
    require(_to != address(0));
    require(_value <= balances[msg.sender]);
    // msg.sender余额中减去额度，_to余额加上相应额度
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    //触发Transfer事件
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev 获取指定address的余额
  * @param _owner 查询余额的address.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}
```
通过SafeMath来做运算很重要，在我们自己写合约的时候也尽量使用，可以避免一些计算过程的溢出等安全问题。

# StandardToken.sol
```
pragma solidity ^0.4.23;

import "./BasicToken.sol";
import "./ERC20.sol";

/**
 * @title 标准 ERC20 token
 *
 * @dev 实现基础的标准token
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {
  mapping (address => mapping (address => uint256)) internal allowed;

  /**
   * @dev 从一个地址向另外一个地址转token
   * @param _from 转账的from地址
   * @param _to address 转账的to地址
   * @param _value uint256 转账token数量
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    // 做合法性检查
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    //_from余额减去相应的金额
    //_to余额加上相应的金额
    //msg.sender可以从账户_from中转出的数量减少_value
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    // 触发Transfer事件
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev 批准传递的address以代表msg.sender花费指定数量的token
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender 花费资金的地址
   * @param _value 可以被花费的token数量
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    //记录msg.sender允许_spender动用的token
    allowed[msg.sender][_spender] = _value;
    //触发Approval事件
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev 函数检查所有者允许的_spender花费的token数量
   * @param _owner address 资金所有者地址.
   * @param _spender address 花费资金的spender的地址.
   * @return A uint256 指定_spender仍可用token的数量。
   */
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    //允许_spender从_owner中转出的token数
    return allowed[_owner][_spender];
  }

  /**
   * @dev 增加所有者允许_spender花费代币的数量。
   *
   * allowed[_spender] == 0时approve应该被调用. 增加allowed值最好使用此函数避免2此调用（等待知道第一笔交易被挖出）
   * From MonolithDAO Token.sol
   * @param _spender 花费资金的地址
   * @param _addedValue 用于增加允许动用的token牌数量
   */
  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    returns (bool)
  {
    //在之前允许的数量上增加_addedValue
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    //触发Approval事件
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev 减少所有者允许_spender花费代币的数量
   *
   * allowed[_spender] == 0时approve应该被调用. 减少allowed值最好使用此函数避免2此调用（等待知道第一笔交易被挖出）
   * From MonolithDAO Token.sol
   * @param _spender  花费资金的地址
   * @param _subtractedValue 用于减少允许动用的token牌数量
   */
  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    returns (bool)
  {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
    //减少的数量少于之前允许的数量，则清零
      allowed[msg.sender][_spender] = 0;
    } else {
    //减少对应的_subtractedValue数量
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    //触发Approval事件
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}
```
上面合约定义的 mapping allowed，它用来记录某个地址允许另外一个地址动用多少 token。假设钱包地址为 B，有另外一个合约其合约地址为 C，合约 C 会通过支付 XXX Token 来做一些事情，根据 ERC20 的定义，每个地址只能操作属于自己的 Token，则合约 C 无法直接使用 B 地址所拥有的 Token，这时候 allowed Mapping 就派上用场了，它上面可以记录一个允许操作值，像是「B 钱包地址允许 C 合约地址动用属于 B 钱包地址的 1000 XXX Token」，以 Mapping 的结构来说标记为「B => C => 1000」

# BurnableToken.sol
```
pragma solidity ^0.4.23;

import "./BasicToken.sol";

/**
 * @title 可销毁 Token
 * @dev Token可以被不可逆转地销毁
 */
contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

  /**
   * @dev 销毁指定数量的token.
   * @param _value 被销毁的token数量.
   */
  function burn(uint256 _value) public {
    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {
    require(_value <= balances[_who]);
    //不需要验证value <= totalSupply，因为这意味着发送者的余额大于总供应量，这应该是断言失败
    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
}
```
该合约比较简单，就是调用者可以销毁一定数量的 token，然后 totalSupply 减去对应销毁的数量

# StandardBurnableToken.sol
```
pragma solidity ^0.4.23;

import "./BurnableToken.sol";
import "./StandardToken.sol";

/**
 * @title 标准可销毁token
 * @dev 将burnFrom方法添加到ERC20实现中
 */
contract StandardBurnableToken is BurnableToken, StandardToken {

  /**
   * @dev 从目标地址销毁特定数量的token并减少允许量
   * @param _from address token所有者地址
   * @param _value uint256 被销毁的token数量
   */
  function burnFrom(address _from, uint256 _value) public {
    require(_value <= allowed[_from][msg.sender]);
    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
    // 此方法需要触发具有更新批准的事件。
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    _burn(_from, _value);
  }
}
```

# MintableToken.sol
```
pragma solidity ^0.4.23;

import "./StandardToken.sol";
import "../../ownership/Ownable.sol";


/**
 * @title 可增发 token
 * @dev 简单的可增发的 ERC20 Token 示例
 * @dev Issue: * https://github.com/OpenZeppelin/openzeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();
  //初始化增发状态为false
  bool public mintingFinished = false;

  modifier canMint() {
    // 检查没有增发结束
    require(!mintingFinished);
    _;
  }

  modifier hasMintPermission() {
    //owner只能为msg.sender
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev 增发token方法
   * @param _to 获取增发token的地址_to.
   * @param _amount 增发的token数量.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address _to,
    uint256 _amount
  )
    hasMintPermission
    canMint
    public
    returns (bool)
  {
    // 总发行量增加_amount数量的token
    totalSupply_ = totalSupply_.add(_amount);
    // 获取增发的地址增加_amount数量的token
    balances[_to] = balances[_to].add(_amount);
    // 触发增发事件
    emit Mint(_to, _amount);
    // 触发Transfer事件
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev 停止增发新token.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner canMint public returns (bool) {
    // 改变增发状态为已完成
    mintingFinished = true;
    // 触发增发已完成事件
    emit MintFinished();
    return true;
  }
}
```
增发 token 的合约也很简单，就是通过增发一定量的 token 给对应的 address，并给总发行量增加对应的增发 token，可以通过调用finishMinting来完成增发。

# CappedToken.sol
```
pragma solidity ^0.4.23;

import "./MintableToken.sol";

/**
 * @title 上限 token
 * @dev 设置一个顶的可增发token.
 */
contract CappedToken is MintableToken {

  uint256 public cap;

  constructor(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
  }

  /**
   * @dev 增发token
   * @param _to 获取增发token的地址_to.
   * @param _amount 增发token数量.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address _to,
    uint256 _amount
  )
    public
    returns (bool)
  {
    // 验证总发行量+增发量小于所设置的上限
    require(totalSupply_.add(_amount) <= cap);
    // 调用父合约的增发方法
    return super.mint(_to, _amount);
  }

}
```
CappedToken 也很简单，就是在可增发合约上加了一个”cap”，来限制增发的上限

# RBACMintableToken.sol
```
pragma solidity ^0.4.23;

import "./MintableToken.sol";
import "../../ownership/rbac/RBAC.sol";

/**
 * @title RBACMintableToken
 * @author Vittorio Minacori (@vittominacori)
 * @dev Mintable Token, with RBAC minter permissions
 */
contract RBACMintableToken is MintableToken, RBAC {
  /**
   * 指定一个增发者的常量名.
   */
  string public constant ROLE_MINTER = "minter";

  /**
   * @dev 重写Mintable token合约的 modifier，增加角色有关的逻辑
   */
  modifier hasMintPermission() {
    // 调用RBAC合约中的角色检查
    checkRole(msg.sender, ROLE_MINTER);
    _;
  }

  /**
   * @dev 将一个地址添加为可增发者角色
   * @param minter address
   */
  function addMinter(address minter) onlyOwner public {
    addRole(minter, ROLE_MINTER);
  }

  /**
   * @dev 将一个地址移除可增发者角色
   * @param minter address
   */
  function removeMinter(address minter) onlyOwner public {
    removeRole(minter, ROLE_MINTER);
  }
}
```
RBACMintableToken 合约将增发操作中添加了 RBAC 逻辑，就是角色权限管理的逻辑，将一个地址这是为增发者角色，也可以移除一个地址的增发者角色，只有拥有”minter”角色的 address 才有权限增发 token

# SafeERC20.sol
```
pragma solidity ^0.4.23;

import "./ERC20Basic.sol";
import "./ERC20.sol";

/**
 * @title SafeERC20
 * @dev 围绕ERC20操作发生故障的包装程序.
 * 可以在合约中通过这样使用这个库 `using SafeERC20 for ERC20;` 来使用安全的操作`token.safeTransfer(...)`
 */
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    ERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    require(token.approve(spender, value));
  }
}
```
SafeERC20 是一个 ERC20 的安全操作库，在下面的TokenTimelock锁定期后释放 token 的合约中我们可以看到用法

# TokenTimelock.sol
```
pragma solidity ^0.4.23;

import "./SafeERC20.sol";

/**
 * @title TokenTimelock 锁定期释放token
 * @dev TokenTimelock 是一个令token持有人合同，将允许一个受益人在给定的发布时间之后提取token
 */
contract TokenTimelock {
  //这里用到了上面的SafeERC20
  using SafeERC20 for ERC20Basic;

  // ERC20 basic token contract being held
  ERC20Basic public token;

  // token被释放后的受益人address
  address public beneficiary;

  // token可以被释放的时间戳
  uint256 public releaseTime;
  // 对token，受益人address和释放时间初始化
  constructor(
    ERC20Basic _token,
    address _beneficiary,
    uint256 _releaseTime
  )
    public
  {
    require(_releaseTime > block.timestamp);
    token = _token;
    beneficiary = _beneficiary;
    releaseTime = _releaseTime;
  }

  /**
   * @notice 将时间限制内的token转移给受益人.
   */
  function release() public {
    require(block.timestamp >= releaseTime);

    uint256 amount = token.balanceOf(this);
    require(amount > 0);

    token.safeTransfer(beneficiary, amount);
  }
}
```
TokenTimelock 合约通过初始化受益人以及释放的时间和锁定的 token，通过release来将锁定期过后释放的 token 转给受益人

# TokenVesting.sol
```
pragma solidity ^0.4.23;

import "./ERC20Basic.sol";
import "./SafeERC20.sol";
import "../../ownership/Ownable.sol";
import "../../math/SafeMath.sol";

/**
 * @title TokenVesting 定期释放token
 * @dev token持有人合同可以逐渐释放token余额典型的归属方案，有断崖时间和归属期, 可选择可撤销的所有者。
 */
contract TokenVesting is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for ERC20Basic;

  event Released(uint256 amount);
  event Revoked();

  // 释放后的token收益人
  address public beneficiary;

  uint256 public cliff; //断崖表示「锁仓4年，1年之后一次性解冻25%」中的一年
  uint256 public start;//起始时间
  uint256 public duration;//持续锁仓时间

  bool public revocable;

  mapping (address => uint256) public released;
  mapping (address => bool) public revoked;

  /**
   * @dev 创建一份归属权合同，将任何ERC20 token的余额归属给_beneficiary,逐渐以线性方式，直到_start + _duration 所有的余额都将归属。
   * @param _beneficiary 授予转让token的受益人的地址
   * @param _cliff 持续时间以秒为单位，代币将开始归属
   * @param _start 归属开始的时间（如Unix时间)
   * @param _duration 持续时间以token的归属期限为单位
   * @param _revocable 归属是否可撤销
   */
  constructor(
    address _beneficiary,
    uint256 _start,
    uint256 _cliff,
    uint256 _duration,
    bool _revocable
  )
    public
  {
    require(_beneficiary != address(0));
    require(_cliff <= _duration);

    beneficiary = _beneficiary;
    revocable = _revocable;
    duration = _duration;
    cliff = _start.add(_cliff);
    start = _start;
  }

  /**
   * @notice 将归属代币转让给受益人.
   * @param token ERC20 token which is being vested
   */
  function release(ERC20Basic token) public {
    uint256 unreleased = releasableAmount(token);

    require(unreleased > 0);

    released[token] = released[token].add(unreleased);

    token.safeTransfer(beneficiary, unreleased);

    emit Released(unreleased);
  }

  /**
   * @notice允许所有者撤销归属。 token已经归属合约，其余归还给所有者。
   * @param token ERC20 token which is being vested
   */
  function revoke(ERC20Basic token) public onlyOwner {
    require(revocable);
    require(!revoked[token]);

    uint256 balance = token.balanceOf(this);

    uint256 unreleased = releasableAmount(token);
    uint256 refund = balance.sub(unreleased);

    revoked[token] = true;

    token.safeTransfer(owner, refund);

    emit Revoked();
  }

  /**
   * @dev 计算已归属但尚未释放的金额。
   * @param token ERC20 token which is being vested
   */
  function releasableAmount(ERC20Basic token) public view returns (uint256) {
    return vestedAmount(token).sub(released[token]);
  }

  /**
   * @dev 计算已归属的金额.
   * @param token ERC20 token which is being vested
   */
  function vestedAmount(ERC20Basic token) public view returns (uint256) {
    uint256 currentBalance = token.balanceOf(this);
    uint256 totalBalance = currentBalance.add(released[token]);

    if (block.timestamp < cliff) {
      return 0;
    } else if (block.timestamp >= start.add(duration) || revoked[token]) {
      return totalBalance;
    } else {
      return totalBalance.mul(block.timestamp.sub(start)).div(duration);
    }
  }
}
```
TokenVesting 也是锁仓的一种方式，主要解决的是有断崖时间和持续锁仓时间的锁仓场景

# PausableToken.sol
```
pragma solidity ^0.4.23;

import "./StandardToken.sol";
import "../../lifecycle/Pausable.sol";


/**
 * @title Pausable token
 * @dev StandardToken modified with pausable transfers.
 **/
contract PausableToken is StandardToken, Pausable {

  function transfer(
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transfer(_to, _value);
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(
    address _spender,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.approve(_spender, _value);
  }

  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}
```
PausableToken 继承了 StandardToken，但是在方法中都添加了whenNotPaused函数修改器，whenNotPaused 继承自 Pausable 合约，Pausable 有个 paused 来标记暂停的状态，从而控制合约的是否暂停。

OpenZeppelin ERC20 源码分析到这里就结束了。

转载自Ryan [是菜鸟 | LNMP 技术栈笔记](https://yuanxuxu.com/2018/06/27/openzeppelin-erc20-code-analysis)
