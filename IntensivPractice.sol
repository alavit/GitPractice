// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

contract IntensivPractice {
    uint public myUint;
    address public owner;
    bool public myBool;

    address public constant MY_ADDRESS =
        0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    uint public immutable MAX_BALANCE;

    mapping(address => uint) public myMap;
    uint[] public myArr;

    mapping(address => mapping(uint => bool)) public nestedMapping;

    struct Payment {
        uint amount;
        uint timestamp;
        address from;
        string message;
    }

    struct Balance {
        uint totalPayments;
        mapping(uint => Payment) payments;
    }

    mapping(address => Balance) public balances;
    Payment[] public paymentsArray;

    constructor(uint _maxBalance) {
        owner = msg.sender;
        MAX_BALANCE = _maxBalance;
    }

    modifier ownerOnly() {
        require(msg.sender == owner, "you are not an owner!");
        _;
    }

    modifier nonEmptyAddress(address _adr) {
        require(_adr != address(0), "zero address!");
        _;
    }

    function changeOwner(address _newOwner) public nonEmptyAddress(_newOwner) {
        owner = _newOwner;
    }

    function addElement(uint element) public {
        myArr.push(element);
    }

    function getArray() public view returns (uint[] memory) {
        return myArr;
    }

    function findElementIndex(uint element) public view returns (int) {
        for (uint i = 0; i < myArr.length; i++) {
            if (myArr[i] == element) {
                return int(i);
            }
        }
        return -1; // if the element is not found return -1
    }

    // copying last element into to the place to remove, then removing last element
    function removeElement(uint element) public {
        int index = findElementIndex(element);

        require(index >= 0, "element is not found");

        myArr[uint(index)] = myArr[myArr.length - 1];
        myArr.pop();
    }

    function addMappingValue(
        address _adr,
        uint _balance,
        bool _value
    ) public {
        nestedMapping[_adr][_balance] = _value;
    }

    function removeMappingValue(address _adr, uint _balance) public {
        delete nestedMapping[_adr][_balance];
    }

    function pay(string memory message) public payable {
        uint paymentNumber = balances[msg.sender].totalPayments;
        balances[msg.sender].totalPayments++;

        Payment memory newPayment = Payment(
            msg.value,
            block.timestamp,
            msg.sender,
            message
        );

        balances[msg.sender].payments[paymentNumber] = newPayment;
    }

    function addPaymentToArray(Payment memory _payment) public {
        paymentsArray.push(_payment);
    }
}