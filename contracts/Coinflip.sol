//Made by Mislav
import "./provableAPI.sol";

pragma solidity 0.5.8;

contract Coinflip is usingProvable{

  struct Result {
    uint amount;
    bool won;
    uint256 blockNr;
    bool head;
  }

  struct Bet{
    address owner;
    bool bet;
    Result result;
  }

  address public owner;
  uint public balance = 0;
  bytes32 public latestServedId;

  mapping (address => Result) results;
  mapping (bytes32 => Bet) currentGames;

  event ResultEvent(bool win, address player, uint amount, uint256 blockNr, uint head);
  event RandomNumberProduced(uint256 randomNumber);
  event LogNewProvableQuery(string strin);

  uint256 constant NUM_OF_RANDOM_BYTES = 1;
  uint256 public latestNumber;

  function __callback(bytes32 _myid, string memory _result, bytes memory _proof) public{
    require (msg.sender == provable_cbAddress());

    uint256 randomNumber = uint256(keccak256(abi.encodePacked(_result))) % 2;
    latestNumber = randomNumber;
    //check if the player with queryId = _myid wron
    if(((latestNumber == 1) && currentGames[_myid].bet)||((latestNumber == 0) && !currentGames[_myid].bet)){
      //if won
      //put result in archive
      Result memory newResult;
      newResult = currentGames[_myid].result;
      newResult.won = true;
      address player = currentGames[_myid].owner;
      results[player] = newResult;

      //send money
      Result memory r = currentGames[_myid].result;
      uint toTransfer = (r.amount)*2;
      balance = balance - toTransfer;
      //delete it from currentGames
      delete currentGames[_myid];
      latestServedId = _myid;
      msg.sender.transfer(toTransfer);
      emit ResultEvent(newResult.won, player, newResult.amount, newResult.blockNr, latestNumber);

    }else{
      //if lost
      //put result in archive
      Result memory newResult;
      newResult = currentGames[_myid].result;
      newResult.won = false;
      address player = currentGames[_myid].owner;
      results[player] = newResult;
      latestServedId = _myid;
      //delete it from currentGames
      delete currentGames[_myid];
      emit ResultEvent(newResult.won, player, newResult.amount, newResult.blockNr, latestNumber);
    }
    emit RandomNumberProduced(latestNumber);
  }

  function update(address sender,bool head ,uint value, bool won, uint256 blockNr) payable public{
    uint256 QUERY_EXECUTION_DELAY = 0;
    uint256 GAS_FOR_CALLBACK = 200000;
    //get ready for mapping
    Result memory newResult;
    newResult.amount =value;
    newResult.won = won;
    newResult.blockNr = blockNr;
    Bet memory newBet;
    newBet.bet = head;
    newBet.owner = sender;
    newBet.result = newResult;

    bytes32 queryId = provable_newRandomDSQuery(
      QUERY_EXECUTION_DELAY,
      NUM_OF_RANDOM_BYTES,
      GAS_FOR_CALLBACK
    );
    currentGames[queryId] = newBet;
    emit LogNewProvableQuery(" -- Waiting for reply ... ");
  }


  constructor() public{
      owner = msg.sender;
  }

  modifier onlyOwner(){
        require(msg.sender == owner);
        _; //Continue execution
    }

  modifier costs(uint cost){
      require(msg.value >= cost);
      _;
  }
/*
  function coinflip(string memory sender,bool head, uint value, bool won, uint256 blockNr) private {
    if(now % 2 == 1){
      return true;
    } else {
      return false;
    }
  }
*/
  function getBalance() public view returns(uint amount){
    return address(this).balance;
  }

  function bet(bool head) public payable costs(0.001 ether){
    require(balance >= msg.value, "Not enough ETH in contract to make that bet");
    balance += msg.value;
    update(msg.sender,head , msg.value, false, block.number);

    /*
    newResult.head = flip;
    if ((flip && head) || (!flip && !head)){
      //if win
      newResult.won = true;
      results[msg.sender] = newResult;
      uint toTransfer = msg.value*2;
      balance = balance - toTransfer;
      msg.sender.transfer(toTransfer);
      assert(balance == oldBalance - msg.value);
      emit ResultEvent(newResult.won, msg.sender, msg.value, newResult.blockNr, flip);
    } else {
      //if lost
      results[msg.sender] = newResult;
      emit ResultEvent(newResult.won, msg.sender, msg.value, newResult.blockNr, flip);
    }*/

  }

  function lookUp() public view returns(bool result, uint amount, uint256 blockNr, bool head){
    Result memory res;
    res = results[msg.sender];
    return (res.won, res.amount, res.blockNr, res.head);
  }

  function fillContract() public payable onlyOwner{
    balance += msg.value;
  }



}
