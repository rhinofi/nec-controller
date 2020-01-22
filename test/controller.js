const Controller = artifacts.require("./NectarController")
const NEC = artifacts.require("./NEC")
const MiniMeTokenFactory = artifacts.require("MiniMeTokenFactory")
const { logGasUsage, blockTime, snapshot, restore, forceMine, moveForwardTime } = require('./helpers/util')
const catchRevert = require("./helpers/exceptions").catchRevert;

const BN = web3.utils.BN
const _1e18 = new BN('1000000000000000000')
let initSnap

contract('Controller', async (accounts) => {

    let controller, nec

    before(async () => {

        vaultWallet = accounts[0]

        const tokenFactory = await MiniMeTokenFactory.new()
        nec = await NEC.new(tokenFactory.address, vaultWallet)
        controller = await Controller.new(vaultWallet, nec.address)

        await nec.transfer(accounts[1], _1e18.mul(new BN(10000)))
        await nec.transfer(accounts[2], _1e18.mul(new BN(10000)))
        const transfertx = await nec.transfer(accounts[3], _1e18.mul(new BN(100000)))
        logGasUsage('transfering NEC', transfertx)
    })

    it("...should be able to see accounts have NEC balances", async () => {

        const balance = await nec.balanceOf(accounts[1])
        assert.equal(balance.toString(), _1e18.mul(new BN(10000)).toString(), "Tokens were not transfered")
        initSnap = await snapshot()
    })

    it('should change the Controller to the Controller Contract', async () => {
        await nec.changeController(controller.address, {from: accounts[0]})
        const controllerAddress = await nec.controller.call()
        assert.equal(controllerAddress, controller.address, 'The controller was not correctly set')
    })

    it('should have NEC address correctly logged in Controller', async () => {
        const tokenAddress = await controller.tokenContract.call()
        assert.equal(tokenAddress, nec.address, 'Wrong address')
    })

    it('should not be possible to burn tokens if burning disabled', async () => {

        await catchRevert(nec.burnAndRetrieve(_1e18.mul(new BN(5000)) , {from: accounts[1]}))
        const balance = await nec.balanceOf(accounts[1])
        assert.equal(balance.toString(), _1e18.mul(new BN(10000)).toString(), "Tokens were not burned")
    })

    it('should be possible to burn tokens if you hold them and burning enabled', async () => {

        await controller.enableBurning(true)
        await nec.burnAndRetrieve(_1e18.mul(new BN(5000)) , {from: accounts[1]})
        const balance = await nec.balanceOf(accounts[1])
        assert.equal(balance.toString(), _1e18.mul(new BN(5000)).toString(), "Tokens were not burned")
    })

    it('should not be possible to burn more tokens than you hold', async () => {

      await nec.burnAndRetrieve(_1e18.mul(new BN(5001)) , {from: accounts[1]})
      const balance = await nec.balanceOf(accounts[1])
      assert.equal(balance.toString(), _1e18.mul(new BN(5000)).toString(), "Tokens were not burned")
      await nec.burnAndRetrieve(_1e18.mul(new BN(5001)) , {from: accounts[1]})
      assert.equal(balance.toString(), _1e18.mul(new BN(5000)).toString(), "Tokens were not burned")
    })

    it('should be possible for the owner to upgrade the controller', async () => {
        await controller.upgradeController(accounts[9], {from: accounts[0]})
        const newController =  await nec.controller.call()
        assert.equal(newController.valueOf(), accounts[9], 'Not successful')
    })

    it('should not be possible for anyone else to update the controller', async () => {
        await catchRevert(controller.upgradeController(accounts[5], {from: accounts[1]}))

        const newController =  await nec.controller.call()
        assert.equal(newController.valueOf(), accounts[9], 'Oh dear it changed again')
    })


})
