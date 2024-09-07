// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./IERC20.sol";

contract Presale{
    IERC20 private immutable CFT;
    IERC20 private immutable USDT;
    address private immutable owner;

    uint256 public totalTokens = 500000*10**18;
    uint256 public tokeSold;
    uint256 public price = 1;
    bool public presleSuccess;
    mapping(address=> uint256) public contributions;
    mapping(address=> bool) public hasClaimed;
    mapping(address=> bool) public isParticipant;
    address[] public participants;

    mapping(address=>address) public referrer;
    mapping(address=> uint256) public rewards;
    uint256[] public referralRewards = [10, 7 , 5 , 3 , 1];

    event tokensBought(address _buyer,uint256 _amount , address _referrer);
    event tokenClaimed(address _buyer , uint256 _amount);

    constructor(address _cft , address _usdt){
        CFT = IERC20(_cft);
        USDT = IERC20(_usdt);
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender==owner,"You are not the owner !!!");
        _;
    }

    function buyTokens(uint256 _amount , address _referrer) external{
        require(tokeSold+_amount<=totalTokens,"Not enough tokens left for sale");

        uint256 usdtAmount = (((_amount*price)/10**18)*10**6)/1000;
        USDT.transferFrom(msg.sender, address(this), usdtAmount);

        distrbutReward(msg.sender,usdtAmount,_referrer);
        tokeSold+=_amount;
        contributions[msg.sender]+=_amount;
        emit tokensBought(msg.sender, _amount, _referrer);
        if(isParticipant[msg.sender]==false){
            participants.push(msg.sender);
        }
    }

    function distrbutReward(address _buyer , uint256 _usdtAmount , address _referrer) internal{
        address currentReferrer = _referrer;
        for(uint i ;i<referralRewards.length;i++){
            if (currentReferrer == address(0)) break;

            uint256 reward = (_usdtAmount*referralRewards[i])/100;
            rewards[currentReferrer]+=reward;

            currentReferrer=referrer[currentReferrer];
        }
        if(_referrer!=address(0)&&referrer[_buyer]==address(0)){
            referrer[_buyer]=_referrer;
        }
    }

    function claimTokens() external{
        require(presleSuccess,"Presale was not succesful");
        require(contributions[msg.sender]>0,"No contributions Made");
        require(!hasClaimed[msg.sender],"Already claimed");

        uint256 amount = contributions[msg.sender];
        CFT.transfer(msg.sender, amount);
        hasClaimed[msg.sender]=true;
        emit tokenClaimed(msg.sender, amount);
    }

    function refund() public{
        require(!presleSuccess,"Presale was not succesful");
        require(contributions[msg.sender]>0,"No contributions made");

        uint256 amount = contributions[msg.sender];
        USDT.transfer(address(this), (amount*price)/1000);
        contributions[msg.sender]=0;
    }

    function setPresaleState(bool _status) public{
        presleSuccess=_status;
    }

    function withdraw() onlyOwner external{
        require(presleSuccess,"Presale was not succesful");
        USDT.transfer(owner, USDT.balanceOf(address(this)));
    }

}
//0x1B65a71bEC4299FcA5418552aaCc4b7a15a907Bb