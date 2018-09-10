pragma solidity ^0.4.24;
import "./SafeMath.sol";
import "./GenericToken.sol";

contract DirectDrop {

    using SafeMath for uint256;

    address public admin;
    GenericToken public genericToken;

    constructor(address addr) public {
        genericToken = GenericToken(addr);
        admin = msg.sender;
    }

    bool public exchangeFlag = false; // 代币兑换开启
    
    // 不满足条件或募集完成多出的eth均返回给原账户
    uint256 public minWei = 1;  //最低打 1 wei  1eth = 1*10^18 wei
    uint256 public maxWei = 20000000000000000000000; // 最多一次打 20000 eth
    uint256 public maxRaiseAmount = 20000000000000000000000; // 募集上限 20000 eth
    uint256 public raisedAmount = 0; // 已募集 0 eth
    uint256 public raiseRatio = 200000; // 兑换比例 1eth = 20万token

    /**
     * 修改募集flag
     */
    function setExchangeFlag(bool _flag) public returns (bool) {
        require(msg.sender == admin);
        exchangeFlag = _flag;
        return true;
    }

    /**
     * 修改单笔募集下限
     */
    function setMinWei(uint256 _value) public returns (bool) {
        require(msg.sender == admin);
        minWei = _value;
        return true;
    }

    /**
     * 修改单笔募集上限
     */
    function setMaxWei(uint256 _value) public returns (bool) {
        require(msg.sender == admin);
        maxWei = _value;
        return true;
    }

    /**
     * 修改总募集上限
     */
    function setMaxRaiseAmount(uint256 _value) public returns (bool) {
        require(msg.sender == admin);
        maxRaiseAmount = _value;
        return true;
    }

    /**
     * 修改已募集数
     */
    // function setRaisedAmount(uint256 _value) public returns (bool) {
    //     require(msg.sender == admin);
    //     raisedAmount = _value;
    //     return true;
    // }

    /**
     * 修改募集比例
     */
    function setRaiseRatio(uint256 _value) public returns (bool) {
        require(msg.sender == admin);
        raiseRatio = _value;
        return true;
    }

    /**
     * fallback 向合约地址转账 or 调用非合约函数触发代币自动兑换eth
     */
    function() public payable {
        require(msg.value > 0);
        if (exchangeFlag) {
            if (msg.value >= minWei && msg.value <= maxWei){
                if (raisedAmount < maxRaiseAmount) {
                    uint256 valueNeed = msg.value;
                    raisedAmount = raisedAmount.add(msg.value);
                    if (raisedAmount > maxRaiseAmount) {
                        uint256 valueLeft = raisedAmount.sub(maxRaiseAmount);
                        valueNeed = msg.value.sub(valueLeft);
                        msg.sender.transfer(valueLeft);
                        raisedAmount = maxRaiseAmount;
                    }
                    if (raisedAmount >= maxRaiseAmount) {
                        exchangeFlag = false;
                    }
                    // 处理精度
                    uint256 _value = valueNeed.mul(raiseRatio);

                    //require(_value <= balances[directdrop]);
                    //balances[directdrop] = balances[directdrop].sub(_value);
                    //balances[msg.sender] = balances[msg.sender].add(_value);
                    
                    genericToken.transferfix(msg.sender, _value);

                }
            } else {
                msg.sender.transfer(msg.value);
            }
        } else {
            msg.sender.transfer(msg.value);
        }
    }

    function withdraw(uint256 _amount) public returns (bool) {
        require(msg.sender == admin);
        admin.transfer(_amount);
        return true;
    }

    /**
     * 查询合约的余额
     */
    function getBalance() public view returns (uint256) {
        require(msg.sender == admin);
        return address(this).balance;
    }

}
