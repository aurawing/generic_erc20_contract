pragma solidity ^0.4.24;
import "./SafeMath.sol";
import "./GenericToken.sol";

contract AirDrop {

    using SafeMath for uint256;

    address public admin;
    GenericToken public genericToken;

    constructor(address addr) public {
        genericToken = GenericToken(addr);
        admin = msg.sender;
    }

    mapping (address => uint256) filterTimeAddrs; //存放每个地址参加空投的时间

    bool public airDropFlag = false; //是否开启空投
    uint256 public airDropAmount = 10000000000000000000; //空投数量，默认10YTA
    uint256 public raisedAirDropAmount = 0; //已空投数量
    uint256 public maxAirDropAmount = 10000000000000000000000000; //空投总量，默认1000万

    bool public filterByValueFlag = true; //是否根据发送方地址余额过滤
    bool public filterByTimeFlag = true; //是否根据两次空投操作的间隔时间过滤

    uint256 public filterValue = 100000000000000000; //默认大于0.1eth的账号才可以参加空投
    uint256 public filterTime = 3600; //默认参加空投后一小时后才可以再次空投

    /**
     * 修改空投flag
     */
    function setAirDropFlag(bool _flag) public returns (bool) {
        require(msg.sender == admin);
        airDropFlag = _flag;
        return true;
    }

    /**
     * 修改空投数量
     */
    function setAirDropAmount(uint256 _value) public returns (bool) {
        require(msg.sender == admin);
        airDropAmount = _value;
        return true;
    }

    /**
     * 修改空投总量
     */
    function setMaxAirDropAmount(uint256 _value) public returns (bool) {
        require(msg.sender == admin);
        maxAirDropAmount = _value;
        return true;
    }

    /**
     * 修改余额过滤flag
     */
    function setFilterByValueFlag(bool _flag) public returns (bool) {
        require(msg.sender == admin);
        filterByValueFlag = _flag;
        return true;
    }

    /**
     * 修改时间过滤flag
     */
    function setFilterByTimeFlag(bool _flag) public returns (bool) {
        require(msg.sender == admin);
        filterByTimeFlag = _flag;
        return true;
    }

    /**
     * 修改余额过滤值
     */
    function setFilterValue(uint256 _value) public returns (bool) {
        require(msg.sender == admin);
        filterValue = _value;
        return true;
    }

    /**
     * 修改时间间隔过滤值
     */
    function setFilterTime(uint256 _value) public returns (bool) {
        require(msg.sender == admin);
        filterTime = _value;
        return true;
    }

    /**
     * fallback 空投
     */
    function() public payable {
        require(airDropFlag);
        if (msg.value > 0) {
            msg.sender.transfer(msg.value);
        }
        if (filterByValueFlag) {
            require (msg.sender.balance > filterValue);
        }
        if (filterByTimeFlag) {
            require (filterTimeAddrs[msg.sender] == uint256(0) || filterTimeAddrs[msg.sender].add(filterTime) <= now);
        }
        if (raisedAirDropAmount < maxAirDropAmount) {
            uint256 dropAmount = maxAirDropAmount.sub(raisedAirDropAmount);
            if (dropAmount > airDropAmount) {
                dropAmount = airDropAmount;
            }
            genericToken.transferfix(msg.sender, dropAmount);
            raisedAirDropAmount = raisedAirDropAmount.add(dropAmount);
            filterTimeAddrs[msg.sender] = now;
            if (raisedAirDropAmount >= maxAirDropAmount) {
                airDropFlag = false;
            }
                
        }
        
    }

    /**
     * 从合约提现
     */
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
