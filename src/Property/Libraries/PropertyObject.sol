// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

library PropertyObject {
    struct Property {
        address propertyOwner;
        uint propertyRent;
        uint propertPrice;
        PropertyStatus propertyStatus;
    }

    enum PropertyStatus {
        Available,
        ForSale,
        Owned
    }
}
