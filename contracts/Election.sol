pragma solidity ^0.5.16;


pragma experimental ABIEncoderV2; // needed to be able to pass string arrays and structs into functions

/// @dev use this to register and unregister voters
contract RegistrationAuthority {

    address public registrationAuthority;

    address[] public deployedElections; // keeps a list of all deployed elections

    /// @dev initializes the contract and sets the contract registration authority to be the deployer of the contract
    constructor() public {
        registrationAuthority = msg.sender;
    }

    /// @dev only the registration authority is allowed functions marked with this
    /// @notice functions with this modifier can only be used by the administrator
    modifier restricted() {
        require(msg.sender == registrationAuthority, "only the registration authority is allowed to use this function");
        _;
    }

    /*****Election related function******/
    /// @dev use this to deploy new Election contracts and reset the temporary options lists afterwards
    /// @param _title specifies the name of the election (e.g. national elections)
    /// @param _description specifies the description of the election
    /// @param _startTime specifies the beginning of the election (since Unix Epoch in seconds)
    /// @param _endTime specifies a time limit until when the election is open (since Unix Epoch in seconds)
    function createElection(
        string memory _title,
        string memory _description,
        uint _startTime,
        uint _endTime,
        string memory _encryptionKey)
        public restricted {
        deployedElections.push(
            address(
                new Election(
                    registrationAuthority,
                    _title,
                    _description,
                    _startTime,
                    _endTime,
                    _encryptionKey
                )
            )
        );
    }

    /// @dev use this to return a list of addresses of all deployed Election contracts
    /// @return a list of addresses of all deployed Election contracts
    function getDeployedElections() public view returns(address[] memory) {
        return deployedElections;
    }
}

/// @dev This is the actual election contract where users can vote
/// @dev Security by design: secret sharing, allows voters one time voting
contract Election {

    struct Voter {
        uint listPointer;
        bool isVoter;
        address ethAddress;
    }

    mapping(address => Voter) private votersList;
    address[] private votersReferenceList;

    /*****Voter related function******/
    /// @dev use this to register or update a voter
    function registerVoter(address _voter) external restricted beforeElection {

        //ONLY ONE TIME ADDRESS REGISTRATION POSSIBLE PER ELECTION
        votersList[_voter].listPointer = votersReferenceList.push(_voter) - 1;
        votersList[_voter].isVoter = true;
        votersList[_voter].ethAddress = _voter;

    }

    /// @dev use this to unregister a voter
    function unregisterVoter(address _voter) external restricted beforeElection{
        require(votersList[_voter].isVoter == true, "this address is not registered as a voter");

        // Delete the desired entry by moving the last item in the array to the row to delete, and then shorten the array by one
        votersList[_voter].isVoter = false;
        uint rowToDelete = votersList[_voter].listPointer;
        address keyToMove = votersReferenceList[votersReferenceList.length - 1];
        votersReferenceList[rowToDelete] = keyToMove;
        votersList[keyToMove].listPointer = rowToDelete;
        votersReferenceList.length--;
    }

    /// @dev use this to check whether an address belongs to a valid voter
    function isRegisteredVoter(address _voter) public view returns(bool) {
        if (votersReferenceList.length == 0) return false;
        return (votersList[_voter].isVoter);
    }

    /// @dev use this this to get the number of registered voters
    function getNumberOfVoters() public view returns(uint) {
        return votersReferenceList.length;
    }

    /// @dev get a list of registered voters
    function getListOfVoters() public view returns(address[] memory x) {
        return votersReferenceList;
    }

    /// @dev get details of a specific voter
    function getVoterDetails(address _voter) public view returns(Voter memory) {
        return votersList[_voter];
    }


    /*****Election related function******/
    struct Ballot {
        string name;
        string party;
    }

    address public registrationAuthority;
    string public title;
    string public description;
    uint public startTime;
    uint public endTime;
    Ballot[] public ballotList;
    string public encryptionKey;
    uint[] public publishedResult;

    mapping(address => bool) private votersCheckList; // records that the voter has voted
    string[] private encryptedVoteList; // keeps a list of all encrypted votes

    /// @dev initializes the contract with all required parameters
    constructor(
        address _registrationAuthority,
        string memory _title,
        string memory _description,
        uint _startTime,
        uint _endTime,
        string memory _encryptionKey
    ) public {
        registrationAuthority=_registrationAuthority;
        //registrationAuthorityContractAdd = msg.sender;
        title = _title;
        description = _description;
        startTime = _startTime;
        endTime = _endTime;
        encryptionKey = _encryptionKey;
    }

    /// @dev only the registration authority is allowed functions marked with this
    /// @notice functions with this modifier can only be used by the registration authority
    modifier restricted() {
        require(msg.sender == registrationAuthority, "only the registration authority is allowed to use this function");
        _;
    }

    /// @dev functions marked with this can be called before the specified start time
    modifier beforeElection() {
        require(now < startTime, "only allowed before election");
        _;
    }

    /// @dev functions marked with this can be called during the specified time frame
    modifier duringElection() {
        require(now > startTime && now < endTime, "only allowed during election");
        _;
    }

    /// @dev functions marked with this can be called after the specified end time
    modifier afterElection() {
        require(now > endTime, "only allowed after election");
        _;
    }

    /// @dev add an option to the ballot before the election starts
    function addCandidate(string calldata _name, string calldata _party) external restricted beforeElection {
        ballotList.push(Ballot({ name: _name, party: _party }));
    }

    /// @dev get all available options on the ballot
    function getBallot() external view returns(Ballot[] memory x) {
        return ballotList;
    }



    /// @dev get the list of encrypted votes of a voter, only allowed after the election is over
    function getencryptedVoteList() external view restricted afterElection returns(string[] memory success) {
        return encryptedVoteList;
    }
    /// @dev publish the decrypted version of the sum of all votes for each candidate
    function publishResults(uint[] calldata results) external restricted afterElection returns(bool success) {
        publishedResult = results;
        return true;
    }

    /// @dev returns the list of final votes for each candidate
    function getResults() external view afterElection returns(uint[] memory results) {
        return publishedResult;
    }

    /// @dev this is used to cast a vote. the vote is homomorphically encrypted
    /// @dev allows users to vote multiple times, invalidating the previous vote
    function vote(string calldata _encryptedVote) external duringElection returns(bool success) {
        require(isRegisteredVoter(msg.sender), "message sender is not a registered voter");
        require(!votersCheckList[msg.sender],"only one vote possible");
        encryptedVoteList.push(_encryptedVote);
        votersCheckList[msg.sender] = true;

        return true;
    }

    /// @dev find out whether a voter has submitted their vote
    function hasVoted(address _address) public view returns(bool) {
        return votersCheckList[_address];
    }

}