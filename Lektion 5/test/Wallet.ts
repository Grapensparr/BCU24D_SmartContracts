import { expect } from "chai";
import { parseEther } from "ethers";
import { network } from "hardhat";

const { ethers } = await network.connect();

describe("Wallet", function() {
    async function deployWalletFixture() {
        const [account] = await ethers.getSigners();
        const Wallet = await ethers.getContractFactory("Wallet");
        const wallet = await Wallet.deploy();

        return { wallet, account }
    }

    describe("Deposit function", function() {
        it("Should accept deposits and emit an event", async function() {
            const { wallet, account } = await deployWalletFixture();
            const depositAmount = parseEther("1.0");

            await expect(wallet.deposit({ value: depositAmount }))
                .to.emit(wallet, "DepositMade")
                .withArgs(account.address, depositAmount);

            expect(await wallet.contractBalance()).to.equal(depositAmount);
        });

        it("Should allow deposits through the receieve function", async function() {
            const { wallet, account } = await deployWalletFixture();
            const depositAmount = parseEther("1.0");

            await expect(account.sendTransaction({ to: wallet.getAddress(), value: depositAmount }))
                .to.emit(wallet, "DepositMade")
                .withArgs(account.address, depositAmount);

            expect(await wallet.contractBalance()).to.equal(depositAmount);
        });
    });

    describe("Withdrawal function", function() {
        it("Should allow a valid withdrawal and emit an event", async function() {
            const { wallet, account } = await deployWalletFixture();
            const depositAmount = parseEther("1.0");
            const withdrawalAmount = parseEther("0.5");

            await wallet.deposit({ value: depositAmount });

            expect(await wallet.contractBalance()).to.equal(depositAmount);

            await expect(wallet.withdrawal(withdrawalAmount))
                .to.emit(wallet, "WithdrawalMade")
                .withArgs(account.address, withdrawalAmount);
            
            expect(await wallet.contractBalance()).to.equal(parseEther("0.5"));
        });

        it("Should not allow a withdrawal of more than 1 ETH per transaction", async function() {
            const { wallet } = await deployWalletFixture();
            const depositAmount = parseEther("3.0");
            const withdrawalAmount = parseEther("2.0");

            await wallet.deposit({ value: depositAmount });

            expect(await wallet.contractBalance()).to.equal(depositAmount);

            await expect(wallet.withdrawal(withdrawalAmount))
                .to.be.revertedWith("You cannot withdraw more than 1 ETH per transaction")
        })
    })

    describe("Fallback function", function() {
        it("Should revert if the fallback function is called", async function() {
            const { wallet, account } = await deployWalletFixture();
            await expect(account.sendTransaction({ to: wallet.getAddress(), data: "0x1234"}))
                .to.be.revertedWith("Fallback function called. This function does not exist. Try another one.");
        });
    });
})