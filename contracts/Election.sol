pragma solidity 0.5.16;

// contract ElectionFactory{
//     address[] public deployedElections;
//     function createElection() public {
//         address newElection = address( new Election(msg.sender));
//         deployedElections.push(newElection);
//     }
//     function getDeployedElections() public view returns (address[] memory){
//         return deployedElections;
//     } 
// }
contract Election {
    uint public votersCount = 0;
    uint public candidatesCount= 0;
    address public manager;
        
    struct Candidate{
        uint id;
        string name;
        uint voteCount;
    }

    struct Voter {
        bool exists;
        uint id;
        string name;
        bool voted;
        string password;
        bool authenticated;
    }
    //mapping is key => value pairs 
    mapping(uint => Candidate) public candidates;
    mapping(address => Voter) public voters;
    
    //uint public candidateId;
   
    Candidate public winner;
    
    //sets deployer of contract as its manager
    //constructor(address _manager) public {
    constructor() public {
    
        manager = msg.sender;
    }

    
    //restricts action to manager if used otherwise causes error
    modifier restricted(){
        require(msg.sender == manager);
        _;
    }

    //manager adds candidates with default values
    function addCandidate(uint _id, string memory _name) public restricted{
        Candidate memory newCandidate = Candidate({
            name: _name,
            id: _id,
            voteCount: 0
        });

        candidatesCount++;
        candidates[candidatesCount] =  newCandidate;
    }
    
    //manager adds voters with default values
    function addVoter(uint _id, string memory _name, address _address) public restricted{
        Voter memory newVoter = Voter({
            exists : false,
            voted: false,
            name: _name,
            id: _id,
            password: 'dfault',
            authenticated: false
 
        });

        votersCount++;
        voters[_address] = newVoter;
        voters[_address].exists = true;
    }

    //lets voters set passwords
    function setVoterPassword(string memory _pass) public {
        require(voters[msg.sender].id!=0);
        require(voters[msg.sender].exists);
        require(!voters[msg.sender].authenticated);
        //to check strings
        require((keccak256(abi.encodePacked(voters[msg.sender].password)) == keccak256(abi.encodePacked('dfault'))));

        voters[msg.sender].password = _pass;
    }

    //Voters can vote only once
    function vote(uint _candidateId) public {
        require(voters[msg.sender].exists);
        require(voters[msg.sender].authenticated);
        require(voters[msg.sender].voted == false);

        voters[msg.sender].voted = true;
        candidates[_candidateId].voteCount++;

    }
    //Voter authentication
    function authenticate(uint _id,string memory _pass) public {
        require(voters[msg.sender].exists);
        require(!voters[msg.sender].voted);
        require((keccak256(abi.encodePacked(voters[msg.sender].password)) == keccak256(abi.encodePacked(_pass))));
        require(voters[msg.sender].id == _id);

        //(keccak256(abi.encodePacked(voters[msg.sender].password)) == keccak256(abi.encodePacked(_pass)));
        voters[msg.sender].authenticated = true;
    }

    //only manager declares the winner
    function finalizeResult() public restricted {
        uint maxIndex = 0;
        for (uint i = 1; i < candidatesCount; i++) {
            if(candidates[i].voteCount > candidates[maxIndex].voteCount){
                maxIndex = i;
            }    
        
        winner = candidates[maxIndex];

        }   
    }
    
       
}