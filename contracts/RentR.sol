// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract RentR is ReentrancyGuard
{
    using Counters for Counters.Counter;
    
    constructor()
    {
        manager = msg.sender;
    }

    // Structs 
    struct RentPayment
    {
        uint256 payementDate;
        uint256 amountPaid;
    }

    struct PersonalDetails
    {
        string name;
        string emailId;
        string sex;
        uint256 age;
        uint256 aadharNumber;
        string imageURI;
    }

    struct Owner
    {
        address ownerAddress;
        PersonalDetails personalDetails;
        bool flag;
    }

    struct Renter
    {
        address renterAddress;
        PersonalDetails personalDetails;
        uint256 startDate;
        uint256 endDate;
        uint256 paymentDate;
        uint256 baseRent;
        uint256 annualIncrementRate;
        string agreementURI;
        uint256 lastPaymentDate;
        mapping(uint256 => RentPayment) paymentHistory;
        uint256 numberOfPayments;
        Owner owner;
        bool flag;       
    }

    // Local Variables
    address public manager;
    uint256 servicePrice = 0.000477 ether; //100 INR - 477000000000000 wei 

    // Maps
    mapping(address => Owner) private owners; 
    mapping(address => Renter) private renters; 
    
    // Functions

    // getServicePrice
    function getServicePrice() public view returns (uint256)
    {
        return servicePrice;    
    }

    // setServicePrice
    function setServicePrice(uint256 _servicePrice) public 
    {
        servicePrice = _servicePrice;
    } 

    // Lists an Owner,
    function listOwner(
        string memory _name,
        string memory _emailId,
        string memory _sex,
        uint256 _age,
        uint256 _aadharNumber,
        string memory _imageURI
    ) public payable nonReentrant returns(bool success)
    {
        // Owner needs to pay the servicePrice once
        require(msg.value == servicePrice, "You have to pay the listing price");
        owners[msg.sender] = Owner(
            msg.sender,
            PersonalDetails(
                _name,
                _emailId,
                _sex,
                _age,
                _aadharNumber,
                _imageURI
            ),
            true
        );
        // transfers the service fee to manager of the contract
        payable(manager).transfer(servicePrice);    
        return true;
    }

    // Lists a Renter
    function listRenter(
        address _renterAddress,
        PersonalDetails memory _personal_details,
        uint256 _startDate,
        uint256 _endDate,
        uint256 _paymentDate,
        uint256 _baseRent,
        uint256 _annualIncrementRate,
        string memory _agreementURI,
        uint256 _lastPaymentDate
    ) public nonReentrant returns(bool success)
    {
        // Only owner can list a renter
        require(owners[msg.sender].flag, "You must be an owner");        
        
        renters[_renterAddress].renterAddress = _renterAddress;
        renters[_renterAddress].personalDetails =  _personal_details;
        renters[_renterAddress].startDate = _startDate;
        renters[_renterAddress].endDate = _endDate;
        renters[_renterAddress].paymentDate = _paymentDate;
        renters[_renterAddress].baseRent = _baseRent;
        renters[_renterAddress].annualIncrementRate = _annualIncrementRate; 
        renters[_renterAddress].agreementURI = _agreementURI;
        renters[_renterAddress].lastPaymentDate = _lastPaymentDate;
        renters[_renterAddress].numberOfPayments = 0;
        renters[_renterAddress].owner = owners[msg.sender];
        renters[_renterAddress].flag = true;

        return true;   
    } 

    function getOwnerDetails(address ownerAddress) public view returns (
        string memory _name,
        string memory _emailId,
        string memory _sex,
        uint256 _age,
        uint256 _aadharNumber,
        string memory _imageURI
    ) 
    {
       _name =  owners[ownerAddress].personalDetails.name;
       _emailId = owners[ownerAddress].personalDetails.emailId;
       _sex = owners[ownerAddress].personalDetails.sex;
       _age = owners[ownerAddress].personalDetails.age;
       _aadharNumber = owners[ownerAddress].personalDetails.aadharNumber;
       _imageURI = owners[ownerAddress].personalDetails.imageURI;
    }  

    function getRenterDetails(address renterAddress) public view returns (
        PersonalDetails memory _personalDetails,
        uint256 _startDate,
        uint256 _endDate,
        uint256 _paymentDate,
        uint256 _baseRent,
        uint256 _annualIncrementRate,
        string memory _agreementURI,
        uint256 _lastPaymentDate,
        address _ownerAddress
    ) 
    {
        _personalDetails = renters[renterAddress].personalDetails;
        _startDate = renters[renterAddress].startDate;
        _endDate = renters[renterAddress].endDate;
        _paymentDate = renters[renterAddress].paymentDate;
        _baseRent = renters[renterAddress].baseRent;
        _annualIncrementRate = renters[renterAddress].annualIncrementRate;
        _agreementURI = renters[renterAddress].agreementURI;
        _lastPaymentDate = renters[renterAddress].lastPaymentDate; 
        _ownerAddress = renters[renterAddress].owner.ownerAddress;    
    }  
}