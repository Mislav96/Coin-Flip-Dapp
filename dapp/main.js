var web3 = new Web3(Web3.givenProvider);
var contractInstance;
var account;

$(document).ready(function() {
    window.ethereum.enable().then(function(accounts){
      account = String(accounts[0]);
      contractInstance = new web3.eth.Contract(abi, "0x1440FC7B5b6FA73C2ab3aC07729CBF6B862Cc55E", {from:accounts[0]});
      console.log(contractInstance);
      fetch();
    });

    //JQuery button
    $("#add_amount_button").click(input);


});



function input(){

  var amount = $("#amount_input").val();
  var bett = $('input[name="bet"]:checked').val();
  if (bett === "head"){
    bett = true;
  } else {
    bett = false;
  }
  var config=
    {
      value : web3.utils.toWei(String(amount),"ether"),
      from:account
    };
  //console.log("tu sam "+account);
  $('.dvLoading').css("visibility" , "visible");
  $('.overlay').css("visibility" , "visible");
  $('.overlay-back').css("visibility" , "visible");
  //send je vazan
  contractInstance.methods.bet(bett).send(config)
  .on("receipt",function(receipt){
    //console.log("tu sam 2");
    console.log(receipt);
    waiting();
  });

}

async function waiting(){
  //waiting flag
  var flag = true;

  //make event listener for our "ticket"
  contractInstance.events.ResultEvent({
    filter : {player : account, from : 0},
    function (error, event){
      console.log(event);
    }
  })
  .on("data", function(event){
    console.log(event);
    $('.dvLoading, .overlay, .overlay-back').css("visibility" , "hidden");
    fetch()
  });
  console.log("over");
}

async function fetch(){
  var money = await contractInstance.methods.getBalance().call()
  //console.log(String(money/1000000000000000000));
  $("#money_output").text(String(money/1000000000000000000)+" ETH");
  contractInstance.methods.lookUp().call().then(function(res){
    if(res.amount != 0){
      $("#amount_output").text(String(res.amount/1000000000000000000) +"ETH");
      $("#height_output").text(String(res.blockNr));

      if(res.result === true){
        $("#outcome_output").text("Won");
      } else { $("#outcome_output").text("Lost"); }
    }
  });
}
