import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.connect();

describe("AccessControl", function() {
    async function deployAccessControlFixture() {
        const [owner, admin, supporter, member] = await ethers.getSigners();
        const AccessControl = await ethers.getContractFactory("AccessControl");
        const accessControl = await AccessControl.deploy();

        return { accessControl, owner, admin, supporter, member }
    }

    describe("Deployment", function() {
        it("Should set the deployer as admin", async function() {
            const { accessControl, owner } = await deployAccessControlFixture();

            expect(await accessControl.admins(owner.address)).to.be.true;
        });
    });

    describe("Assign role", function() {
        it("Should allow admin to assign the admin role to another account", async function() {
            const { accessControl, admin } = await deployAccessControlFixture();

            expect(await accessControl.admins(admin.address)).to.be.false;

            await expect(accessControl.assignAdminRole(admin.address))
                .to.emit(accessControl, "RoleAssigned")
                .withArgs(admin.address, "Admin");
            
            expect(await accessControl.admins(admin.address)).to.be.true;
        });

        it("Should allow admin to assign the supporter role", async function() {
            const { accessControl, supporter } = await deployAccessControlFixture();

            expect(await accessControl.supporters(supporter.address)).to.be.false;
            
            await expect(accessControl.assignOtherRole(supporter.address, "Supporter"))
                .to.emit(accessControl, "RoleAssigned")
                .withArgs(supporter.address, "Supporter");
            
            expect(await accessControl.supporters(supporter.address)).to.be.true;
        });

        it("Should allow admin to assign the member role", async function() {
            const { accessControl, member } = await deployAccessControlFixture();

            expect(await accessControl.members(member.address)).to.be.false;
            
            await expect(accessControl.assignOtherRole(member.address, "Member"))
                .to.emit(accessControl, "RoleAssigned")
                .withArgs(member.address, "Member");
            
            expect(await accessControl.members(member.address)).to.be.true;
        });

        it("Should not allow an admin to assign a role that doesn't exist", async function() {
            const { accessControl, member } = await deployAccessControlFixture();

            await expect(accessControl.assignOtherRole(member.address, "Invalid role"))
                .to.be.revertedWith("Invalid role. Please try again!")
        });

        it("Should not allow a non-admin to assign a role", async function() {
            const { accessControl, supporter, member } = await deployAccessControlFixture();

            await expect(accessControl.connect(supporter).assignOtherRole(member.address, "Member"))
                .to.be.revertedWith("You are not an admin and cannot call this function!");
        });
    });
})