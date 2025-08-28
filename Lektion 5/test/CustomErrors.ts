import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.connect();

describe("CustomErrors", function() {
    async function deployCustomErrorsFixture() {
        const [ownerAccount, notOwner] = await ethers.getSigners();
        const CustomErrors = await ethers.getContractFactory("CustomErrors");
        const customErrors = await CustomErrors.deploy();

        return { customErrors, ownerAccount, notOwner };
    }

    describe("Deployment", function() {
        it("Should set the correct owner", async function() {
            const { customErrors, ownerAccount } = await deployCustomErrorsFixture();

            expect(await customErrors.owner()).to.equal(ownerAccount.address);
        });
    });

    describe("setNumber functionality", function() {
        it("Should allow a valid number to be set", async function() {
            const { customErrors } = await deployCustomErrorsFixture();
            const validNumber = 12;

            await customErrors.setNumber(validNumber);

            expect(await customErrors.number()).to.equal(validNumber);
        });

        it("Should not allow a non-owner to set a valid number", async function() {
            const { customErrors, notOwner } = await deployCustomErrorsFixture();
            const validNumber = 14;

            await expect(customErrors.connect(notOwner).setNumber(validNumber))
                .to.be.revertedWithCustomError(customErrors, "NotOwner")
                .withArgs(notOwner.address);
        });

        it("Should not allow the owner to set a number below 10", async function() {
            const { customErrors } = await deployCustomErrorsFixture();
            const invalidNumber = 5;

            await expect(customErrors.setNumber(invalidNumber))
                .to.be.revertedWithCustomError(customErrors, "TooLow")
                .withArgs(invalidNumber, 10);
        });

        it("Should keep the number despite invalid input", async function() {
            const { customErrors } = await deployCustomErrorsFixture();
            const validNumber = 12;
            const invalidNumber = 5;

            await customErrors.setNumber(validNumber);

            expect(await customErrors.number()).to.equal(validNumber);

            await expect(customErrors.setNumber(invalidNumber))
                .to.be.revertedWithCustomError(customErrors, "TooLow")
                .withArgs(invalidNumber, 10);
            
            expect(await customErrors.number()).to.equal(validNumber);
        });
    });
})