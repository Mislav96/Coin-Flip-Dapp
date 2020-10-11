const Coinflip = artifacts.require("Coinflip");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(Coinflip).then(function(instance){
    instance.fillContract({value: web3.utils.toWei("0.03", "ether"), from:accounts[0]}).then(function(){
      console.log("Contract filled")
    });
  }).catch(function(err){
    console.log("Deployment failed withh error : " + err);
  });
};
