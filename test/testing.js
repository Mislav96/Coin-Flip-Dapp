const Coinflip = artifacts.require("Coinflip");
const truffleAssert = require("truffle-assertions");

contract("Coinflip", async function(accounts){

  it("should initiate with at least 3 ETH", async function(){
    let instance = await Coinflip.deployed();
    let balance = await instance.getBalance();
    assert(balance >= web3.utils.toWei("0.3", "ether") , "Not enough ETH for initiating " + balance);
    assert(web3.eth.getBalance(Coinflip.address) >= web3.utils.toWei("0.3", "ether"),"Not enough ETH for initiating 2" )
  });

  it("shlouldn't be possible for non-owner to fill contract",async function(){
    let instance = await Coinflip.deployed();
    await truffleAssert.fails(instance.fillContract({value: web3.utils.toWei("1", "ether"), from: accounts[3]}));
  });
  it("shlould be possible for owner to fill contract",async function(){
    let instance = await Coinflip.deployed();
    await truffleAssert.passes(instance.fillContract({value: web3.utils.toWei("1", "ether"), from: accounts[0]}));
  });
  it("shouldn't be possible to bet without money", async function(){
    let instance = await Coinflip.deployed();
    await truffleAssert.fails(instance.bet({from:accounts[2]}))
  })
  it("should be possible to bet", async function(){
    let instance = await Coinflip.deployed();
    await truffleAssert.passes(instance.bet(true, {value:web3.utils.toWei("0.2", "ether"), from:accounts[2]} ))
  })

})
