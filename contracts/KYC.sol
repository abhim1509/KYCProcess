pragma solidity ^0.5.9;

contract kyc {

  
    address admin;
    
    /*
    Struct for a customer
     */
    struct Customer {
        string userName;   //unique
        string data_hash;  //unique
        uint8 upvotes;
        address bank;
        uint rating;
        string password;
    }

    /*
    Struct for a Bank
     */
    struct Bank {
        address ethAddress;   //unique  
        string bankName;
        string regNumber;       //unique
        uint rating;   
        uint KYC_count;
    }

    /*
    Struct for a KYC Request
     */
    struct KYCRequest {
        string userName;     
        string data_hash;  //unique
        address bank;
        bool isAllowed;
    }

    /*
    Mapping a customer's username to the Customer struct
    We also keep an array of all keys of the mapping to be able to loop through them when required.
     */
    mapping(string => Customer) customers;
    string[] customerNames;

    /*
    Mapping a bank's address to the Bank Struct
    We also keep an array of all keys of the mapping to be able to loop through them when required.
     */
    mapping(address => Bank) banks;
    address[] bankAddresses;

    /*
    Mapping a customer's Data Hash to KYC request captured for that customer.
    This mapping is used to keep track of every kycRequest initiated for every customer by a bank.
     */
    mapping(string => KYCRequest) kycRequests;
    string[] customerDataList;

    /*
    Mapping a customer's user name with a bank's address
    This mapping is used to keep track of every upvote given by a bank to a customer
     */
    mapping(string => mapping(address => uint256)) upvotes;

    /**
     * Constructor of the contract.
     * We save the contract's admin as the account which deployed this contract.
     */
    constructor() public {
        admin = msg.sender;
    }

    /**
     * Record a new KYC request on behalf of a customer
     * The sender of message call is the bank itself
     * @param  {string} _userName The name of the customer for whom KYC is to be done
     * @param  {address} _bankEthAddress The ethAddress of the bank issuing this request
     * @return {bool}        True if this function execution was successful
     */
    function addKycRequest(string memory _userName, string memory _customerData) public returns (uint8) {
        // Check that the user's KYC has not been done before, the Bank is a valid bank and it is allowed to perform KYC.
        require(kycRequests[_customerData].bank == address(0), "This user already has a KYC request with same data in process.");
        //bytes memory uname = new bytes(bytes(_userName));
        // Save the timestamp for this KYC request.
        
        if(2*(banks[msg.sender].rating)>1){
        kycRequests[_customerData].data_hash = _customerData;
        kycRequests[_customerData].userName = _userName;
        kycRequests[_customerData].bank = msg.sender;
        kycRequests[_customerData].isAllowed = true;
        customerDataList.push(_customerData);
        return 1;
        }
        return 0;
    }

    /**
     * Add a new customer
     * @param {string} _userName Name of the customer to be added
     * @param {string} _hash Hash of the customer's ID submitted for KYC
     */
    function addCustomer(string memory _userName, string memory _customerData) public returns (uint8) {
        require(customers[_userName].bank == address(0), "This customer is already present, please call modifyCustomer to edit the customer data");
        require(kycRequests[_customerData].isAllowed == true);
        customers[_userName].userName = _userName;
        customers[_userName].data_hash = _customerData;
        customers[_userName].bank = msg.sender;
        customers[_userName].upvotes = 0;
        customerNames.push(_userName);
        return 1;
    }

    /**
     * Remove KYC request
     * @param  {string} _userName Name of the customer
     * @return {uint8}         A 0 indicates failure, 1 indicates success
     */
    function removeKYCRequest(string memory _userName) public returns (uint8) {
        uint8 i=0;
        for ( i = 0; i< customerDataList.length; i++) {
            if (stringsEquals(kycRequests[customerDataList[i]].userName,_userName)) {
                delete kycRequests[customerDataList[i]];
                for(uint j = i+1;j < customerDataList.length;j++) 
                { 
                    customerDataList[j-1] = customerDataList[j];
                }
                customerDataList.length --;
                i=1;
            }
        }
        return i; // 0 is returned if no request with the input username is found.
    }

    /**
     * Remove customer information
     * @param  {string} _userName Name of the customer
     * @return {uint8}         A 0 indicates failure, 1 indicates success
     */
    function removeCustomer(string memory _userName) public returns (uint8) {
            for(uint i = 0;i < customerNames.length;i++) 
            { 
                if(stringsEquals(customerNames[i],_userName))
                {
                    delete customers[_userName];
                    for(uint j = i+1;j < customerNames.length;j++) 
                    {
                        customerNames[j-1] = customerNames[j];
                    }
                    customerNames.length--;
                    return 1;
                }
                
            }
            return 0;
    }

    /**
     * Edit customer information
     * @param  {public} _userName Name of the customer
     * @param  {public} _hash New hash of the updated ID provided by the customer
     * @return {uint8}         A 0 indicates failure, 1 indicates success
     */
    function modifyCustomer(string memory _userName, string memory _newcustomerData) public returns (uint8) {
        for(uint i = 0;i < customerNames.length;i++) 
            { 
                if(stringsEquals(customerNames[i],_userName))
                {
                    customers[_userName].data_hash = _newcustomerData;
                    return 1;
                }
            
            }
            return 0;
    }

    /**
     * View customer information
     * @param  {public} _userName Name of the customer
     * @return {string} data_hash 
     */
    function viewCustomer(string memory _userName, string memory _password) public view returns (string memory) {
        bytes memory a = bytes(_password);
        if(a.length == 0){
            _password = "0";
            return customers[_userName].data_hash;
        }
        bytes memory b = bytes(customers[_userName].password);
        if(a.length == b.length){
            for(uint i=0; i<a.length; i++){
                if(a[i]!=b[i]){
                    return "0";
                }
            }
            return customers[_userName].data_hash;
        }

    }

    /**
     * Add a new upvote from a bank
     * @param {string} _userName Name of the customer to be upvoted
     */
    function Upvote(string memory _userName) public returns (uint8) {
        for(uint i = 0;i < customerNames.length;i++) 
            { 
                if(stringsEquals(customerNames[i],_userName))
                {
                    customers[_userName].upvotes++;
                    upvotes[_userName][msg.sender] = now;//storing the timestamp when vote was casted, not required though, additional
                    return 1;
                }
            
            }
            return 0;
    }

    // if you are using string, you can use the following function to compare two strings
    // function to compare two string value
    // This is an internal fucntion to compare string values
    // @Params - String a and String b are passed as Parameters
    // @return - This function returns true if strings are matched and false if the strings are not matching
    function stringsEquals(string storage _a, string memory _b) internal view returns (bool) {
        bytes storage a = bytes(_a);
        bytes memory b = bytes(_b); 
        if (a.length != b.length)
            return false;
        // @todo unroll this loop
        for (uint i = 0; i < a.length; i ++)
        {
            if (a[i] != b[i])
                return false;
        }
        return true;
    }

    /**
     * Get details of bank.
     * @param {address} _bankAddress Address of the bank whose details are to be fetched.
     * @return ethAddress, bankName, regNumber, rating, KYC_count. This function returns the details of the bank.
     */

    function getBankDetails(address _bankAddress) public view returns(address, string memory, string memory, uint, uint){
        return (banks[_bankAddress].ethAddress, banks[_bankAddress].bankName, banks[_bankAddress].regNumber,
                banks[_bankAddress].rating, banks[_bankAddress].KYC_count);
    }

    /**
     * Add bank ratings.
     * @param {address} _bankAddress Address of the bank.
     * @return 1 if rating is updated else return 0.
     */
    function addBankRatings(address _bankAddress) public returns(uint8){
        for(uint i = 0;i < bankAddresses.length;i++) 
            { 
                if(banks[bankAddresses[i]].ethAddress == _bankAddress)
                {
                    banks[bankAddresses[i]].rating++;
                    return 1;
                }
            }
        return 0;
    }

    /**
     * Get customer ratings.
     * @param {string} _customerName Customer name whose rating is to be fetched.
     * @return 1 if rating is updated else return 0.
     */
    function getCustomerRating(string memory _customerName) public view returns(uint256){
            require(customers[_customerName].bank == address(0), "Customer not found.");
            return customers[_customerName].rating;
    }
    
    /**
     * Get Bank ratings.
     * @param {address} _bankAddress Address of the bank.
     * @return rating of the bank.
     */
    function getBankRating(address _bankAddress) public view returns(uint256){
            return banks[_bankAddress].rating;
    }
    
    /**
     * Get resource history.
     * @param {string} _customerName Customer name.
     * @return bank which updated the customer.
     */
    function getResourceHistory(string memory _customerName) public view returns(address){
            require(customers[_customerName].bank == address(0), "Customer not found.");
            return customers[_customerName].bank;
    }

    /**
     * Adds a bank.
     * @param {string, address, string} _bankName, _bankAddress, _regNumber. Bank name, bank address, registered number are provided as input.
     * @return 1 if bank is saved successfully.
     */
    function addBank(string memory _bankName, address _bankAddress, string memory _regNumber) public returns(uint8){
        require(msg.sender == admin, "User does not have proper roles.");
        banks[_bankAddress].ethAddress = _bankAddress;
        banks[_bankAddress].bankName = _bankName;
        banks[_bankAddress].regNumber = _regNumber;
        return 1;
    }

    /**
     * Removes a bank.
     * @param {address} _bankAddress Bank address is provided as input.
     * @return 1 if bank is removed successfully else 0.
     */
    function removeBank(address _bankAddress) public  returns(uint8){
        require(msg.sender == admin, "User does not have proper roles.");
        for(uint i = 0; i < bankAddresses.length; i++) 
            { 
                if(banks[bankAddresses[i]].ethAddress == _bankAddress)
                {
                    delete banks[_bankAddress];
                    for(uint j = i+1;j < bankAddresses.length;j++) 
                    {
                        bankAddresses[j-1] = bankAddresses[j];
                    }
                    bankAddresses.length--;
                    return 1;
                }
                
            }
            return 0;
    }

    /**
     * Sets a password for customer.
     * @param {string, string} _userName, _password. Customer' username and passowrd is provided as input.
     * @return 1 if bank is removed successfully else 0.
     */
    function setPassword(string memory _userName, string memory _password) public returns(uint8){
        customers[_userName].password = _password;
        return 1;
    }

    /**
     * Gets bank requests.
     * @param {address} _bankAddress. Bank address is provided as input.
     * @return KYC_count of bank.
     */
    function getBankRequests(address _bankAddress) public view returns(uint){
        return banks[_bankAddress].KYC_count;     
    } 
}
