//SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
//found contract
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.7/vendor/SafeMathChainlink.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
contract FundMe{
    using SafeMathChainlink for uint256;
    mapping(address => uint256) public addressToAmountFunded;
    //direcciones que pagan
    address[] public funders;
    //variable de estado manteener la eddress del token ERC20
    address public tokenAddress;
    //address token;
   //declaramos variable de el dueño
   address public owner;
   constructor(address _tokenAddress)public {
       tokenAddress=_tokenAddress;
       //al momneto que se despliege quien ejecute el contrato se convierte en dueño del contrato
       owner=msg.sender;
   }
    
    function fund() public payable{
        uint256 minUsd= 5 * 10**18;
        require(getConversionRate(msg.value)>=minUsd,"necesitas enviar mas dev");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }
    function depositErc(uint256 _amount) public {
    // I call the function of IERC20 contract to transfer the token from the user (that he's interacting with the contract) to
    // the smart contract 
     IERC20 token=IERC20(tokenAddress);
    token.transferFrom(msg.sender, address(this), _amount);
    
  }
    //Nos da el precio de btc
    function getPrice()public view returns(uint256){
        //AggregatorV3Interface priceFeed=AggregatorV3Interface(0xa39d8684B8cd74821db73deEB4836Ea46E145300);
        //(/*uint80 roundID*/,
           // int price,
            /*uint startedAt*/
            /*uint timeStamp*/
            /*uint80 answeredInRound*///)=priceFeed.latestRoundData();
            //return uint256(price * 10000000000);
        return uint256(2233822018468 * 10000000000);//40752693
    } 
    function getConversionRate(uint256 devAmount) public view returns(uint256){
        uint256 devPrice= getPrice();
        uint256 devAmountInusd=(devPrice * devAmount) / 1000000000000000000;
        return devAmountInusd;
    }
    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }
    function withdraw() payable onlyOwner public{
        //transfer nos permite transferir activos desde una billetera a otra
        //quien ejecute la funcion le vamos a transferir
        payable(msg.sender).transfer(address(this).balance);
        //----------
        for(uint256 funderIndex;funderIndex < funders.length;funderIndex++){
            address funder=funders[funderIndex];
            addressToAmountFunded[funder]=0;
        }
        funders=new address[](0);
    }
    
    /*function getContractBalance() public onlyOwner view returns(uint){
         return IERC20(token).balanceOf(address(this));
  }*/
}
