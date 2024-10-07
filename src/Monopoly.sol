// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {PlayerObject} from "./Player/Libraries/PlayerObject.sol";
import {PlayerLogic} from "./Player/Libraries/PlayerLogic.sol";
import {PlayerErrors} from "./Player/Libraries/PlayerErrors.sol";
import {PropertyObject} from "./Property/Libraries/PropertyObject.sol";

contract Core_Monopoly {
    uint256 public playersCount;
    mapping(uint256 => PlayerObject.Player) private player;
    mapping(address => PlayerObject.Player) private playerMapping;
    mapping(bytes => bool) private alreadyExistingName;
    mapping(address => bool) private alreadyExistingAddress;
    mapping(address => PropertyObject.Property) private propertyOwner;
    mapping(uint => PropertyObject.Property) private propertyId;

    function registerPlayer(
        string memory name
    ) external returns (PlayerObject.Player memory p, uint256 playerId_) {
        require(playersCount < 8, "Maximum no Of players Allowed is 8");
        // Check if the address already exists
        bool duplicateAddress = PlayerLogic.checkDuplicateAddress(
            alreadyExistingAddress,
            msg.sender
        );
        if (duplicateAddress) {
            revert PlayerErrors.DuplicateAddressError(msg.sender);
        }

        // Check if the name is already taken
        (bool nameTaken, ) = PlayerLogic.checkDuplicateName(
            alreadyExistingName,
            name
        );
        if (nameTaken) {
            revert PlayerErrors.DuplicateUsernameError(bytes(name));
        }

        // Increment players count and register the player
        playersCount += 1;
        (p, playerId_) = PlayerLogic.registerPlayer(
            playersCount,
            msg.sender,
            bytes(name),
            player,
            playerMapping
        );

        // Mark the address and name as already existing
        alreadyExistingAddress[msg.sender] = true;
        alreadyExistingName[bytes(name)] = true; // Store name directly as bytes
    }

    function buyProperty(uint256 id) public payable returns (bool status) {
        PropertyObject.Property storage property = propertyId[id]; // Use storage for modifying the property directly
        uint amount = property.propertPrice; // Property price

        if (
            property.propertyStatus == PropertyObject.PropertyStatus.Available
        ) {
            // Require the buyer to send the correct amount of Ether to purchase the property
            require(msg.value >= amount, "Insufficient Ether to buy property");

            // The contract (bank) keeps the Ether, so no need to call an external address.
            // Just transfer ownership and update the property status
            property.propertyOwner = msg.sender;
            property.propertyStatus = PropertyObject.PropertyStatus.Owned;

            return true;
        } else {
            // Property is up for resale, and a payment is required to the current owner
            require(
                property.propertyStatus ==
                    PropertyObject.PropertyStatus.ForSale,
                "Property not for sale"
            );
            require(
                property.propertyOwner != msg.sender,
                "You already own this property"
            );

            // Transfer Ether to the current owner (seller)
            address payable recipient = payable(property.propertyOwner);
            (bool success, ) = recipient.call{value: amount}(""); // Send Ether to the seller
            require(success, "Transfer to seller failed");

            // Update ownership and status
            property.propertyOwner = msg.sender;
            property.propertyStatus = PropertyObject.PropertyStatus.Owned;

            return true;
        }
    }

    function payRent(uint256 id) public payable returns (bool status) {
        PropertyObject.Property storage property = propertyId[id];
        uint amount = property.propertyRent; // Rent price

        // Ensure the property is owned by someone
        require(
            property.propertyStatus == PropertyObject.PropertyStatus.Owned,
            "Property not owned"
        );

        // Ensure the player is sending enough Ether to cover the rent
        require(msg.value >= amount, "Insufficient Ether to pay rent");

        // Transfer rent payment to the property owner
        address payable recipient = payable(property.propertyOwner);
        (bool success, ) = recipient.call{value: amount}(""); // Send Ether to the property owner
        require(success, "Transfer to property owner failed");

        // Refund excess Ether, if any (optional)
        if (msg.value > amount) {
            uint excess = msg.value - amount;
            (bool refundSuccess, ) = msg.sender.call{value: excess}("");
            require(refundSuccess, "Refund of excess Ether failed");
        }

        return true;
    }

    function sellProperty(uint256 id) public payable returns (bool status) {
        PropertyObject.Property storage property = propertyId[id];
        uint price = property.propertPrice; // Selling price of the property

        // Ensure the property is owned and the sender is the current owner
        require(
            property.propertyStatus == PropertyObject.PropertyStatus.Owned,
            "Property not owned by anyone"
        );
        require(
            property.propertyOwner == msg.sender,
            "Only the property owner can sell this property"
        );

        // Ensure the buyer has sent enough Ether to buy the property
        require(msg.value >= price, "Insufficient Ether to buy property");

        // Transfer the Ether from the buyer to the seller (current property owner)
        address payable seller = payable(property.propertyOwner);
        (bool success, ) = seller.call{value: price}(""); // Transfer Ether to the seller
        require(success, "Transfer to seller failed");

        // Update property ownership and status
        property.propertyOwner = msg.sender; // The buyer becomes the new owner
        property.propertyStatus = PropertyObject.PropertyStatus.Owned; // Mark property as owned by buyer

        // Refund excess Ether, if any
        if (msg.value > price) {
            uint excess = msg.value - price;
            (bool refundSuccess, ) = msg.sender.call{value: excess}("");
            require(refundSuccess, "Refund of excess Ether failed");
        }

        return true;
    }
}
