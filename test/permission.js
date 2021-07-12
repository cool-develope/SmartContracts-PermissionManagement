const PC = artifacts.require("PermissionControl");

contract("PermissionControl", accounts => {
    it("create account in the first account", async () => {
        let Error = undefined;

        const instance = await PC.deployed();
        await instance.createAccount(2, 1, 3, 5);

        try {
            await instance.createAccount(1, 2, 2, 10);
        } catch (error) {
            Error = error;
        }
        assert.notEqual(Error, undefined, "Error must be thrown");
        assert.isAbove(Error.message.search("This user is already registered"), -1, "Error: VM Exception while processing transaction: revert");
    });

    it("add the first user again", async () => {
        let Error = undefined;

        const instance = await PC.deployed();

        try {
            await instance.addUser(accounts[0]);
        } catch (error) {
            Error = error;
        }

        assert.notEqual(Error, undefined, "Error must be thrown");
        assert.isAbove(Error.message.search("This user is already registered"), -1, "Error: VM Exception while processing transaction: revert");
    });

    it("add the second user again", async () => {
        let Error = undefined;

        const instance = await PC.deployed();
        await instance.addUser(accounts[1]);

        try {
            await instance.addUser(accounts[1]);
        } catch (error) {
            Error = error;
        }
        
        assert.notEqual(Error, undefined, "Error must be thrown");
        assert.isAbove(Error.message.search("This user is already invited"), -1, "Error: VM Exception while processing transaction: revert");

        await instance.acceptInvite({from: accounts[1]});
    });

    it("remove the first user", async () => {
        let Error = undefined;

        const instance = await PC.deployed();

        try {
            await instance.removeUser(accounts[0], {from: accounts[1]});
        } catch (error) {
            Error = error;
        }
        
        assert.notEqual(Error, undefined, "Error must be thrown");
        assert.isAbove(Error.message.search("Can't remove the owner"), -1, "Error: VM Exception while processing transaction: revert");

        await instance.removeUser(accounts[1]);
    });

    
    it("check the permission role in the second account", async () => {
        let Error = undefined;

        const instance = await PC.deployed();
        await instance.createAccount(1, 2, 2, 5, { from: accounts[1]});

        try {
            await instance.addUser(accounts[2], { from: accounts[1]});
        } catch (error) {
            Error = error;
        }

        assert.notEqual(Error, undefined, "Error must be thrown");
        assert.isAbove(Error.message.search("This user has no add permission"), -1, "Error: VM Exception while processing transaction: revert");
    });
});